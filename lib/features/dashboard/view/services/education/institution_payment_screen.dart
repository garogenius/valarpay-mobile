import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/features/models/education_models.dart';
import 'package:valarpay/features/notifiers/education_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/themes/color_utils.dart';

class InstitutionPaymentScreen extends ConsumerStatefulWidget {
  final EducationBiller biller;

  const InstitutionPaymentScreen({super.key, required this.biller});

  @override
  ConsumerState<InstitutionPaymentScreen> createState() => _InstitutionPaymentScreenState();
}

class _InstitutionPaymentScreenState extends ConsumerState<InstitutionPaymentScreen> {
  final studentIdController = TextEditingController();
  final amountController = TextEditingController();
  EducationProduct? _selectedProduct;
  EducationVerificationResponse? _verificationResult;
  bool saveBeneficiary = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.biller.category == 'vending') {
        ref.read(educationProductsProvider.notifier).fetchVendingProducts(widget.biller.billerId);
      } else {
        ref.read(educationProductsProvider.notifier).fetchBillerItems(widget.biller.billerId);
      }
    });
  }

  @override
  void dispose() {
    studentIdController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (studentIdController.text.isEmpty || _selectedProduct == null) {
      AppMessenger.show(context, message: 'Please fill all fields', type: MessageType.error);
      return;
    }

    // Verify customer first
    try {
      if (widget.biller.billerId.toLowerCase() == 'waec') {
        await ref.read(educationVerificationProvider.notifier).verifyWaec(
          itemCode: _selectedProduct!.id,
          billerNumber: studentIdController.text.trim(),
        );
      } else if (widget.biller.billerId.toLowerCase() == 'jamb') {
        await ref.read(educationVerificationProvider.notifier).verifyJamb(
          itemCode: _selectedProduct!.id,
          billerNumber: studentIdController.text.trim(),
        );
      } else {
        await ref.read(educationVerificationProvider.notifier).verifySchoolCustomer(
          itemCode: _selectedProduct!.id,
          billerCode: widget.biller.billerId,
          billerNumber: studentIdController.text.trim(),
        );
      }

      if (!mounted) return;

      final verifyState = ref.read(educationVerificationProvider);
      if (verifyState.isDataAvailable) {
        _verificationResult = verifyState.data!.first;
        _navigateToDetails();
      } else {
        AppMessenger.show(context, message: verifyState.message ?? 'Verification failed', type: MessageType.error);
      }
    } catch (e) {
      if (!mounted) return;
      AppMessenger.show(context, message: e.toString(), type: MessageType.error);
    }
  }

  void _navigateToDetails() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finalAmount = _selectedProduct!.amount > 0 ? _selectedProduct!.amount : double.tryParse(amountController.text) ?? 0;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReuseableTransactionDetailsScreen(
          totalAmount: finalAmount,
          saveBeneficiary: saveBeneficiary,
          onSaveBeneficiaryChanged: (v) => setState(() => saveBeneficiary = v),
          hasBottom: false,
          topTitleText: 'Education Payment',
          topTransactionsDetailsList: [
            buildDetailRow('Institution/Provider', widget.biller.billerName, isDark),
            buildDetailRow('Service', _selectedProduct!.name, isDark),
            buildDetailRow('Candidate/Student', _verificationResult!.customerName, isDark),
            buildDetailRow('Number', _verificationResult!.billerNumber, isDark),
            buildDetailRow('Amount', currencyFormatter(finalAmount.toString()), isDark),
          ],
          onButtonPressed: () => _handlePayment(biometric: false),
          onBiometricButtonPressed: () => _handlePayment(biometric: true),
          onAutomaticallyShowBiometric: () => _handlePayment(biometric: true),
        ),
      ),
    );
  }

  Future<void> _handlePayment({bool biometric = false}) async {
    final pin = biometric
        ? await BiometricTransactionPinModal.show(context)
        : await TransactionPinModal.show(context);

    if (pin == null || pin.length != 4) return;

    if (!mounted) return;
    Navigator.pop(context); // Close details screen

    try {
      final request = EducationPaymentRequest(
        itemCode: _selectedProduct!.id,
        billerCode: widget.biller.billerId,
        billerNumber: studentIdController.text.trim(),
        amount: _selectedProduct!.amount > 0 ? _selectedProduct!.amount : double.parse(amountController.text),
        walletPin: pin,
        addBeneficiary: saveBeneficiary,
      );

      if (widget.biller.billerId.toLowerCase() == 'waec') {
        await ref.read(educationPurchaseProvider.notifier).payWaec(request);
      } else if (widget.biller.billerId.toLowerCase() == 'jamb') {
        await ref.read(educationPurchaseProvider.notifier).payJamb(request);
      } else {
        await ref.read(educationPurchaseProvider.notifier).paySchoolFees(request);
      }
      
      if (!mounted) return;

      final purchaseState = ref.read(educationPurchaseProvider);
      if (purchaseState.isDataAvailable) {
        _navigateToReceipt(purchaseState.data!.first);
      } else {
        AppMessenger.show(context, message: purchaseState.message ?? 'Payment failed', type: MessageType.error);
      }
    } catch (e) {
      if (!mounted) return;
      AppMessenger.show(context, message: e.toString(), type: MessageType.error);
    }
  }

  void _navigateToReceipt(EducationPaymentResponse response) {
    final now = DateTime.now();
    final receiptData = [
      ShareableTransactionReceiptDetail(label: 'Institution', value: widget.biller.billerName),
      ShareableTransactionReceiptDetail(label: 'Service', value: _selectedProduct!.name),
      ShareableTransactionReceiptDetail(label: 'Amount Paid', value: currencyFormatter(response.amount.toString())),
      ShareableTransactionReceiptDetail(label: 'Ref', value: response.transactionRef),
      ShareableTransactionReceiptDetail(label: 'Identifier', value: response.studentNumber ?? response.registrationNumber ?? response.candidateNumber ?? ''),
      ShareableTransactionReceiptDetail(label: 'Status', value: 'Successful', isSuccessful: true),
    ];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionReceiptWidget(
          headerText: 'Payment Successful',
          amount: currencyFormatter(response.amount.toString()),
          topDetails: [
            TransactionDetail(label: 'Transaction ID', value: response.transactionRef, showCopyIcon: true),
            TransactionDetail(label: 'Institution', value: widget.biller.billerName),
            TransactionDetail(label: 'Service', value: _selectedProduct!.name),
          ],
          shareableDetails: receiptData,
          receiptDate: '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productsState = ref.watch(educationProductsProvider);
    final products = productsState.data ?? [];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.biller.billerName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Select Service', isDark),
            GestureDetector(
              onTap: productsState.isInitialLoading ? null : () => _showServiceModal(context, products),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                              _selectedProduct == null 
                                  ? 'Choose product' 
                                  : '${_selectedProduct!.name} - ${currencyFormatter(_selectedProduct!.amount.toString())}',
                              style: TextStyle(
                                color: _selectedProduct == null 
                                    ? (isDark ? Colors.white38 : Colors.grey) 
                                    : (isDark ? Colors.white : Colors.black),
                                fontSize: 16,
                                fontWeight: _selectedProduct == null ? FontWeight.normal : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down, 
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel(
              widget.biller.billerId.toLowerCase() == 'waec' 
                ? 'Examination/Candidate Number' 
                : widget.biller.billerId.toLowerCase() == 'jamb'
                ? 'Registration Number'
                : 'Student ID / Matric Number', 
              isDark
            ),
            TextField(
              controller: studentIdController,
              decoration: _inputDecoration('Enter number', isDark),
            ),
            const SizedBox(height: 24),
            if (_selectedProduct != null && _selectedProduct!.amount <= 0) ...[
              _buildLabel('Amount (₦)', isDark),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Enter amount', isDark),
              ),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 48),
            FullWidthButton(
              text: 'Continue',
              onPressed: _handleContinue,
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceModal(BuildContext context, List<EducationProduct> products) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Service',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1, 
                    indent: 16, 
                    endIndent: 16,
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  ),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    final isSelected = _selectedProduct?.id == p.id;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedProduct = p;
                          if (p.amount > 0) {
                            amountController.text = p.amount.toString();
                          } else {
                            amountController.text = '';
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormatter(p.amount.toString()),
                                    style: const TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: AppColors.primaryColor),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87)),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
