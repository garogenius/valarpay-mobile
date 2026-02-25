import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/utils/responsive_utils.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/notifiers/wallet_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/models/api_response.dart';

class AccountSetupScreen extends ConsumerStatefulWidget {
  final String accountType;

  const AccountSetupScreen({super.key, this.accountType = 'USD'});

  @override
  ConsumerState<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends ConsumerState<AccountSetupScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Passport info
  final TextEditingController _passportNumberController = TextEditingController();
  final TextEditingController _passportCountryController = TextEditingController();
  final TextEditingController _issueDateController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  File? _passportFile;

  // Address info
  String? _addressDocType;
  File? _addressFile;

  // Account creation info
  final TextEditingController _labelController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _labelController.text = 'My ${widget.accountType} Account';
    
    // Populate existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user != null) {
        if (user.passportNumber != null) _passportNumberController.text = user.passportNumber!;
        if (user.passportCountry != null) _passportCountryController.text = user.passportCountry!;
        if (user.passportIssueDate != null) _issueDateController.text = user.passportIssueDate!;
        if (user.passportExpiryDate != null) _expiryDateController.text = user.passportExpiryDate!;
        
        // Detect address document type
        if (user.bankStatementUrl != null && user.bankStatementUrl!.isNotEmpty) {
          _addressDocType = 'bank_statement';
        } else if (user.utilityBillUrl != null && user.utilityBillUrl!.isNotEmpty) {
          _addressDocType = 'utility_bill';
        }

