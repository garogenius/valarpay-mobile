import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart'; // Using the filename correctly
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/features/models/remita_models.dart';
import 'package:valarpay/features/notifiers/remita_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';

class RemitaBillingScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const RemitaBillingScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<RemitaBillingScreen> createState() => _RemitaBillingScreenState();
}

class _RemitaBillingScreenState extends ConsumerState<RemitaBillingScreen> {
  int _currentStep = 0;
  RemitaBiller? _selectedBiller;
  RemitaProduct? _selectedProduct;
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};
  
  RemitaCustomerValidation? _validationData;
  bool _isValidated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(remitaBillersProvider.notifier).fetchBillers(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _amountController.dispose();
    _customFieldControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _onBillerSelected(RemitaBiller biller) {
    setState(() {
      _selectedBiller = biller;
      _selectedProduct = null;
      _isValidated = false;
      _currentStep = 1;
    });
    ref.read(remitaProductsProvider.notifier).fetchProducts(biller.billerId);
  }

  void _onProductSelected(RemitaProduct product) {
    setState(() {
      _selectedProduct = product;
      _isValidated = false;
      _currentStep = 2;
      _customFieldControllers.clear();
      if (product.customFields != null) {
        for (var field in product.customFields!) {
          _customFieldControllers[field.variableName] = TextEditingController();
        }
      }
      if (product.amount != null && product.amount! > 0) {
        _amountController.text = product.amount!.toStringAsFixed(0);
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

    await ref.read(remitaValidationProvider.notifier).validate(
      billPaymentProductId: _selectedProduct!.billPaymentProductId,
      customerId: _customerIdController.text.trim(),
    );

    final state = ref.read(remitaValidationProvider);
    if (state.isDataAvailable && state.singleData != null) {
      setState(() {
        _validationData = state.singleData;
        _isValidated = true;
      });
      if (_validationData!.minimumAmount != null && _validationData!.minimumAmount! > 0) {
        if (_amountController.text.isEmpty) {
          _amountController.text = _validationData!.minimumAmount!.toStringAsFixed(0);
        }
      }
    } else {
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

    final user = ref.read(userProvider);
    Map<String, dynamic>? metadata;
    if (_selectedProduct!.customFields != null && _selectedProduct!.customFields!.isNotEmpty) {
      final customFields = <Map<String, dynamic>>[];
      for (var field in _selectedProduct!.customFields!) {
        customFields.add({
          'variable_name': field.variableName,
          'value': _customFieldControllers[field.variableName]?.text ?? '',
        });
      }
      metadata = {'customFields': customFields};
    }

    final initiateRequest = RemitaInitiateRequest(
      billPaymentProductId: _selectedProduct!.billPaymentProductId,
      amount: double.parse(_amountController.text.replaceAll(',', '')),
      name: _validationData?.customerName ?? user?.fullName ?? 'ValarPay User',
      paymentIdentifier: DateTime.now().millisecondsSinceEpoch.toString(),
      email: user?.email ?? 'support@valarpay.com',
      phoneNumber: user?.phoneNumber ?? '',
      customerId: _customerIdController.text.trim(),
      metadata: metadata,
    );

    final initiationResponse = await ref.read(remitaPaymentProvider.notifier).initiate(initiateRequest);

    if (initiationResponse != null) {
      _showPinModal(initiationResponse);
    } else {
      final state = ref.read(remitaPaymentProvider);
      AppMessenger.show(context, message: state.message ?? 'Initiation failed', type: MessageType.error);
    }
  }

  Future<void> _showPinModal(RemitaInitiationResponse initiation) async {
    final pin = await TransactionPinModal.show(context);
    if (pin != null && pin.length == 4) {
      _completePayment(initiation, pin);
    }
  }

  Future<void> _completePayment(RemitaInitiationResponse initiation, String pin) async {
    final paymentRequest = RemitaPaymentRequest(
      rrr: initiation.rrr,
      paymentIdentifier: initiation.paymentIdentifier,
      amount: initiation.amount,
      walletPin: pin,
    );

    await ref.read(remitaPaymentProvider.notifier).pay(paymentRequest);

    final state = ref.read(remitaPaymentProvider);
    if (state.isDataAvailable && state.singleData != null) {
      _navigateToReceipt(state.singleData!);
    } else {
      AppMessenger.show(context, message: state.message ?? 'Payment failed', type: MessageType.error);
    }
  }

  void _navigateToReceipt(RemitaPaymentResponse response) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionReceiptWidget(
          headerText: 'Payment Successful',
          amount: response.amount.toString(),
          topDetails: [
            TransactionDetail(label: 'RRR', value: response.rrr, showCopyIcon: true),
            TransactionDetail(label: 'Amount', value: currencyFormatter(response.amount.toString())),
            TransactionDetail(label: 'Status', value: response.transactionStatus),
          ],
          bottomDetails: [
            TransactionDetail(label: 'Biller', value: _selectedBiller?.billerName ?? ''),
            TransactionDetail(label: 'Product', value: _selectedProduct?.billPaymentProductName ?? ''),
            TransactionDetail(label: 'Customer ID', value: _customerIdController.text),
            TransactionDetail(label: 'Customer Name', value: _validationData?.customerName ?? ''),
            TransactionDetail(label: 'Transaction Ref', value: response.transactionRef, showCopyIcon: true),
            TransactionDetail(label: 'Date', value: DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())),
          ],
          shareableDetails: [
            ShareableTransactionReceiptDetail(label: 'Biller', value: _selectedBiller?.billerName ?? ''),
            ShareableTransactionReceiptDetail(label: 'Product', value: _selectedProduct?.billPaymentProductName ?? ''),
            ShareableTransactionReceiptDetail(label: 'RRR', value: response.rrr),
            ShareableTransactionReceiptDetail(label: 'Amount', value: currencyFormatter(response.amount.toString())),
            ShareableTransactionReceiptDetail(label: 'Status', value: 'SUCCESSFUL', isSuccessful: true),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
    final state = ref.watch(remitaBillersProvider);
    if (state.isInitialLoading) return const SizedBox.shrink();
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
            leading: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: biller.billerLogoUrl != null 
                    ? Image.network(biller.billerLogoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.business))
                    : const Icon(Icons.business),
              ),
            ),
            title: Text(biller.billerName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _onBillerSelected(biller),
          ),
        );
      },
    );
  }

  Widget _buildProductSelection() {
    final state = ref.watch(remitaProductsProvider);
    if (state.isInitialLoading) return const SizedBox.shrink();
    if (state.message != null) return Center(child: Text(state.message!, style: const TextStyle(color: Colors.red)));
    final products = state.data ?? [];

    if (products.isEmpty && !state.isInitialLoading) {
      return const Center(child: Text('No products found for this biller.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Select Product from ${_selectedBiller?.billerName}',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
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
                  title: Text(product.billPaymentProductName, style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: product.amount != null && product.amount! > 0 
                      ? Text(currencyFormatter(product.amount!.toString()), style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
                      : const Text('Flat Rate / Enter Amount'),
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
    final validationState = ref.watch(remitaValidationProvider);
    final paymentState = ref.watch(remitaPaymentProvider);

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
                      Text(_selectedBiller?.billerName ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      Text(_selectedProduct?.billPaymentProductName ?? '', style: TextStyle(fontSize: 13.sp)),
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
              labelText: 'ID Number',
              hintText: 'Enter Customer ID / Reference',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              suffixIcon: validationState.isInitialLoading 
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.orange),
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
                        Text(_validationData!.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 20.h),
          if (_selectedProduct?.customFields != null)
            ..._selectedProduct!.customFields!.map((field) {
              return Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: TextFormField(
                  controller: _customFieldControllers[field.variableName],
                  decoration: InputDecoration(
                    labelText: field.displayName,
                    hintText: 'Enter ${field.displayName}',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              );
            }).toList(),
          SizedBox(height: 8.h),
          ReuseableAmountTextfield(
            amountController: _amountController,
            prefixText: '₦',
            hintText: '0.00',
            isReadOnly: _selectedProduct?.isAmountFixed ?? false,
          ),
          if (_validationData?.minimumAmount != null && _validationData!.minimumAmount! > 0)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text('Minimum payable amount: ${currencyFormatter(_validationData!.minimumAmount!.toString())}', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            ),
          SizedBox(height: 40.h),
          FullWidthButton(
            text: _isValidated ? 'Proceed to Payment' : 'Validate & Continue',
            isLoading: paymentState.isInitialLoading,
            onPressed: _initiatePayment,
          ),
        ],
      ),
    );
  }
}
