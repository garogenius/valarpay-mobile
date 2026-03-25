import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/features/models/flutterwave_bill_models.dart';
import 'package:valarpay/features/notifiers/flutterwave_bill_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';

class FlutterwaveBillingScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const FlutterwaveBillingScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<FlutterwaveBillingScreen> createState() => _FlutterwaveBillingScreenState();
}

class _FlutterwaveBillingScreenState extends ConsumerState<FlutterwaveBillingScreen> {
  int _currentStep = 0;
  FlutterwaveBiller? _selectedBiller;
  FlutterwaveProduct? _selectedProduct;
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  FlutterwaveCustomerValidation? _validationData;
  bool _isValidated = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Fetch categories first as requested
      await ref.read(flutterwaveCategoriesProvider.notifier).fetchCategories(isOverlayHidden: false);
      
      final categoriesState = ref.read(flutterwaveCategoriesProvider);
      if (categoriesState.isDataAvailable) {
        // 2. Clear previous billers and fetch new ones
        ref.read(flutterwaveBillersProvider.notifier).reset();
        ref.read(flutterwaveBillersProvider.notifier).fetchBillers(widget.categoryId, isOverlayHidden: false);
      }
    });
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onBillerSelected(FlutterwaveBiller biller) {
    setState(() {
      _selectedBiller = biller;
      _selectedProduct = null;
      _isValidated = false;
      _currentStep = 1;
      _searchController.clear();
    });
    ref.read(flutterwaveProductsProvider.notifier).fetchProducts(biller.billerCode, widget.categoryId, isOverlayHidden: false);
  }

  void _onProductSelected(FlutterwaveProduct product) {
    setState(() {
      _selectedProduct = product;
      _isValidated = false;
      _currentStep = 2;
      if (product.amount > 0) {
        _amountController.text = product.amount.toStringAsFixed(0);
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

    setState(() => _isVerifying = true);
    
    try {
      await ref.read(flutterwaveValidationProvider.notifier).validate(
        billPaymentProductId: _selectedProduct!.itemCode,
        customerId: _customerIdController.text.trim(),
        billerCode: _selectedBiller!.billerCode,
        isOverlayHidden: false,
      );

      final state = ref.read(flutterwaveValidationProvider);
      if (state.isDataAvailable && state.singleData != null) {
        setState(() {
          _validationData = state.singleData;
          _isValidated = true;
          if (_validationData!.maximum > 0 && _amountController.text.isEmpty) {
             // If product amount is 0 but validation returns a suggested amount or requirement
          }
        });
      } else {
        AppMessenger.show(context, message: state.message ?? 'Validation failed', type: MessageType.error);
      }
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _showConfirmationDetails() async {
    if (!_isValidated && (_selectedProduct?.isResolvable ?? false)) {
      await _validateCustomer();
      if (!_isValidated) return;
    }

    if (_amountController.text.isEmpty) {
      AppMessenger.show(context, message: 'Please enter amount', type: MessageType.error);
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final fee = _validationData?.fee ?? 0.0;
    final totalAmount = amount + fee;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReuseableTransactionDetailsScreen(
          topTitleText: 'Payment',
          totalAmount: totalAmount,
          saveBeneficiary: false,
          onSaveBeneficiaryChanged: (val) {},
          hasBottom: false,
          topTransactionsDetailsList: [
            buildDetailRow('Biller', _selectedBiller?.name ?? '', isDark),
            buildDetailRow('Product', _selectedProduct?.name ?? '', isDark),
            buildDetailRow('Customer ID', _customerIdController.text, isDark),
            if (_validationData?.name != null && _validationData!.name.isNotEmpty)
              buildDetailRow('Customer Name', _validationData!.name, isDark),
            buildDetailRow('Amount', currencyFormatter(amount.toString()), isDark),
            buildDetailRow('Fee', currencyFormatter(fee.toString()), isDark),
            const Divider(),
            buildDetailRow('Total Amount', currencyFormatter(totalAmount.toString()), isDark, isTotal: true),
          ],
          onButtonPressed: () => _handlePayment(biometric: false),
          onBiometricButtonPressed: () => _handlePayment(biometric: true),
        ),
      ),
    );
  }

  Future<void> _handlePayment({required bool biometric}) async {
    final pin = biometric
        ? await BiometricTransactionPinModal.show(context)
        : await TransactionPinModal.show(context);

    if (pin == null || pin.length != 4) return;

    if (!mounted) return;
    Navigator.pop(context); // Close confirmation screen

    final paymentRequest = FlutterwavePaymentRequest(
      itemCode: _selectedProduct!.itemCode,
      billerCode: _selectedBiller!.billerCode,
      amount: double.parse(_amountController.text.replaceAll(',', '')),
      currency: 'NGN',
      billerNumber: _customerIdController.text.trim(),
      walletPin: pin,
      category: widget.categoryId,
    );

    await ref.read(flutterwaveBillPaymentProvider.notifier).pay(paymentRequest, isOverlayHidden: false);

    final state = ref.read(flutterwaveBillPaymentProvider);
    if (state.isDataAvailable && state.singleData != null) {
      _navigateToReceipt(state.singleData!);
    } else {
      AppMessenger.show(context, message: state.message ?? 'Payment failed', type: MessageType.error);
    }
  }

  void _navigateToReceipt(FlutterwavePaymentResponse response) {
    final amount = _amountController.text;
    final fee = _validationData?.fee ?? 0.0;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionReceiptWidget(
          headerText: 'Payment Successful',
          amount: amount,
          topDetails: [
            TransactionDetail(label: 'Amount', value: currencyFormatter(amount)),
            TransactionDetail(label: 'Fee', value: currencyFormatter(fee.toString())),
            TransactionDetail(label: 'Status', value: 'SUCCESSFUL'),
          ],
          bottomDetails: [
            TransactionDetail(label: 'Biller', value: _selectedBiller?.name ?? ''),
            TransactionDetail(label: 'Product', value: _selectedProduct?.name ?? ''),
            TransactionDetail(label: 'Customer ID', value: _customerIdController.text),
            if (_validationData?.name != null && _validationData!.name.isNotEmpty)
              TransactionDetail(label: 'Customer Name', value: _validationData!.name),
            if (response.transactionRef != null)
              TransactionDetail(label: 'Transaction Ref', value: response.transactionRef!, showCopyIcon: true),
            TransactionDetail(label: 'Date', value: DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())),
          ],
          shareableDetails: [
            ShareableTransactionReceiptDetail(label: 'Biller', value: _selectedBiller?.name ?? ''),
            ShareableTransactionReceiptDetail(label: 'Product', value: _selectedProduct?.name ?? ''),
            ShareableTransactionReceiptDetail(label: 'Amount', value: currencyFormatter(amount)),
            ShareableTransactionReceiptDetail(label: 'Status', value: 'SUCCESSFUL', isSuccessful: true),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
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
        return _buildProductSelection();
      case 2:
        return _buildDetailsEntry();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBillerSelection() {
    final categoriesState = ref.watch(flutterwaveCategoriesProvider);
    final state = ref.watch(flutterwaveBillersProvider);

    // If categories failed
    if (categoriesState.message != null) {
      return _buildErrorWidget(
        title: 'Unable to Load Categories',
        message: categoriesState.message!,
        onRetry: _fetchInitialData,
      );
    }

    // If billers failed
    if (state.message != null) {
      return _buildErrorWidget(
        title: 'Unable to Load Billers',
        message: state.message!,
        onRetry: () => ref.read(flutterwaveBillersProvider.notifier).fetchBillers(widget.categoryId, isOverlayHidden: false),
      );
    }

    // loading check removed as GlobalLoadingOverlay is handled by the notifier
    
    final allBillers = state.data ?? [];
    final searchTerm = _searchController.text.toLowerCase();
    final billers = allBillers.where((b) => b.name.toLowerCase().contains(searchTerm)).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search billers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onChanged: (v) => setState(() {}),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: billers.length,
            itemBuilder: (context, index) {
              final biller = billers[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  title: Text(biller.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _onBillerSelected(biller),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductSelection() {
    final state = ref.watch(flutterwaveProductsProvider);
    if (state.message != null) {
      return _buildErrorWidget(
        title: 'Unable to Load Products',
        message: state.message!,
        onRetry: () => ref.read(flutterwaveProductsProvider.notifier).fetchProducts(_selectedBiller!.billerCode, widget.categoryId, isOverlayHidden: false),
      );
    }
    
    final allProducts = state.data ?? [];
    final searchTerm = _searchController.text.toLowerCase();
    final products = allProducts.where((p) => p.name.toLowerCase().contains(searchTerm)).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onChanged: (v) => setState(() {}),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  title: Text(product.name, style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: product.amount > 0 
                      ? Text(currencyFormatter(product.amount.toString()), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
                      : const Text('Enter Amount'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _onProductSelected(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsEntry() {
    final validationState = ref.watch(flutterwaveValidationProvider);
    final paymentState = ref.watch(flutterwaveBillPaymentProvider);

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
                const Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedBiller?.name ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      Text(_selectedProduct?.name ?? '', style: TextStyle(fontSize: 13.sp)),
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
              labelText: 'Customer ID / Reference',
              hintText: 'Enter account or meter number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              suffixIcon: (_selectedProduct?.isResolvable ?? false)
                  ? IconButton(
                          icon: Icon(Icons.check_circle, color: _isValidated ? Colors.green : Colors.orange),
                          onPressed: _validateCustomer,
                        )
                  : null,
            ),
            onChanged: (v) {
              if (_isValidated) setState(() => _isValidated = false);
            },
          ),
          if (_isValidated && _validationData != null && _validationData!.name.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.green),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Verified Customer', style: TextStyle(fontSize: 12.sp, color: Colors.green)),
                        Text(_validationData!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            isReadOnly: _selectedProduct?.amount != null && _selectedProduct!.amount > 0,
          ),
          if (_validationData != null && _validationData!.fee > 0)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text('Service Fee: ${currencyFormatter(_validationData!.fee.toString())}', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            ),
          SizedBox(height: 40.h),
          FullWidthButton(
            text: (_selectedProduct?.isResolvable ?? false) && !_isValidated ? 'Verify & Continue' : 'Continue',
            isLoading: paymentState.isInitialLoading || _isVerifying,
            onPressed: _showConfirmationDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget({required String title, required String message, required VoidCallback onRetry}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(24.w),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_off, color: Colors.red, size: 64.w),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            message.replaceAll('Exception: ', ''),
            style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white70 : Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Go Back', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
