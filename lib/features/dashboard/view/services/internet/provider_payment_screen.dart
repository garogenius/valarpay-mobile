import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/check_balance.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/current_rate_widget.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/features/notifiers/internet_notifier.dart';
import 'package:valarpay/features/models/internet_models.dart';
import 'package:valarpay/features/dashboard/widgets/services_widgets/cabletv_widgets/provider_selector_modal.dart';
import 'package:valarpay/features/dashboard/widgets/services_widgets/cabletv_widgets/plan_selector_modal.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class InternetProviderPaymentScreen extends ConsumerStatefulWidget {
  String providerName;

  InternetProviderPaymentScreen({super.key, required this.providerName});

  @override
  ConsumerState<InternetProviderPaymentScreen> createState() =>
      _InternetProviderPaymentScreenState();
}

class _InternetProviderPaymentScreenState
    extends ConsumerState<InternetProviderPaymentScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );

  String _selectedProvider = '';
  String _selectedPlan = '';
  String _serviceFee = '0';
  bool _saveBeneficiary = false;
  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.providerName;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plans = ref.read(internetPlansNotifierProvider).data;
      if (plans != null && plans.isNotEmpty) {
        final match = plans.firstWhere(
          (p) => p.planName == _selectedProvider,
          orElse: () => plans.first,
        );
        ref
            .read(internetVariationNotifierProvider.notifier)
            .getVariations(billerCode: match.billerCode);
      }
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variationsState = ref.watch(internetVariationNotifierProvider);

    final planNames = variationsState.data?.map((v) => v.name).toList() ?? [];

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

    void _navigateToReceipt() {
      final variations = ref.read(internetVariationNotifierProvider).data;
      if (variations == null || variations.isEmpty) return;

      final selectedVar = variations.firstWhere(
        (v) => v.name == _selectedPlan,
        orElse: () => variations.first,
      );

      // Create receipt data while State is mounted
      final receiptData = [
        ShareableTransactionReceiptDetail(
          label: 'Amount',
          value: currencyFormatter(_amountController.text..replaceAll(',', '')),
        ),
        ShareableTransactionReceiptDetail(label: 'Currency', value: 'NGN'),
        ShareableTransactionReceiptDetail(
          label: 'Transaction Type',
          value: 'Internet',
        ),
        ShareableTransactionReceiptDetail(
          label: 'Beneficiary Number',
          value: _accountController.text.trim(),
        ),
        ShareableTransactionReceiptDetail(
          label: 'Provider',
          value: _selectedProvider,
        ),
        ShareableTransactionReceiptDetail(
          label: 'Transaction ID',
          value: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        ),
        ShareableTransactionReceiptDetail(
          label: 'Status',
          value: 'Successful',
          isSuccessful: true,
        ),
      ];

      final receiptDate =
          '${DateTime.now().day} ${DateFormat('MMMM').format(DateTime.now())} ${DateTime.now().year} | ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'pm' : 'am'}';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => TransactionReceiptWidget(
                headerText: 'Transaction',
                amount:
                    (selectedVar.payAmount ?? selectedVar.amount).toString(),
                topDetails: [
                  TransactionDetail(label: 'Plan', value: _selectedPlan),
                  TransactionDetail(
                    label: 'Provider',
                    value: _selectedProvider,
                  ),
                  TransactionDetail(
                    label: 'Amount',
                    value: currencyFormatter(_amountController.text),
                  ),
                ],
                bottomDetails: [
                  TransactionDetail(
                    label: 'Transaction ID',
                    value: 'TXN${DateTime.now().millisecondsSinceEpoch}',
                    showCopyIcon: true,
                  ),
                  TransactionDetail(
                    label: 'Account Number',
                    value: _accountController.text,
                  ),
                  TransactionDetail(
                    label: 'Payment Source',
                    value: 'ValarPay Account',
                  ),
                  TransactionDetail(
                    label: 'Date & Time',
                    value:
                        '${DateTime.now().day} ${DateFormat('MMMM').format(DateTime.now())} ${DateTime.now().year} | ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'pm' : 'am'}',
                  ),
                ],
                shareableDetails: receiptData,
                receiptDate: receiptDate,
              ),
        ),
      );
    }

    Future<void> _processPayment(String pin) async {
      if (_accountController.text.isEmpty || _selectedPlan.isEmpty) {
        return;
      }

      final variations = ref.read(internetVariationNotifierProvider).data;
      if (variations == null || variations.isEmpty) {
        AppMessenger.show(
          context,
          message: 'Plan not available',
          type: MessageType.error,
        );
        return;
      }

      final selectedVar = variations.firstWhere(
        (v) => v.name == _selectedPlan,
        orElse: () => variations.first,
      );

      _showLoading();

      try {
        await ref
            .read(internetPaymentNotifierProvider.notifier)
            .payInternet(
              InternetPayRequest(
                walletPin: pin,
                itemCode: selectedVar.itemCode,
                billerCode: selectedVar.billerCode,
                currency: 'NGN',
                amount: selectedVar.payAmount ?? selectedVar.amount,
                billerNumber: _accountController.text,
              ),
            );

        _hideLoading();

        if (!mounted) return;

        final state = ref.read(internetPaymentNotifierProvider);

        if (state.isDataAvailable &&
            state.data != null &&
            state.data!.isNotEmpty) {
          _navigateToReceipt();
        } else {
          final errorMessage =
              state.message ?? 'Payment failed. Please try again.';

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
                  : 'Payment failed: $errorMessage',
          type: MessageType.error,
        );
      }
    }

    _handlePin({bool biometric = false}) async {
      final totalAmount =
          int.parse(_amountController.text) + int.parse(_serviceFee);
      final user = ref.read(userProvider);
      final hasEnoughBalance = checkBalanceLeft(
        context,
        user?.wallets.first.balance.toString() ?? '0',
        totalAmount.toString(),
      );

      if (!hasEnoughBalance) return;

      final pin =
          biometric
              ? await BiometricTransactionPinModal.show(context)
              : await TransactionPinModal.show(context);

      if (pin == null || pin.length != 4 || !mounted) return;

      if (!mounted) return;
      Navigator.pop(context);

      await _processPayment(pin);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.providerName),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Saved Beneficiary',
              style: TextStyle(color: Color(0xFFF76301)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Provider',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showProviderSelector(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedProvider),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Account Number',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ReuseableTextFieldWithCountry(
              controller: _accountController,
              hintText: 'Account/Subscriber Number',
              isReadOnly: false,
              textInputType: TextInputType.number,
              showCountryLabel: false,
            ),
            const SizedBox(height: 24),
            Text(
              'Select Plan',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showPlanSelector(context, planNames),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedPlan.isEmpty ? 'Select Plan' : _selectedPlan),
                    variationsState.isInitialLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Icon(
                          Icons.keyboard_arrow_down,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CurrentRateWidget(
              price: _amountController.text.trim(),
              text: 'Current Rate',
            ),
            const SizedBox(height: 60),
            FullWidthButton(
              text: 'Continue',
              onPressed: () {
                if (_accountController.text.isEmpty || _selectedPlan.isEmpty) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ReuseableTransactionDetailsScreen(
                          totalAmount: double.parse(
                            (int.parse(_amountController.text) +
                                    int.parse(_serviceFee))
                                .toString(),
                          ),
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
                              'Account',
                              _accountController.text,
                              isDark,
                            ),
                            buildDetailRow(
                              'Provider',
                              _selectedProvider,
                              isDark,
                            ),
                            buildDetailRow('Package', _selectedPlan, isDark),
                            buildDetailRow(
                              'Amount',
                              currencyFormatter(_amountController.text),
                              isDark,
                            ),
                            buildDetailRow(
                              'Fee',
                              currencyFormatter(_serviceFee),
                              isDark,
                            ),
                            buildDetailRow(
                              'Total Amount',
                              currencyFormatter(
                                '${int.parse(_amountController.text) + int.parse(_serviceFee)}',
                              ),
                              isDark,
                              isTotal: true,
                            ),
                          ],
                          onButtonPressed: () => _handlePin(),
                          onBiometricButtonPressed:
                              () => _handlePin(biometric: true),
                          onAutomaticallyShowBiometric:
                              () => _handlePin(biometric: true),
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProviderSelector(BuildContext context) {
    final plans = ref.read(internetPlansNotifierProvider).data ?? [];
    final providers = plans.map((e) => e.planName).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CableTvProviderSelectorModal(
            selectedProvider: _selectedProvider,
            providers: providers,
            onProviderSelected: (provider) {
              setState(() {
                _selectedProvider = provider;
                widget.providerName = provider;
              });
              final match = plans.firstWhere(
                (p) => p.planName == provider,
                orElse: () => plans.first,
              );
              ref
                  .read(internetVariationNotifierProvider.notifier)
                  .getVariations(billerCode: match.billerCode);
            },
          ),
    );
  }

  void _showPlanSelector(BuildContext context, List<String> planNames) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CableTvPlanSelectorModal(
            selectedPlan: _selectedPlan,
            plans: planNames,
            onPlanSelected: (plan) {
              setState(() {
                _selectedPlan = plan;
                final variations =
                    ref.read(internetVariationNotifierProvider).data;
                if (variations != null && variations.isNotEmpty) {
                  final selectedVar = variations.firstWhere(
                    (v) => v.name == plan,
                    orElse: () => variations.first,
                  );
                  _amountController.text = (selectedVar.payAmount ??
                          selectedVar.amount)
                      .toStringAsFixed(0);
                }
              });
            },
          ),
    );
  }
}
