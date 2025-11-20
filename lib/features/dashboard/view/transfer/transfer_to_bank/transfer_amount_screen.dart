import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/check_balance.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/utils/helpers.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/features/models/transfer_models.dart';
import 'package:valarpay/features/notifiers/transfer_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class TransferAmountScreen extends ConsumerStatefulWidget {
  final Bank selectedBank;
  final AccountDetails accountDetails;

  const TransferAmountScreen({
    super.key,
    required this.selectedBank,
    required this.accountDetails,
  });

  @override
  ConsumerState<TransferAmountScreen> createState() =>
      _TransferAmountScreenState();
}

class _TransferAmountScreenState extends ConsumerState<TransferAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  final NumberFormat _formatter = NumberFormat('#,###');
  final TextEditingController _descriptionController = TextEditingController();
  TransferFee? _transferFee;
  bool _isLoadingFee = false;
  bool _isNotMinimumAmount = false;
  bool _saveBeneficiary = false;
  bool _loadingShown = false;
  late String _userFullname;
  late double _amount;
  late double _totalAmount;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      _onAmountChanged();
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

    // Setup listener for transfer fee updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.listenManual(transferFeeNotifierProvider, (previous, next) {
          if (next.isDataAvailable &&
              next.data != null &&
              next.data!.isNotEmpty) {
            if (mounted) {
              setState(() {
                _transferFee = next.data!.first;
              });
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount != null && amount > 0) {
      _getTransferFee(amount);
    } else {
      setState(() {
        _transferFee = null;
      });
    }
  }

  void _getTransferFee(double amount) async {
    setState(() {
      _isLoadingFee = true;
    });

    try {
      await ref
          .read(transferFeeNotifierProvider.notifier)
          .getTransferFee(currency: 'NGN', amount: amount);
    } catch (e) {
      // Error handling is done in the listener
    } finally {
      setState(() {
        _isLoadingFee = false;
      });
    }
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
      await ref
          .read(transferNotifierProvider.notifier)
          .initiateTransfer(
            bankCode: widget.accountDetails.bankCode,
            accountNumber: widget.accountDetails.accountNumber,
            amount: amount,
            currency: 'NGN',
            description: _descriptionController.text.trim(),
            pin: pin,
            saveBeneficiary: _saveBeneficiary,
            sessionId: widget.accountDetails.sessionId,
          );
      final state = ref.read(transferNotifierProvider);
      if (!mounted) return;
      _hideLoading();

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

  void _navigateToReceipt() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) {
        return;
      }
      final receiptData = [
        ShareableTransactionReceiptDetail(
          label: 'Amount',
          value: currencyFormatter(_amount.toString()),
        ),
        ShareableTransactionReceiptDetail(label: 'Currency', value: 'NGN'),
        ShareableTransactionReceiptDetail(
          label: 'Transaction Type',
          value: 'Inter-bank Transfer',
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
          value: widget.selectedBank.name,
        ),
        if (_descriptionController.text.isNotEmpty)
          ShareableTransactionReceiptDetail(
            label: 'Narration',
            value: _descriptionController.text,
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

      // Transfer successful - navigate to receipt
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => TransactionReceiptWidget(
                headerText: 'Transfer',
                amount: currencyFormatter(_amount.toString()),
                topDetails: [
                  TransactionDetail(
                    label: 'Transaction ID',
                    value:widget.accountDetails.sessionId,
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
                  TransactionDetail(
                    label: 'Bank',
                    value: widget.selectedBank.name,
                  ),
                  TransactionDetail(
                    label: 'Amount',
                    value: currencyFormatter(_amount.toString()),
                  ),
                  if (_transferFee != null)
                    TransactionDetail(
                      label: 'Transfer Fee',
                      value: currencyFormatter(_transferFee!.fee.toString()),
                    ),
                  if (_transferFee != null)
                    TransactionDetail(
                      label: 'Total',
                      value: currencyFormatter(
                        (_amount + _transferFee!.fee).toString(),
                      ),
                    ),
                  TransactionDetail(
                    label: 'Description',
                    value:
                        _descriptionController.text.trim().isEmpty
                            ? 'No description'
                            : _descriptionController.text.trim(),
                  ),
                ],
                shareableDetails: receiptData,
                receiptDate: receiptDate,
              ),
        ),
      );
    });
  }

  Future<void> _handlePinEntry({bool biometric = false}) async {
    final user = ref.watch(userProvider);
    final wallet =
        user?.wallets.isNotEmpty == true ? user!.wallets.first : null;
    final balance = wallet?.balance ?? 0.0;
    final hasEnoughBalance = checkBalanceLeft(
      context,
      balance.toString(),
      _totalAmount.toString(),
    );

    if (!hasEnoughBalance) return;

    final pin =
        biometric
            ? await BiometricTransactionPinModal.show(context)
            : await TransactionPinModal.show(context);

    if (pin != null && pin.length == 4) {
      final pinString = pin.toString();
      Navigator.pop(context);
      if (mounted) {
        _initiateTransfer(pinString, _amount);
      }
    }
  }

  _handleOnPressed() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReuseableTransactionDetailsScreen(
              totalAmount: _totalAmount,
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
                  'Account Name',
                  widget.accountDetails.accountName,
                  isDark,
                ),
                buildDetailRow('Bank', widget.selectedBank.name, isDark),
                buildDetailRow(
                  'Account Number',
                  widget.accountDetails.accountNumber,
                  isDark,
                ),
                buildDetailRow(
                  'Amount',
                  currencyFormatter(_amountController.text),
                  isDark,
                ),
                buildDetailRow(
                  'Fee',
                  currencyFormatter(_transferFee?.fee.toString() ?? ''),
                  isDark,
                ),
                buildDetailRow(
                  'Total Amount',
                  currencyFormatter('$_totalAmount'),
                  isDark,
                  isTotal: true,
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

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferNotifierProvider);
    _amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    _totalAmount = _amount + (_transferFee?.fee ?? 0);
    _userFullname = ref.read(userProvider)?.fullname ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Transfer Amount",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipient Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recipient Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: appTheme.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          widget.selectedBank.name
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                            color: appTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.accountDetails.accountName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${widget.accountDetails.accountNumber} • ${widget.selectedBank.name}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Amount Input
            const Text(
              "Amount",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ReuseableAmountTextfield(
              prefixText: '₦',
              amountController: _amountController,
              hintText: "Enter amount",
            ),
            if (_isNotMinimumAmount) SizedBox(height: 5),
            if (_isNotMinimumAmount)
              Text(
                'Minimum transfer amount is ₦50',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),

            const SizedBox(height: 16),

            // Description Input
            const Text(
              "Description (Optional)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "What's this transfer for?",
                filled: true,
                fillColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Fee Information
            if (_isLoadingFee)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text("Calculating fee..."),
                ],
              ),
            const SizedBox(height: 60),

            // Transfer Button
            FullWidthButton(
              text: 'Transfer',
              isEnabled: _amount >= 100 && _transferFee != null,
              onPressed: _handleOnPressed,
            ),
          ],
        ),
      ),
    );
  }
}