        if (user.passportNumber != null && user.passportNumber!.isNotEmpty) {
          if (user.isAddressVerified) {
            setState(() {
              _currentStep = 2; // Skip to label entry
            });
          } else {
            setState(() {
              _currentStep = 1; // Skip to address verification
            });
          }
        }
      }
    });
  }

  String get accountTitle {
    switch (widget.accountType) {
      case 'USD':
        return 'Get USD Account';
      case 'EUR':
        return 'Get Euro Account';
      case 'GBP':
        return 'Get Pound Account';
      default:
        return 'Get Account';
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickFile(bool isPassport) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    if (isPassport) {
                      _passportFile = File(image.path);
                    } else {
                      _addressFile = File(image.path);
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    if (isPassport) {
                      _passportFile = File(image.path);
                    } else {
                      _addressFile = File(image.path);
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Upload PDF'),
              onTap: () async {
                Navigator.pop(context);
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null) {
                  setState(() {
                    if (isPassport) {
                      _passportFile = File(result.files.single.path!);
                    } else {
                      _addressFile = File(result.files.single.path!);
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleProceed() async {
    if (_currentStep == 0) {
      // Step 1: Passport Info
      if (_passportFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload your passport scan")),
        );
        return;
      }

      if (!_formKey.currentState!.validate()) return;

      try {
        // 1. Upload the physical document
        await ref.read(userNotifierProvider.notifier).uploadDocument(
          documentType: 'passport',
          documentPath: _passportFile!.path,
          documentNumber: _passportNumberController.text,
          documentCountry: _passportCountryController.text,
          issueDate: _issueDateController.text,
          expiryDate: _expiryDateController.text,
        );

        final updatedUser = ref.read(userProvider);
        setState(() {
          _currentStep = (updatedUser?.isAddressVerified ?? false) ? 2 : 1;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else if (_currentStep == 1) {
      // Step 2: Address Verification
      if (_addressDocType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select address document type")),
        );
        return;
      }

      if (_addressFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload your address document")),
        );
        return;
      }

      try {
        // 1. Upload address document
        await ref.read(userNotifierProvider.notifier).uploadDocument(
          documentType: _addressDocType!,
          documentPath: _addressFile!.path,
        );

        setState(() {
          _currentStep = 2; // Move to label entry
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else if (_currentStep == 2) {
      // Step 3: Account Label & Final Creation
      if (!_formKey.currentState!.validate()) return;

      try {
        await ref.read(walletNotifierProvider.notifier).createMultiCurrencyAccount(
          currency: widget.accountType,
          label: _labelController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${widget.accountType} Account created successfully!")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final walletState = ref.watch(walletNotifierProvider);
    final isLoading = userState.isInitialLoading || walletState.isInitialLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          "Setup ${widget.accountType} Account",
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.paddingAll16,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(),
              SizedBox(height: 24.h),
              if (_currentStep == 0)
                _buildPassportStep()
              else if (_currentStep == 1)
                _buildAddressStep()
              else
                _buildLabelStep(),
              SizedBox(height: 40.h),
              Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 55.h,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: appTheme.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _currentStep--;
                                  });
                                },
                          child: Text(
                            "Back",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: appTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 55.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isLoading ? null : _handleProceed,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _currentStep == 0
                                    ? "Verify Passport"
                                    : _currentStep == 1
                                        ? "Verify Address"
                                        : "Create ${widget.accountType} Account",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    // We always show all 3 steps so users can navigate back and forth to "preview" their info
    final List<Map<String, dynamic>> visibleSteps = [
      {'id': 0, 'title': 'Passport'},
      {'id': 1, 'title': 'Address'},
      {'id': 2, 'title': 'Account Info'},
    ];

    List<Widget> children = [];
    for (int i = 0; i < visibleSteps.length; i++) {
      final step = visibleSteps[i];
      final stepId = step['id'] as int;
      final stepTitle = step['title'] as String;
      
      children.add(_stepCircle(i + 1, stepTitle, _currentStep >= stepId));
      
      if (i < visibleSteps.length - 1) {
        final nextStepId = visibleSteps[i + 1]['id'] as int;
        children.add(_stepLine(_currentStep >= nextStepId));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _stepCircle(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? appTheme.primaryColor : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: isActive ? appTheme.primaryColor : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.only(bottom: 15.h, left: 8.w, right: 8.w),
        color: isActive ? appTheme.primaryColor : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildPassportStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Passport Information",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Please providing your passport information to proceed with the account setup.",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        SizedBox(height: 24.h),
        _buildFileUploadBox(
          label: "Passport Scan (Required)",
          file: _passportFile,
          networkUrl: ref.watch(userProvider)?.passportDocumentUrl,
          onTap: () => _pickFile(true),
        ),
        SizedBox(height: 20.h),
        _buildTextField("Passport Number", _passportNumberController, hint: "Enter passport number"),
        SizedBox(height: 16.h),
        _buildTextField("Country of Issue", _passportCountryController, hint: "e.g. NG, US, GB"),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: _buildDateField("Issue Date", _issueDateController)),
            SizedBox(width: 16.w),
            Expanded(child: _buildDateField("Expiry Date", _expiryDateController)),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Address Verification",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Select a document type and upload a clear scan for address verification.",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        SizedBox(height: 24.h),
        Text(
          "Document Type",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _choiceChip(
                label: "Bank Statement",
                isSelected: _addressDocType == 'bank_statement',
                onSelected: (val) => setState(() => _addressDocType = 'bank_statement'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _choiceChip(
                label: "Utility Bill",
                isSelected: _addressDocType == 'utility_bill',
                onSelected: (val) => setState(() => _addressDocType = 'utility_bill'),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        _buildFileUploadBox(
          label: "Upload Document (Required)",
          file: _addressFile,
          networkUrl: _addressDocType == 'bank_statement' 
              ? ref.watch(userProvider)?.bankStatementUrl 
              : ref.watch(userProvider)?.utilityBillUrl,
          onTap: () => _pickFile(false),
        ),
      ],
    );
  }

  Widget _buildLabelStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Account Label",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Give your new ${widget.accountType} account a name for easy identification.",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        SizedBox(height: 32.h),
        _buildTextField(
          "Account Label",
          _labelController,
          hint: "e.g. My Savings, Business Account",
        ),
      ],
    );
  }

  Widget _choiceChip({required String label, required bool isSelected, required Function(bool) onSelected}) {
    return ChoiceChip(
      label: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(label),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: appTheme.primaryColor.withOpacity(0.2),
      backgroundColor: Theme.of(context).cardColor,
      labelStyle: TextStyle(
        color: isSelected ? appTheme.primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(
          color: isSelected ? appTheme.primaryColor : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildFileUploadBox({required String label, File? file, String? networkUrl, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: (file == null && (networkUrl == null || networkUrl.isEmpty))
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 40.sp, color: Colors.grey),
                      SizedBox(height: 8.h),
                      Text("Tap to upload JPG, PNG or PDF", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    ],
                  )
                : Stack(
                    children: [
                      Center(
                        child: file != null
                            ? (file.path.endsWith('.pdf')
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.picture_as_pdf, size: 40.sp, color: Colors.red),
                                      SizedBox(height: 8.h),
                                      Text(file.path.split('/').last,
                                          style: TextStyle(fontSize: 12.sp), overflow: TextOverflow.ellipsis),
                                    ],
                                  )
                                : Image.file(file, fit: BoxFit.contain))
                            : (networkUrl!.toLowerCase().endsWith('.pdf')
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.picture_as_pdf, size: 40.sp, color: Colors.red),
                                      SizedBox(height: 8.h),
                                      Text("View Document", style: TextStyle(fontSize: 12.sp)),
                                    ],
                                  )
                                : Image.network(networkUrl, fit: BoxFit.contain)),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 12.r,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.refresh, size: 16.sp, color: appTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _pickDate(controller),
      child: AbsorbPointer(
        child: _buildTextField(label, controller, hint: "YYYY-MM-DD"),
      ),
    );
  }
}