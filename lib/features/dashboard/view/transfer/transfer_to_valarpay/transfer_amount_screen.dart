import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/check_balance.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/features/models/transfer_models.dart';
import 'package:valarpay/features/notifiers/transfer_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

import '../../../../../core/utils/logger.dart';

class InternalTransferAmountScreen extends ConsumerStatefulWidget {
  final AccountDetails accountDetails;
  InternalTransferAmountScreen({required this.accountDetails, super.key});

  @override
  ConsumerState<InternalTransferAmountScreen> createState() =>
      _InternalTransferAmountScreenState();
}

class _InternalTransferAmountScreenState
    extends ConsumerState<InternalTransferAmountScreen> {
  final NumberFormat _formatter = NumberFormat('#,###');

  TextEditingController _amountController = TextEditingController();
  TextEditingController _narrationController = TextEditingController();
  bool _isNotMinimumAmount = false;
  bool _saveBeneficiary = false;
  bool _loadingShown = false;
  late String _userFullname;
  late double _amount;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _amountController.addListener(() {
      final text = _amountController.text.replaceAll(',', '');
      if (text.isEmpty) return;

      // Prevent recursive updates
      final newText = _formatter.format(int.parse(text));
      if (newText != _amountController.text) {
        final cursorPos = newText.length;
        _amountController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: cursorPos),
        );
      }
      if (int.parse(text) < 100) {
        setState(() {
          _isNotMinimumAmount = true;
        });
      } else {
        setState(() {
          _isNotMinimumAmount = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _narrationController.dispose();
    super.dispose();
  }

  void _showLoading() {
    if (_loadingShown) return;
    _loadingShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => WillPopScope(
            onWillPop: () async => false,
            child: const Center(child: CircularProgressIndicator()),
          ),
    );
  }

  void _hideLoading() {
    if (!_loadingShown) return;
    _loadingShown = false;

    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _initiateTransfer(String pin, double amount) async {
    Navigator.pop(context); // Close pin modal

    _showLoading();

    try {
      AppLogger.log('🔐 Initiating ValarPay transfer with PIN...');
      AppLogger.log(
        '📤 Transfer details - Account: ${widget.accountDetails.accountNumber}, Amount: $amount',
      );
      await ref
          .read(transferNotifierProvider.notifier)
          .initiateTransfer(
            bankCode: '090672',
            accountNumber: widget.accountDetails.accountNumber,
            amount: amount,
            currency: 'NGN',
            description: _narrationController.text.trim(),
            pin: pin,
            saveBeneficiary: _saveBeneficiary,
            sessionId: widget.accountDetails.sessionId,
          );

      _hideLoading();

      if (!mounted) return;

      final state = ref.read(transferNotifierProvider);

      if (state.isDataAvailable &&
          state.data != null &&
          state.data!.isNotEmpty) {
        Navigator.pop(context);
        _navigateToReceipt();
      } else {
        final errorMessage =
            state.message ?? 'Transaction failed. Please try again.';

        final isIncorrectPin =
            errorMessage.toLowerCase().contains('incorrect pin') ||
            errorMessage.toLowerCase().contains('wrong pin') ||
            errorMessage.toLowerCase().contains('invalid pin') ||
            errorMessage.toLowerCase().contains('pin is incorrect');

        AppMessenger.show(
          context,
          message:
              isIncorrectPin
                  ? 'Incorrect PIN. Please try again.'
                  : errorMessage,
          type: MessageType.error,
        );
      }
    } catch (e) {
      _hideLoading();

      if (!mounted) return;

      // Check if the exception message indicates incorrect PIN
      final errorMessage = e.toString();
      final isIncorrectPin =
          errorMessage.toLowerCase().contains('incorrect pin') ||
          errorMessage.toLowerCase().contains('wrong pin') ||
          errorMessage.toLowerCase().contains('invalid pin') ||
          errorMessage.toLowerCase().contains('pin is incorrect');

      AppMessenger.show(
        context,
        message:
            isIncorrectPin
                ? 'Incorrect PIN. Please try again.'
                : 'An unexpected error occurred: $errorMessage',
        type: MessageType.error,
      );
    }
  }

  _handlePinEntry({bool biometric = false}) async {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final user = ref.watch(userProvider);
    final wallet =
        user?.wallets.isNotEmpty == true ? user!.wallets.first : null;
    final balance = wallet?.balance ?? 0.0;
    final hasEnoughBalance = checkBalanceLeft(
      context,
      balance.toString(),
      amount.toString(),
    );

    if (!hasEnoughBalance) return;
    final pin =
        biometric
            ? await BiometricTransactionPinModal.show(context)
            : await TransactionPinModal.show(context);

    if (pin != null && pin.length == 4) {
      // Ensure PIN is a string
      final pinString = pin.toString();
      Navigator.pop(context);
      if (mounted) {
        _initiateTransfer(pinString, amount);
      }
    } else {
      AppLogger.log('❌ PIN invalid or cancelled');
    }
  }

  _handleOnPressed() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReuseableTransactionDetailsScreen(
              totalAmount: double.parse(_amountController.text),
              hasBottom: false,
              saveBeneficiary: _saveBeneficiary,
              onSaveBeneficiaryChanged: (value) {
                setState(() {
                  _saveBeneficiary = value;
                });
              },
              topTitleText: 'Transaction',
              topTransactionsDetailsList: [
                buildDetailRow(
                  'Name',
                  widget.accountDetails.accountName,
                  isDark,
                ),
                buildDetailRow(
                  'Account Number',
                  widget.accountDetails.accountNumber,
                  isDark,
                ),
                buildDetailRow('Bank', 'ValarPay', isDark),
                buildDetailRow(
                  'Amount',
                  currencyFormatter(_amountController.text),
                  isDark,
                ),
              ],
              onButtonPressed: () => _handlePinEntry(biometric: false),
              onBiometricButtonPressed: () => _handlePinEntry(biometric: true),
              onAutomaticallyShowBiometric:
                  () => _handlePinEntry(biometric: true),
            ),
      ),
    );
  }

  void _navigateToReceipt() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) {
        return;
      }

      final transferAmount =
          double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      final receiptData = [
        ShareableTransactionReceiptDetail(
          label: 'Amount',
          value: currencyFormatter(_amount.toString()),
        ),
        ShareableTransactionReceiptDetail(label: 'Currency', value: 'NGN'),
        ShareableTransactionReceiptDetail(
          label: 'Transaction Type',
          value: 'Intra-bank Transfer',
        ),
        ShareableTransactionReceiptDetail(
          label: 'Sender Name',
          value: _userFullname,
        ),
        ShareableTransactionReceiptDetail(
          label: 'Beneficiary Details',
          value:
              '${widget.accountDetails.accountName} \n${widget.accountDetails.accountNumber}',
        ),
        ShareableTransactionReceiptDetail(
          label: 'Beneficiary Bank',
          value: 'ValarPay',
        ),
        if (_narrationController.text.isNotEmpty)
          ShareableTransactionReceiptDetail(
            label: 'Narration',
            value: _narrationController.text,
          ),
        ShareableTransactionReceiptDetail(
          label: 'Transaction ID',
          value: widget.accountDetails.sessionId,
        ),
        ShareableTransactionReceiptDetail(
          label: 'Status',
          value: 'Successful',
          isSuccessful: true,
        ),
      ];
      final now = DateTime.now();
      final receiptDate =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} | ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => TransactionReceiptWidget(
                headerText: 'Transfer',
                amount: currencyFormatter(transferAmount.toString()),
                topDetails: [
                  TransactionDetail(
                    label: 'Transaction ID',
                    value: widget.accountDetails.sessionId,
                    showCopyIcon: true,
                  ),
                  TransactionDetail(
                    label: 'Recipient Name',
                    value: widget.accountDetails.accountName,
                  ),
                  TransactionDetail(
                    label: 'Recipient Account',
                    value: widget.accountDetails.accountNumber,
                  ),
                  TransactionDetail(label: 'Bank', value: 'ValarPay'),
                  TransactionDetail(
                    label: 'Amount',
                    value: currencyFormatter(transferAmount.toString()),
                  ),
                  if (_narrationController.text.trim().isNotEmpty)
                    TransactionDetail(
                      label: 'Narration',
                      value: _narrationController.text.trim(),
                    ),
                ],
                shareableDetails: receiptData,
                receiptDate: receiptDate,
              ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.read(userProvider);
    _userFullname = user?.fullname ?? '';
    _amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Transfer to ValarPay Account',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor:
                        isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFF3F4F6),
                    child: ClipOval(
                      child: Icon(
                        Icons.person,
                        size: 24.r,
                        color:
                            isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.accountDetails.accountName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${widget.accountDetails.accountNumber}   ValarPay',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40.h),

              // Amount Field
              Text(
                'Amount',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 8.h),
              ReuseableAmountTextfield(
                amountController: _amountController,
                prefixText: '₦',
                hintText: 'Enter Amount',
              ),
              if (_isNotMinimumAmount) SizedBox(height: 5),
              if (_isNotMinimumAmount)
                Text(
                  'Minimum transfer amount is ₦100',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),

              SizedBox(height: 25.h),

              // Narration Field
              Text(
                'Narration (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
                  hintText: 'Enter narration',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: appTheme.primaryColor,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50.h),

              // Continue Button
              FullWidthButton(
                text: 'Continue',
                isEnabled:
                    _amountController.text.isNotEmpty &&
                    int.parse(_amountController.text.replaceAll(',', '')) >=
                        100,
                onPressed: () {
                  _handleOnPressed();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
