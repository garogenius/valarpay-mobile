import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/features/notifiers/wallet_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class PayshigaMcyAccountForm extends ConsumerStatefulWidget {
  final String currency; // Expected to be 'USD', 'EUR', or 'GBP'

  const PayshigaMcyAccountForm({
    Key? key,
    required this.currency,
  }) : super(key: key);

  @override
  ConsumerState<PayshigaMcyAccountForm> createState() => _PayshigaMcyAccountFormState();
}

class _PayshigaMcyAccountFormState extends ConsumerState<PayshigaMcyAccountForm> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _profileFormKey = GlobalKey<FormState>();
  int _currentStep = 1;
  bool _hasMissingInfo = false;
  bool _isUpdatingProfile = false;

  String? _phoneNumber;
  String? _address;
  String? _city;
  String? _state;
  String? _postalCode;
  String? _bvn;
  
  String? _incomeBand;
  String? _sourceOfIncome;
  String? _accountDesignation;
  String? _occupation;
  String? _employmentStatus;

  File? _utilityBillFile;

  String? _selectedAdditionalIdType;
  final List<String> _additionalIdTypes = ['PASSPORT', 'DRIVER_LICENSE', 'RESIDENT_CARD'];
  String? _additionalIdNumber;
  String? _additionalIdIssueDate;
  String? _additionalIdExpiryDate;
  File? _additionalIdFile;

  Future<void> _pickAdditionalIdFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'jpeg'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _additionalIdFile = File(result.files.single.path!);
      });
    }
  }
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user != null) {
        setState(() {
          _phoneNumber = user.phoneNumber;
          _address = user.address;
          _city = user.city;
          _state = user.state;
          _postalCode = user.postalCode;
          // Note: bvn is usually not returned in full for security, but handled if exists
          
          _hasMissingInfo = (user.phoneNumber == null || user.phoneNumber!.isEmpty) ||
                               (user.address == null || user.address!.isEmpty) ||
                               (user.city == null || user.city!.isEmpty) ||
                               (user.state == null || user.state!.isEmpty) ||
                               (user.isBvnVerified != true);
        });
      }
    });
  }

  final List<String> _incomeBands = ['0-50,000', '50,001-100,000', '100,001-500,000', '500,001+'];
  final List<String> _employmentStatuses = ['Employed', 'Self-Employed', 'Unemployed', 'Student'];

  Future<void> _pickUtilityBill() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'jpeg'],
    );
    
    if (result != null && result.files.single.path != null) {
      setState(() {
        _utilityBillFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitForm(bool isFirstPayshigaAccount) async {
    print("🔘 CREATE ACCOUNT BUTTON CLICKED");
    if (_utilityBillFile == null) {
      AppMessenger.show(context, message: 'Please upload a utility bill document.', type: MessageType.error);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      print("📤 Submitting multi-currency account request for ${widget.currency}...");
      final repo = ref.read(walletRepositoryProvider);
      
      await repo.createMultiCurrencyAccount(
        currency: widget.currency,
        label: '${widget.currency} Virtual Account',
        phoneNumber: _phoneNumber,
        address: _address,
        city: _city,
        state: _state,
        postalCode: _postalCode,
        bvn: _bvn,
        utilityBillPath: _utilityBillFile?.path,
        incomeBand: _incomeBand,
        sourceOfIncome: _sourceOfIncome,
        accountDesignation: _accountDesignation,
        occupation: _occupation,
        employmentStatus: _employmentStatus,
        additionalIdType: isFirstPayshigaAccount ? _selectedAdditionalIdType : null,
        additionalIdNumber: isFirstPayshigaAccount ? _additionalIdNumber : null,
        additionalIdIssueDate: isFirstPayshigaAccount ? _additionalIdIssueDate : null,
        additionalIdExpiryDate: isFirstPayshigaAccount ? _additionalIdExpiryDate : null,
        additionalIdDocumentPath: isFirstPayshigaAccount ? _additionalIdFile?.path : null,
      );

      print("✅ Account creation request successful!");
      if (mounted) {
        AppMessenger.show(context, message: 'Account creation request submitted successfully!', type: MessageType.success);
        context.go('/dashboard'); // Or pop depending on navigation flow
      }
    } catch (e) {
      print("❌ Account creation failed: $e");
      if (mounted) {
        AppMessenger.show(context, message: e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isLoading = _isSubmitting;
    final user = ref.watch(userProvider);
    final wallets = user?.wallets ?? [];
    final hasPayshigaAccount = wallets.any((w) => w.currency == 'USD' || w.currency == 'EUR' || w.currency == 'GBP');
    final isFirstPayshigaAccount = !hasPayshigaAccount;
    
    int totalSteps = isFirstPayshigaAccount ? 4 : 3;

    return Scaffold(
      appBar: AppBar(
        title: Text('Step $_currentStep of $totalSteps'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildCurrentStep(isFirstPayshigaAccount, totalSteps, isLoading),
      ),
    );
  }

  Widget _buildCurrentStep(bool isFirstPayshigaAccount, int totalSteps, bool isLoading) {
    if (_currentStep == 1) {
      return Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step 1: Personal & Address Details",
              style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "We need your personal and address details to create your ${widget.currency} account.",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            _buildTextFormField(
              'Phone Number',
              initialValue: _phoneNumber,
              onChanged: (val) => _phoneNumber = val,
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              'Address',
              initialValue: _address,
              onChanged: (val) => _address = val,
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              'City',
              initialValue: _city,
              onChanged: (val) => _city = val,
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              'State',
              initialValue: _state,
              onChanged: (val) => _state = val,
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              'Postal Code',
              initialValue: _postalCode,
              onChanged: (val) => _postalCode = val,
            ),
            const SizedBox(height: 16),
            
            if (user?.isBvnVerified != true) ...[
              _buildTextFormField(
                'BVN (Required if not added)',
                initialValue: _bvn,
                onChanged: (val) => _bvn = val,
              ),
            ],
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF76301),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (!_profileFormKey.currentState!.validate()) return;
                  setState(() => _currentStep = 2);
                },
                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentStep == 2) {
      return Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step 2: Account Information",
              style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please provide a few more details for your ${widget.currency} account compliance.",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Income Band',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: _incomeBand,
              items: _incomeBands.map((band) {
                return DropdownMenuItem(value: band, child: Text(band));
              }).toList(),
              onChanged: (val) => setState(() => _incomeBand = val),
              validator: (val) => val == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Source of Income',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => _sourceOfIncome = val,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Account Designation (e.g. Personal, Savings)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => _accountDesignation = val,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Occupation',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => _occupation = val,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Employment Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: _employmentStatus,
              items: _employmentStatuses.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (val) => setState(() => _employmentStatus = val),
              validator: (val) => val == null ? 'Required' : null,
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF76301)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => setState(() => _currentStep = 1),
                      child: const Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF76301),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF76301),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (!_formKey1.currentState!.validate()) return;
                        setState(() => _currentStep = 3);
                      },
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 16,
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
      );
    } else if (_currentStep == 3 && isFirstPayshigaAccount) {
      return Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step 3: Identity Verification",
              style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please upload a valid identification document.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Document Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: _selectedAdditionalIdType,
              items: _additionalIdTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) => setState(() => _selectedAdditionalIdType = val),
              validator: (val) => val == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Document Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => _additionalIdNumber = val,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Issue Date (YYYY-MM-DD)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => _additionalIdIssueDate = val,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Expiry Date (YYYY-MM-DD)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => _additionalIdExpiryDate = val,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const Text('Document File (PDF, JPG, PNG)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickAdditionalIdFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(Icons.upload_file, size: 40, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 8),
                    Text(
                      _additionalIdFile != null ? _additionalIdFile!.path.split('/').last : 'Tap to upload Identity Document',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _additionalIdFile != null ? Colors.green : Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF76301)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => setState(() => _currentStep = 2),
                      child: const Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF76301),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF76301),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (!_formKey2.currentState!.validate()) return;
                        if (_additionalIdFile == null) {
                          AppMessenger.show(context, message: 'Please upload your identity document to continue.', type: MessageType.error);
                          return;
                        }
                        setState(() => _currentStep = 4);
                      },
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 16,
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
      );
    } else {
      int backStep = isFirstPayshigaAccount ? 3 : 2;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Step $totalSteps: Utility Bill",
            style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "A valid utility bill is required for ${widget.currency} account creation.",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text('Utility Bill (PDF, JPG, PNG)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickUtilityBill,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file, size: 40, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    _utilityBillFile != null ? _utilityBillFile!.path.split('/').last : 'Tap to upload utility bill',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _utilityBillFile != null ? Colors.green : Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFF76301)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => setState(() => _currentStep = backStep),
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF76301),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF76301),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : () {
                      _submitForm(isFirstPayshigaAccount);
                    },
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 16,
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
      );
    }
  }


  Widget _buildTextFormField(
    String label, {
    String? initialValue,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
