import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/features/models/coralpay_models.dart';
import 'package:valarpay/features/notifiers/coralpay_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'coralpay_success_screen.dart';

class CoralPayBillingScreen extends ConsumerStatefulWidget {
  final String groupSlug;
  final String groupName;

  const CoralPayBillingScreen({
    super.key,
    required this.groupSlug,
    required this.groupName,
  });

  @override
  ConsumerState<CoralPayBillingScreen> createState() => _CoralPayBillingScreenState();
}

class _CoralPayBillingScreenState extends ConsumerState<CoralPayBillingScreen> {
  int _currentStep = 0;
  CoralPayBiller? _selectedBiller;
  CoralPayPackage? _selectedPackage;
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  CoralPayCustomerVerification? _validationData;
  bool _isValidated = false;

  @override
  void initState() {
    super.initState();
    _customerIdController.addListener(_onCustomerIdChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if a biller was passed as extra
      final extraBiller = GoRouterState.of(context).extra as CoralPayBiller?;
      if (extraBiller != null) {
        setState(() {
          _selectedBiller = extraBiller;
          _currentStep = 1;
        });
        ref.read(coralPayPackagesProvider.notifier).fetchPackages(extraBiller.slug);
      } else {
        ref.read(coralPayBillersProvider.notifier).fetchBillers(widget.groupSlug);
      }
    });
  }

  void _onCustomerIdChanged() {
    final text = _customerIdController.text.trim();
    // Automatically trigger validation when 10 digits are entered (common for most utilities)
    // or if the user stops typing (we can use a short timer if needed, but 10 digits is often enough)
    if (text.length >= 10 && !_isValidated && !ref.read(coralPayVerificationProvider).isInitialLoading) {
      _validateCustomer();
    }
  }

  @override
  void dispose() {
    _customerIdController.removeListener(_onCustomerIdChanged);
    _customerIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onBillerSelected(CoralPayBiller biller) {
    setState(() {
      _selectedBiller = biller;
      _selectedPackage = null;
      _isValidated = false;
      _currentStep = 1;
    });
    ref.read(coralPayPackagesProvider.notifier).fetchPackages(biller.slug);
  }

  void _onPackageSelected(CoralPayPackage package) {
    setState(() {
      _selectedPackage = package;
      _isValidated = false;
      _currentStep = 2;
      if (package.amount > 0) {
        _amountController.text = package.amount.toStringAsFixed(0);
      } else {
        _amountController.clear();
      }
    });
  }

  Future<void> _validateCustomer() async {
    if (_customerIdController.text.isEmpty) {
      AppMessenger.show(context, message: 'Please enter customer ID', type: MessageType.error);
      return;
    }

    final success = await ref.read(coralPayVerificationProvider.notifier).verify(
      customerId: _customerIdController.text.trim(),
      billerSlug: _selectedBiller!.slug,
      productName: _selectedPackage!.slug,
    );

    if (success) {
      final state = ref.read(coralPayVerificationProvider);
      setState(() {
        _validationData = state.singleData;
        _isValidated = true;
      });
      if (_validationData!.minAmount != null && _validationData!.minAmount! > 0) {
        if (_amountController.text.isEmpty) {
          _amountController.text = _validationData!.minAmount!.toStringAsFixed(0);
        }
      }
    } else {
      final state = ref.read(coralPayVerificationProvider);
      AppMessenger.show(context, message: state.message ?? 'Validation failed', type: MessageType.error);
    }
  }

  Future<void> _initiatePayment() async {
    if (!_isValidated) {
      await _validateCustomer();
      if (!_isValidated) return;
    }

    if (_amountController.text.isEmpty) {
      AppMessenger.show(context, message: 'Please enter amount', type: MessageType.error);
      return;
    }

    final pin = await TransactionPinModal.show(context);
    if (pin != null && pin.length == 4) {
      _completePayment(pin);
    }
  }

  Future<void> _completePayment(String pin) async {
    final user = ref.read(userProvider);
    final paymentRequest = CoralPayPaymentRequest(
      customerId: _customerIdController.text.trim(),
      billerSlug: _selectedBiller!.slug,
      packageSlug: _selectedPackage!.slug,
      amount: double.parse(_amountController.text.replaceAll(',', '')),
      customerName: _validationData?.customerName ?? user?.fullName ?? 'ValarPay User',
      walletPin: pin,
    );

    final success = await ref.read(coralPayPaymentProvider.notifier).pay(paymentRequest);

    if (success) {
      final state = ref.read(coralPayPaymentProvider);
      _navigateToSuccess(state.singleData!);
    } else {
      final state = ref.read(coralPayPaymentProvider);
      AppMessenger.show(context, message: state.message ?? 'Payment failed', type: MessageType.error);
    }
  }

  void _navigateToSuccess(CoralPayPaymentResponse response) {
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(now);
    
    final topDetails = [
      TransactionDetail(label: 'Ref', value: response.paymentReference ?? 'N/A', showCopyIcon: true),
      TransactionDetail(label: 'Amount', value: currencyFormatter(_amountController.text)),
      TransactionDetail(label: 'Status', value: 'SUCCESSFUL'),
      TransactionDetail(label: 'Date', value: dateStr),
    ];

    final bottomDetails = [
      TransactionDetail(label: 'Biller', value: _selectedBiller?.name ?? ''),
      TransactionDetail(label: 'Package', value: _selectedPackage?.name ?? ''),
      TransactionDetail(label: 'Customer ID', value: _customerIdController.text),
      TransactionDetail(label: 'Customer Name', value: _validationData?.customerName ?? ''),
      TransactionDetail(label: 'Transaction ID', value: response.transactionId ?? 'N/A', showCopyIcon: true),
    ];

    final shareableDetails = [
      ShareableTransactionReceiptDetail(label: 'Biller', value: _selectedBiller?.name ?? ''),
      ShareableTransactionReceiptDetail(label: 'Package', value: _selectedPackage?.name ?? ''),
      ShareableTransactionReceiptDetail(label: 'Amount', value: currencyFormatter(_amountController.text)),
      ShareableTransactionReceiptDetail(label: 'Status', value: 'SUCCESSFUL', isSuccessful: true),
    ];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CoralPaySuccessScreen(
          amount: _amountController.text,
          topDetails: topDetails,
          bottomDetails: bottomDetails,
          shareableDetails: shareableDetails,
        ),
      ),
    );
  }

  String _getCustomerIdLabel() {
    switch (widget.groupSlug) {
      case 'PAY_TV':
        return 'Smartcard Number';
      case 'COLLECTIONS':
        return 'Phone Number / Email / Reference';
      case 'TRANSPORT_AND_TOLL_PAYMENT':
        return 'Driver ID / Account Number';
      case 'ELECTRIC_DISCO':
        return 'Meter Number';
      default:
        return 'ID / Account Number';
    }
  }

  String _getCustomerIdHint() {
    switch (widget.groupSlug) {
      case 'PAY_TV':
        return 'Enter Smartcard Number';
      case 'COLLECTIONS':
        return 'Enter Reference or Contact Details';
      case 'TRANSPORT_AND_TOLL_PAYMENT':
        return 'Enter Driver ID or Reference';
      case 'ELECTRIC_DISCO':
        return 'Enter Meter Number';
      default:
        return 'Enter Customer ID / Reference';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: _buildStepContent(),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBillerSelection();
      case 1:
        return _buildPackageSelection();
      case 2:
        return _buildDetailsEntry();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBillerSelection() {
    final state = ref.watch(coralPayBillersProvider);
    // Removed redundant loader as GlobalLoadingOverlay handles it

    if (state.message != null) return Center(child: Padding(
      padding: EdgeInsets.all(20.w),
      child: Text(state.message!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
    ));
    final billers = state.data ?? [];

    if (billers.isEmpty && !state.isInitialLoading) {
      return const Center(child: Text('No billers found for this category.'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: billers.length,
      itemBuilder: (context, index) {
        final biller = billers[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            leading: b_buildBillerImage(biller.logoUrl, biller.name),
            title: Text(biller.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _onBillerSelected(biller),
          ),
        );
      },
    );
  }

  Widget b_buildBillerImage(String? logoUrl, String name) {
    String? localAsset;
    final normalizedName = name.toLowerCase();
    
    if (normalizedName.contains('dstv')) {
      localAsset = 'assets/images/dstv.png';
    } else if (normalizedName.contains('gotv')) {
      localAsset = 'assets/images/gotv.png';
    } else if (normalizedName.contains('startimes')) {
      localAsset = 'assets/images/startimes.png';
    } else if (normalizedName.contains('showmax')) {
      localAsset = 'assets/images/showmax.png';
    } else if (normalizedName.contains('waec')) {
      localAsset = 'assets/images/waec.png';
    } else if (normalizedName.contains('jamb')) {
      localAsset = 'assets/images/jamb.png';
    }

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipOval(
        child: localAsset != null 
            ? Image.asset(localAsset, fit: BoxFit.cover)
            : (logoUrl != null && logoUrl.isNotEmpty
                ? Image.network(logoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.business))
                : const Icon(Icons.business)),
      ),
    );
  }

  Widget _buildPackageSelection() {
    final state = ref.watch(coralPayPackagesProvider);
    // Removed redundant loader as GlobalLoadingOverlay handles it

    if (state.message != null) return Center(child: Text(state.message!, style: const TextStyle(color: Colors.red)));
    final packages = state.data ?? [];

    if (packages.isEmpty && !state.isInitialLoading) {
      return const Center(child: Text('No packages found for this biller.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Select Package from ${_selectedBiller?.name}',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  title: Text(package.name, style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: package.amount > 0 
                      ? Text(currencyFormatter(package.amount.toString()), style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
                      : const Text('Flat Rate / Enter Amount'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _onPackageSelected(package),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsEntry() {
    final verificationState = ref.watch(coralPayVerificationProvider);
    final paymentState = ref.watch(coralPayPaymentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                if (_selectedBiller != null)
                  b_buildBillerImage(_selectedBiller!.logoUrl, _selectedBiller!.name),
                if (_selectedBiller == null)
                  const Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedBiller?.name ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      Text(_selectedPackage?.name ?? '', style: TextStyle(fontSize: 13.sp)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Payment Details',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _customerIdController,
            decoration: InputDecoration(
              labelText: _getCustomerIdLabel(),
              hintText: _getCustomerIdHint(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              suffixIcon: IconButton(
                icon: Icon(Icons.check_circle, color: _isValidated ? Colors.green : Colors.grey),
                onPressed: _validateCustomer,
              ),
            ),
            onChanged: (v) {
              if (_isValidated) setState(() => _isValidated = false);
            },
          ),
          if (_isValidated && _validationData != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: Colors.green, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Verified Customer', style: TextStyle(fontSize: 12.sp, color: Colors.green, fontWeight: FontWeight.w500)),
                        SizedBox(height: 2.h),
                        Text(
                          _validationData!.customerName.toUpperCase(), 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: isDark ? Colors.white : Colors.black)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 20.h),
          ReuseableAmountTextfield(
            amountController: _amountController,
            prefixText: '₦',
            hintText: '0.00',
            isReadOnly: _selectedPackage?.isAmountFixed ?? false,
          ),
          if (_validationData?.minAmount != null && _validationData!.minAmount! > 0)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text('Minimum payable amount: ${currencyFormatter(_validationData!.minAmount!.toString())}', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            ),
          SizedBox(height: 40.h),
          FullWidthButton(
            text: _isValidated ? 'Proceed to Payment' : 'Validate & Continue',
            onPressed: _initiatePayment,
          ),
        ],
      ),
    );
  }
}
