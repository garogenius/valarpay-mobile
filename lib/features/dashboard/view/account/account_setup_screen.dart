import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/utils/responsive_utils.dart';
import 'package:valarpay/features/notifiers/wallet_notifier.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class AccountSetupScreen extends ConsumerStatefulWidget {
  final String accountType;

  const AccountSetupScreen({super.key, this.accountType = 'USD'});

  @override
  ConsumerState<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends ConsumerState<AccountSetupScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _profileFormKey = GlobalKey<FormState>();
  final _ngnFormKey = GlobalKey<FormState>();
  int _currentStep = 1;
  bool _hasMissingInfo = false;
  bool _isUpdatingProfile = false;

  String? _phoneNumber;
  String? _address;
  String? _city;
  String? _state;
  String? _postalCode;
  String? _bvn;
  final TextEditingController _labelController = TextEditingController();
  
  String? _selectedNgnDocType;
  final TextEditingController _ngnDocNumberController = TextEditingController();
  
  // Payshiga specific controllers
  final TextEditingController _incomeBandController = TextEditingController();
  final TextEditingController _sourceOfIncomeController = TextEditingController();
  final TextEditingController _accountDesignationController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  
  String? _selectedEmploymentStatus;
  final List<String> _employmentStatuses = ['Employed', 'Self-Employed', 'Unemployed', 'Student', 'Retired'];

  String? _selectedSourceOfIncome;
  final List<String> _sourceOfIncomes = ['Salary', 'Business', 'Freelance', 'Investments', 'Pension', 'Other'];

  File? _utilityBillFile;
  bool _requiresUtilityBill = false;

  // Additional ID controllers (For first-time Payshiga users)
  String? _selectedAdditionalIdType;
  final List<String> _additionalIdTypes = ['PASSPORT', 'DRIVER_LICENSE', 'RESIDENT_CARD'];
  final TextEditingController _additionalIdNumberController = TextEditingController();
  final TextEditingController _additionalIdIssueDateController = TextEditingController();
  final TextEditingController _additionalIdExpiryDateController = TextEditingController();
  File? _additionalIdFile;

  @override
  void initState() {
    super.initState();
    _labelController.text = 'My ${widget.accountType} Account';

    final isPayshigaCurrency = widget.accountType == 'USD' || widget.accountType == 'EUR' || widget.accountType == 'GBP';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user != null && isPayshigaCurrency) {
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

  Future<void> _updateProfileAndContinue() async {
    if (!_profileFormKey.currentState!.validate()) return;
    setState(() => _isUpdatingProfile = true);
    try {
      final user = ref.read(userProvider);

      if (user != null && user.isBvnVerified != true && _bvn != null && _bvn!.isNotEmpty) {
         final bvnRes = await ref.read(userNotifierProvider.notifier).verifyBvnTier2(_bvn!);
         if (bvnRes == null || !bvnRes.isSuccess) {
            throw Exception(bvnRes?.message ?? 'BVN verification failed');
         }
      }

      await ref.read(userNotifierProvider.notifier).editProfile(
        fullName: user?.fullName,
        phoneNumber: _phoneNumber,
        address: _address,
        city: _city,
        state: _state,
        postalCode: _postalCode,
      );
      if (mounted) {
        setState(() {
          _hasMissingInfo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingProfile = false);
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _incomeBandController.dispose();
    _sourceOfIncomeController.dispose();
    _accountDesignationController.dispose();
    _occupationController.dispose();
    _additionalIdNumberController.dispose();
    _additionalIdIssueDateController.dispose();
    _additionalIdExpiryDateController.dispose();
    _ngnDocNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleProceed(bool isFirstPayshigaAccount) async {
    

    if (_requiresUtilityBill && _utilityBillFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a utility bill to continue.')),
      );
      return;
    }

    if (isFirstPayshigaAccount && _additionalIdFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your identity document to continue.')),
      );
      return;
    }

    try {
      await ref.read(walletNotifierProvider.notifier).createMultiCurrencyAccount(
        currency: widget.accountType,
        label: _labelController.text,
        phoneNumber: _phoneNumber,
        address: _address,
        city: _city,
        state: _state,
        postalCode: _postalCode,
        bvn: _bvn,
        utilityBillPath: _utilityBillFile?.path,
        incomeBand: _requiresUtilityBill ? _incomeBandController.text.trim() : null,
        sourceOfIncome: _requiresUtilityBill ? _selectedSourceOfIncome : null,
        accountDesignation: _requiresUtilityBill ? _accountDesignationController.text.trim() : null,
        occupation: _requiresUtilityBill ? _occupationController.text.trim() : null,
        employmentStatus: _requiresUtilityBill ? _selectedEmploymentStatus : null,
        additionalIdType: isFirstPayshigaAccount ? _selectedAdditionalIdType : null,
        additionalIdNumber: isFirstPayshigaAccount ? _additionalIdNumberController.text.trim() : null,
        additionalIdIssueDate: isFirstPayshigaAccount ? _additionalIdIssueDateController.text.trim() : null,
        additionalIdExpiryDate: isFirstPayshigaAccount ? _additionalIdExpiryDateController.text.trim() : null,
        additionalIdDocumentPath: isFirstPayshigaAccount ? _additionalIdFile?.path : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.accountType} Account created successfully!")),
        );
        context.pushReplacement('/multi-currency-dashboard/${widget.accountType}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifierProvider);
    final isLoading = walletState.isInitialLoading;

    final user = ref.watch(userProvider);
    final wallets = user?.wallets ?? [];
    final hasPayshigaAccount = wallets.any((w) => w.currency == 'USD' || w.currency == 'EUR' || w.currency == 'GBP');
    final isFirstPayshigaAccount = _requiresUtilityBill && !hasPayshigaAccount;
    
    // We only need utility bill for USD, EUR, GBP (Payshiga)
    _requiresUtilityBill = widget.accountType == 'USD' || widget.accountType == 'EUR' || widget.accountType == 'GBP';

    // If it's NGN, show the NGN setup form
    if (widget.accountType == 'NGN') {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Setup NGN Account",
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: ResponsiveUtils.paddingAll16,
          child: _buildNgnSetupForm(),
        ),
      );
    }
    
    // If it's Payaza (not NGN, not Payshiga), just show label step
    if (!_requiresUtilityBill) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
            onPressed: () => Navigator.pop(context),
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
            key: _formKey1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabelStep(),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  height: 55.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : () {
                      if (!_formKey1.currentState!.validate()) return;
                      _handleProceed(isFirstPayshigaAccount);
                    },
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            "Create ${widget.accountType} Account",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // For Payshiga (USD, EUR, GBP), show the 4-step wizard
    int totalSteps = isFirstPayshigaAccount ? 4 : 3; // Step 1: Profile, Step 2: Details, Step 3: ID (if first time), Step 4: Utility
    // Adjust step count based on whether they need to provide additional ID
    int displayStep = _currentStep;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          "Step $_currentStep of $totalSteps",
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.paddingAll16,
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              "We need your personal and address details to create your ${widget.accountType} account.",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 24.h),
            
            _buildTextFormField(
              'Phone Number',
              initialValue: _phoneNumber,
              onChanged: (val) => _phoneNumber = val,
            ),
            SizedBox(height: 16.h),
            
            _buildTextFormField(
              'Address',
              initialValue: _address,
              onChanged: (val) => _address = val,
            ),
            SizedBox(height: 16.h),
            
            _buildTextFormField(
              'City',
              initialValue: _city,
              onChanged: (val) => _city = val,
            ),
            SizedBox(height: 16.h),
            
            _buildTextFormField(
              'State',
              initialValue: _state,
              onChanged: (val) => _state = val,
            ),
            SizedBox(height: 16.h),
            
            _buildTextFormField(
              'Postal Code',
              initialValue: _postalCode,
              onChanged: (val) => _postalCode = val,
            ),
            SizedBox(height: 16.h),
            
            if (ref.read(userProvider)?.isBvnVerified != true) ...[
              _buildTextFormField(
                'BVN (Required if not added)',
                initialValue: _bvn,
                onChanged: (val) => _bvn = val,
              ),
            ],
            SizedBox(height: 32.h),

            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (!_profileFormKey.currentState!.validate()) return;
                  setState(() => _currentStep = 2);
                },
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 16.sp,
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Please provide a few more details for your ${widget.accountType} account compliance.",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 24.h),
            _buildLabelStep(),
            SizedBox(height: 24.h),
            _buildPayshigaFields(),
            SizedBox(height: 40.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: appTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () => setState(() => _currentStep = 1),
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
                Expanded(
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
                      onPressed: () {
                        if (!_formKey1.currentState!.validate()) return;
                        setState(() => _currentStep = 3);
                      },
                      child: Text(
                        "Next",
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
      );
    } else if (_currentStep == 3 && isFirstPayshigaAccount) {
      return Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step 3: Identity Verification",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Please upload a valid identification document.",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 24.h),
            _buildAdditionalIdFields(),
            SizedBox(height: 24.h),
            _buildAdditionalIdFileStep(),
            SizedBox(height: 40.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: appTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () => setState(() => _currentStep = 2),
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
                Expanded(
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
                      onPressed: () {
                        if (!_formKey2.currentState!.validate()) return;
                        if (_additionalIdFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please upload your identity document to continue.')),
                          );
                          return;
                        }
                        setState(() => _currentStep = 4);
                      },
                      child: Text(
                        "Next",
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
      );
    } else {
      // Final Step: Utility Bill (Step 3 or 4 depending on isFirstPayshigaAccount)
      int backStep = isFirstPayshigaAccount ? 3 : 2;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Step $totalSteps: Utility Bill",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            "A valid utility bill is required for ${widget.accountType} account creation.",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 24.h),
          _buildUtilityBillStep(),
          SizedBox(height: 40.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: appTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () => setState(() => _currentStep = backStep),
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
              Expanded(
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
                    onPressed: isLoading ? null : () => _handleProceed(isFirstPayshigaAccount),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            "Create Account",
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
      );
    }
  }

  Widget _buildProfileUpdateForm() {
    return Form(
      key: _profileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Complete Your Profile",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            "We need a few more personal details before creating your ${widget.accountType} account.",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 24.h),
          
          _buildTextFormField(
            'Phone Number',
            initialValue: _phoneNumber,
            onChanged: (val) => _phoneNumber = val,
          ),
          SizedBox(height: 16.h),
          
          _buildTextFormField(
            'Address',
            initialValue: _address,
            onChanged: (val) => _address = val,
          ),
          SizedBox(height: 16.h),
          
          _buildTextFormField(
            'City',
            initialValue: _city,
            onChanged: (val) => _city = val,
          ),
          SizedBox(height: 16.h),
          
          _buildTextFormField(
            'State',
            initialValue: _state,
            onChanged: (val) => _state = val,
          ),
          SizedBox(height: 16.h),
          
          _buildTextFormField(
            'Postal Code',
            initialValue: _postalCode,
            onChanged: (val) => _postalCode = val,
          ),
          SizedBox(height: 16.h),
          
          if (ref.read(userProvider)?.isBvnVerified != true) ...[
            _buildTextFormField(
              'BVN (Required if not added)',
              initialValue: _bvn,
              onChanged: (val) => _bvn = val,
            ),
          ],
          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              onPressed: _isUpdatingProfile ? null : _updateProfileAndContinue,
              child: _isUpdatingProfile
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      "Save & Continue",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNgnSetupForm() {
    return Form(
      key: _ngnFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Setup NGN Account",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Please select your verification method and enter the ID number.",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 32.h),
          Text(
            "Document Type",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            value: _selectedNgnDocType,
            hint: const Text("Select Document Type"),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'nin', child: Text('Setup using NIN')),
              DropdownMenuItem(value: 'bvn', child: Text('Setup using BVN')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedNgnDocType = value;
                _ngnDocNumberController.clear();
              });
            },
            validator: (value) => value == null ? "Document Type is required" : null,
          ),
          SizedBox(height: 16.h),
          if (_selectedNgnDocType != null)
            _buildTextField(
              "Document Number",
              _ngnDocNumberController,
              hint: "Enter your ${_selectedNgnDocType?.toUpperCase()}",
              keyboardType: TextInputType.number,
              maxLength: 11, // Both BVN and NIN are 11 digits typically
            ),
          SizedBox(height: 40.h),
          SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              onPressed: () {
                if (!_ngnFormKey.currentState!.validate()) return;
                
                context.push('/ngn-face-capture', extra: {
                  'docType': _selectedNgnDocType,
                  'docNumber': _ngnDocNumberController.text.trim(),
                });
              },
              child: Text(
                "Proceed",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildPayshigaFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Additional Details",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Please provide a few more details for your ${widget.accountType} account compliance.",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        SizedBox(height: 24.h),
        _buildTextField(
          "Income Band",
          _incomeBandController,
          hint: "e.g. \$10,000 - \$50,000",
        ),
        SizedBox(height: 16.h),
        Text(
          "Source of Income",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedSourceOfIncome,
          hint: const Text("Select Source of Income"),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
          items: _sourceOfIncomes.map((source) {
            return DropdownMenuItem(
              value: source,
              child: Text(source),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSourceOfIncome = value;
            });
          },
          validator: (value) => value == null ? "Source of Income is required" : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          "Account Designation",
          _accountDesignationController,
          hint: "e.g. Personal Savings, Operations",
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          "Occupation",
          _occupationController,
          hint: "e.g. Software Engineer",
        ),
        SizedBox(height: 16.h),
        Text(
          "Employment Status",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedEmploymentStatus,
          hint: const Text("Select Employment Status"),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
          items: _employmentStatuses.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedEmploymentStatus = value;
            });
          },
          validator: (value) => value == null ? "Employment Status is required" : null,
        ),
      ],
    );
  }

  Future<void> _pickUtilityBill() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _utilityBillFile = File(result.files.single.path!);
      });
    }
  }

  Widget _buildUtilityBillStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickUtilityBill,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
            decoration: BoxDecoration(
              border: Border.all(color: appTheme.primaryColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12.r),
              color: appTheme.primaryColor.withOpacity(0.05),
            ),
            child: Column(
              children: [
                Icon(
                  _utilityBillFile != null ? Icons.check_circle : Icons.upload_file,
                  color: _utilityBillFile != null ? Colors.green : appTheme.primaryColor,
                  size: 40.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  _utilityBillFile != null
                      ? "File Selected: ${_utilityBillFile!.path.split('/').last}"
                      : "Tap to upload Utility Bill (PDF, JPG, PNG)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: _utilityBillFile != null ? Colors.green : appTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAdditionalIdFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _additionalIdFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildAdditionalIdFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Identity Verification",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          "This is your first ${widget.accountType} account, please provide additional identity details.",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        SizedBox(height: 24.h),
        Text(
          "ID Type",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedAdditionalIdType,
          hint: const Text("Select ID Type"),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
          items: _additionalIdTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.replaceAll('_', ' ')),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAdditionalIdType = value;
            });
          },
          validator: (value) => value == null ? "ID Type is required" : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          "ID Number",
          _additionalIdNumberController,
          hint: "e.g. A12345678",
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () => _selectDate(_additionalIdIssueDateController),
          child: AbsorbPointer(
            child: _buildTextField(
              "Issue Date",
              _additionalIdIssueDateController,
              hint: "YYYY-MM-DD",
            ),
          ),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () => _selectDate(_additionalIdExpiryDateController),
          child: AbsorbPointer(
            child: _buildTextField(
              "Expiry Date",
              _additionalIdExpiryDateController,
              hint: "YYYY-MM-DD",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalIdFileStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upload ID Document",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          "A clear photo or PDF of your selected ID document.",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        SizedBox(height: 16.h),
        InkWell(
          onTap: _pickAdditionalIdFile,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
            decoration: BoxDecoration(
              border: Border.all(color: appTheme.primaryColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12.r),
              color: appTheme.primaryColor.withOpacity(0.05),
            ),
            child: Column(
              children: [
                Icon(
                  _additionalIdFile != null ? Icons.check_circle : Icons.upload_file,
                  color: _additionalIdFile != null ? Colors.green : appTheme.primaryColor,
                  size: 40.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  _additionalIdFile != null
                      ? "File Selected: ${_additionalIdFile!.path.split('/').last}"
                      : "Tap to upload ID Document (PDF, JPG, PNG)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: _additionalIdFile != null ? Colors.green : appTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
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
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator ?? (value) => value == null || value.isEmpty ? "$label is required" : null,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
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
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
          decoration: InputDecoration(
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
}