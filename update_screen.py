import re

file_path = 'lib/features/dashboard/view/account/account_setup_screen.dart'

with open(file_path, 'r') as f:
    content = f.read()

# Replace _hasMissingInfo handling
new_build = """
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

"""

start_str = "  @override\n  Widget build(BuildContext context) {"
end_str = "  Widget _buildProfileUpdateForm() {"

idx_start = content.find(start_str)
idx_end = content.find(end_str)

new_content = content[:idx_start] + new_build + content[idx_end:]

# We also need to remove _buildProfileUpdateForm entirely because we aren't using it anymore
# But wait, we still use _buildTextFormField. So we should keep _buildTextFormField, but remove _buildProfileUpdateForm.
# Actually, I can just let _buildProfileUpdateForm remain there unused to avoid risking syntax errors.

# Let's fix the `_handleProceed` method to pass `_phoneNumber` etc.
handle_proceed_old = """      await ref.read(walletNotifierProvider.notifier).createMultiCurrencyAccount(
        currency: widget.accountType,
        label: _labelController.text,
        utilityBillPath: _utilityBillFile?.path,
        incomeBand: _requiresUtilityBill ? _incomeBandController.text.trim() : null,"""

handle_proceed_new = """      await ref.read(walletNotifierProvider.notifier).createMultiCurrencyAccount(
        currency: widget.accountType,
        label: _labelController.text,
        phoneNumber: _phoneNumber,
        address: _address,
        city: _city,
        state: _state,
        postalCode: _postalCode,
        bvn: _bvn,
        utilityBillPath: _utilityBillFile?.path,
        incomeBand: _requiresUtilityBill ? _incomeBandController.text.trim() : null,"""

new_content = new_content.replace(handle_proceed_old, handle_proceed_new)

with open(file_path, 'w') as f:
    f.write(new_content)

print("Replaced content successfully.")
