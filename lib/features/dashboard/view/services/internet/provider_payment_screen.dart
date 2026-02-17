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
  final String providerName;
  final String billerCode;

  InternetProviderPaymentScreen({
    super.key,
    required this.providerName,
    required this.billerCode,
  });

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
      ref
          .read(internetVariationNotifierProvider.notifier)
          .getVariations(billerCode: widget.billerCode);
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

      final now = DateTime.now();
      final receiptDate =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} | ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

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
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(child: _getProviderIcon(_selectedProvider)),
                        ),
                        Text(
                          _selectedProvider,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
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
                        ? const SizedBox.shrink()
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
    final uniqueProvidersMap = <String, InternetPlanInfo>{};
    for (var plan in plans) {
      if (!uniqueProvidersMap.containsKey(plan.billerCode)) {
        uniqueProvidersMap[plan.billerCode] = plan;
      }
    }
    final providers = uniqueProvidersMap.values
        .map((e) => _getCleanProviderName(e.planName))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CableTvProviderSelectorModal(
            selectedProvider: _selectedProvider,
            providers: providers,
            onProviderSelected: (providerName) {
              setState(() {
                _selectedProvider = providerName;
                _selectedPlan = ''; // Reset plan when provider changes
                _amountController.text = '0';
              });
              
              // Find the representative plan to get the billerCode
              final match = uniqueProvidersMap.values.firstWhere(
                (p) => _getCleanProviderName(p.planName) == providerName,
                orElse: () => uniqueProvidersMap.values.first,
              );

              ref
                  .read(internetVariationNotifierProvider.notifier)
                  .getVariations(billerCode: match.billerCode);
            },
          ),
    );
  }

  String _getCleanProviderName(String planName) {
    final lower = planName.toLowerCase();
    if (lower.contains('smile')) return 'Smile';
    if (lower.contains('spectranet')) return 'Spectranet';
    if (lower.contains('ipnx')) return 'ipNX';
    if (lower.contains('swift')) return 'Swift';
    if (lower.contains('mtn')) return 'MTN Hynet';
    if (lower.contains('airtel')) return 'Airtel';
    if (lower.contains('glo')) return 'Glo';
    if (lower.contains('9mobile') || lower.contains('etisalat')) return '9mobile';
    if (lower.contains('tizeti')) return 'Tizeti';

    final parts = planName.split(' ');
    if (parts.length > 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return planName;
  }

  Widget _getProviderIcon(String providerName) {
    final name = providerName.toLowerCase();

    if (name.contains('smile')) {
      return const Icon(Icons.wifi, color: Color(0xFFE91E63), size: 18);
    } else if (name.contains('spectranet')) {
      return const Icon(Icons.wifi_tethering, color: Color(0xFF2196F3), size: 18);
    } else if (name.contains('ipnx')) {
      return const Icon(Icons.router, color: Color(0xFF4CAF50), size: 18);
    } else if (name.contains('swift')) {
      return const Icon(Icons.speed, color: Color(0xFFDD2C00), size: 18);
    } else if (name.contains('mtn')) {
      return Image.asset(
        'assets/images/mtn.png',
        errorBuilder: (_, __, ___) => const Icon(Icons.wifi, size: 18),
      );
    } else if (name.contains('airtel')) {
      return Image.asset(
        'assets/images/airtel.png',
        errorBuilder: (_, __, ___) => const Icon(Icons.wifi, size: 18),
      );
    } else if (name.contains('glo')) {
      return Image.asset(
        'assets/images/glo.png',
        errorBuilder: (_, __, ___) => const Icon(Icons.wifi, size: 18),
      );
    } else if (name.contains('9mobile') || name.contains('etisalat')) {
      return Image.asset(
        'assets/images/9mobile.png',
        errorBuilder: (_, __, ___) => const Icon(Icons.wifi, size: 18),
      );
    } else if (name.contains('tizeti')) {
      return const Icon(Icons.wifi, color: Color(0xFF00ACC1), size: 18);
    }

    return const Icon(Icons.wifi, color: Colors.grey, size: 18);
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
