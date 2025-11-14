import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/check_balance.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'saved_beneficiary_screen.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import '../../../widgets/services_widgets/cabletv_widgets/cabletv_provider_selector_modal.dart';
import '../../../widgets/services_widgets/cabletv_widgets/cabletv_plan_selector_modal.dart';
import 'package:valarpay/features/notifiers/cable_notifier.dart';
import 'package:valarpay/features/models/cable_models.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class CableTvScreen extends ConsumerStatefulWidget {
  const CableTvScreen({super.key});

  @override
  ConsumerState<CableTvScreen> createState() => _CableTvScreenState();
}

class _CableTvScreenState extends ConsumerState<CableTvScreen> {
  final TextEditingController _smartcardController = TextEditingController();
  bool _saveBeneficiary = false;

  VerifyCableData? _verifyResponse;
  String? _verifiedUserName;
  String? _errorMessage;
  bool _showVerifyButton = false;
  bool _isVerifying = false;
  bool _hasError = false;
  String _planAmount = ' Amount';
  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cablePlansNotifierProvider.notifier).getPlans(currency: 'NGN');
    });
  }

  @override
  void dispose() {
    _smartcardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int _totalAmount = 0;
    try {
      final planAmountInt = int.parse(
        _planAmount.replaceAll(RegExp(r'[^\d]'), ''),
      );
      final feeAmount = double.parse(_verifyResponse?.fee.toString() ?? '0.0');
      _totalAmount = (planAmountInt + feeAmount).toInt();
    } catch (e) {
      _totalAmount = 0;
    }

    // cable plans are read when needed (e.g. in modal builders)

    _buildCableTVReceiptData() {
      return [
        ShareableTransactionReceiptDetail(
          label: 'Amount',
          value: currencyFormatter(_planAmount),
        ),
        ShareableTransactionReceiptDetail(label: 'Currency', value: 'NGN'),
        ShareableTransactionReceiptDetail(
          label: 'Transaction Type',
          value: 'Cable TV Purchase',
        ),
        ShareableTransactionReceiptDetail(
          label: 'Plan',
          value: ref.read(cableSelectedPlanProvider) ?? '',
        ),
        ShareableTransactionReceiptDetail(
          label: 'Smartcard Number',
          value: _smartcardController.text.trim(),
        ),
        ShareableTransactionReceiptDetail(
          label: 'Customer Name',
          value: _verifiedUserName ?? '',
        ),
        ShareableTransactionReceiptDetail(
          label: 'Provider',
          value: ref.read(cableSelectedProviderProvider)?.planName ?? '',
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

    void _navigateToReceipt() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => TransactionReceiptWidget(
                headerText: 'Transaction',
                amount: _planAmount,
                topDetails: [
                  TransactionDetail(
                    label: 'Plan',
                    value: ref.read(cableSelectedPlanProvider) ?? '',
                  ),
                  TransactionDetail(
                    label: 'Amount',
                    value: currencyFormatter(_planAmount),
                  ),
                  TransactionDetail(
                    label: 'Fee',
                    value: currencyFormatter('0.0'),
                  ),
                  TransactionDetail(
                    label: 'Total Debit',
                    value: currencyFormatter(_planAmount),
                  ),
                ],
                bottomDetails: [
                  TransactionDetail(
                    label: 'Provider',
                    value:
                        ref.read(cableSelectedProviderProvider)?.planName ?? '',
                  ),
                  TransactionDetail(
                    label: 'Smartcard Number',
                    value: _smartcardController.text,
                  ),
                  TransactionDetail(
                    label: 'Transaction ID',
                    value: 'TXN${DateTime.now().millisecondsSinceEpoch}',
                    showCopyIcon: true,
                  ),
                  TransactionDetail(
                    label: 'Payment Source',
                    value: 'ValarPay Account',
                  ),
                  TransactionDetail(
                    label: 'Date & Time',
                    value:
                        '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} | ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}',
                  ),
                ],
                shareableDetails: _buildCableTVReceiptData(),
                receiptDate:
                    '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} | ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}',
              ),
        ),
      );
    }

    Future<void> _processPayment(String pin) async {
      if (_smartcardController.text.isEmpty ||
          _planAmount.isEmpty ||
          _verifyResponse == null) {
        return;
      }

      final variations = ref.read(cableVariationNotifierProvider).data;
      if (variations == null || variations.isEmpty) {
        AppMessenger.show(
          context,
          message: 'Selected plan not available',
          type: MessageType.warning,
        );
        return;
      }

      final selectedVar = variations.firstWhere(
        (v) => v.name == ref.read(cableSelectedPlanProvider),
        orElse: () => variations.first,
      );

      _showLoading();

      try {
        await ref
            .read(cablePaymentNotifierProvider.notifier)
            .payCable(
              CablePayRequest(
                itemCode: selectedVar.itemCode,
                billerCode: selectedVar.billerCode,
                currency: 'NGN',
                billerNumber: _smartcardController.text,
                amount: selectedVar.payAmount ?? selectedVar.amount,
                walletPin: pin,
              ),
            );

        _hideLoading();

        if (!mounted) return;

        final state = ref.read(cablePaymentNotifierProvider);

        if (state.isDataAvailable && state.singleData != null) {
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
      final user = ref.read(userProvider);
      final hasEnoughBalance = checkBalanceLeft(
        context,
        user?.wallets.first.balance.toString() ?? '0',
        _totalAmount.toString(),
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
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cable Tv',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions:
            isBvnVerified
                ? [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const CableTvSavedBeneficiaryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Saved Beneficiary',
                      style: TextStyle(color: Color(0xFFF76301), fontSize: 14),
                    ),
                  ),
                ]
                : null,
      ),
      body:
          !isBvnVerified
              ? const KycNotSetWidget(
                title: 'KYC Not Completed',
                subtitle:
                    'Complete your KYC verification to pay for cable TV subscriptions',
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select Provider
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
                            Text(
                              ref
                                      .watch(cableSelectedProviderProvider)
                                      ?.planName ??
                                  'Select Provider',
                              style: TextStyle(fontSize: 16),
                            ),
                            ref
                                    .watch(cablePlansNotifierProvider)
                                    .isInitialLoading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(),
                                )
                                : Icon(
                                  Icons.keyboard_arrow_down,
                                  color:
                                      isDark
                                          ? Colors.white70
                                          : Colors.grey[600],
                                ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Smartcard Number
                    Text(
                      'Smartcard Number',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ReuseableTextFieldWithCountry(
                      controller: _smartcardController,
                      hintText: 'Smartcard Number ',
                      isReadOnly:
                          ref.watch(cableSelectedProviderProvider) == null,
                      textInputType: TextInputType.number,
                      showCountryLabel: false,
                      onChanged: (value) async {
                        setState(() {
                          _verifyResponse = null;
                          _showVerifyButton = value.isNotEmpty;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Verify Button / Response
                    if (_showVerifyButton && _verifyResponse == null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isVerifying
                                  ? null
                                  : () async {
                                    setState(() {
                                      _isVerifying = true;
                                      _hasError = false;
                                      _verifyResponse = null;
                                      _errorMessage = null;
                                    });

                                    final variations =
                                        ref
                                            .read(
                                              cableVariationNotifierProvider,
                                            )
                                            .data;
                                    if (variations == null ||
                                        variations.isEmpty) {
                                      if (mounted) {
                                        AppMessenger.show(
                                          context,
                                          message:
                                              'Selected plan not available',
                                          type: MessageType.warning,
                                        );
                                      }
                                      setState(() {
                                        _isVerifying = false;
                                      });
                                      return;
                                    }

                                    final selectedVar = variations.firstWhere(
                                      (v) =>
                                          v.name ==
                                          ref.read(cableSelectedPlanProvider),
                                      orElse: () => variations.first,
                                    );

                                    try {
                                      final res = await ref
                                          .read(
                                            cablePaymentNotifierProvider
                                                .notifier,
                                          )
                                          .verifyNumber(
                                            VerifyCableRequest(
                                              itemCode: selectedVar.itemCode,
                                              billerCode:
                                                  selectedVar.billerCode,
                                              billerNumber:
                                                  _smartcardController.text,
                                            ),
                                          );

                                      setState(() {
                                        // success path: store typed response and clear error
                                        _verifyResponse = res.data;
                                        _errorMessage = null;
                                        _verifiedUserName =
                                            _verifyResponse?.name;
                                        _showVerifyButton =
                                            false; // remove button once response displays
                                        _hasError = false;
                                        _isVerifying = false;
                                        _errorMessage = res.message;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        _verifyResponse = null;
                                        _verifiedUserName = null;
                                        _showVerifyButton = false;
                                        _hasError = true;
                                        _isVerifying = false;
                                        _errorMessage = e.toString();
                                      });
                                    }
                                  },
                          child:
                              _isVerifying
                                  ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Verify'),
                        ),
                      ),

                    if (_verifyResponse != null || _errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _verifiedUserName != null && _hasError == false
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                _verifiedUserName != null && _hasError == false
                                    ? Colors.green
                                    : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _verifiedUserName != null
                                  ? Icons.check_circle
                                  : Icons.info,
                              color:
                                  _verifiedUserName != null
                                      ? Colors.green
                                      : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _verifiedUserName != null && _hasError == false
                                    ? 'Account Name: $_verifiedUserName'
                                    : _errorMessage ?? '',
                                style: TextStyle(
                                  color:
                                      _verifiedUserName != null &&
                                              _hasError == false
                                          ? Colors.green
                                          : Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Select Plan
                    Text(
                      'Select Plan',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap:
                          ref.watch(cableSelectedProviderProvider) == null
                              ? null
                              : () => _showPlanSelector(context),
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
                            Text(
                              ref.watch(cableSelectedPlanProvider) ??
                                  'Select a plan',
                              style: TextStyle(fontSize: 16),
                            ),
                            ref
                                    .watch(cableVariationNotifierProvider)
                                    .isInitialLoading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Icon(
                                  Icons.keyboard_arrow_down,
                                  color:
                                      isDark
                                          ? Colors.white70
                                          : Colors.grey[600],
                                ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Current Date
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFF76301).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _planAmount == ' Amount'
                                ? _planAmount
                                : currencyFormatter(_planAmount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Pay Cable TV Button
                    FullWidthButton(
                      text: 'Pay Cable TV',
                      onPressed: () async {
                        if (_smartcardController.text.isEmpty ||
                            _planAmount.isEmpty ||
                            _verifyResponse == null) {
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ReuseableTransactionDetailsScreen(
                                  totalAmount: double.parse(
                                    _totalAmount.toString(),
                                  ),
                                  saveBeneficiary: _saveBeneficiary,
                                  onSaveBeneficiaryChanged: (value) {
                                    setState(() {
                                      _saveBeneficiary = value;
                                    });
                                  },
                                  hasBottom: false,
                                  topTitleText: 'Transaction',
                                  topTransactionsDetailsList: [
                                    buildDetailRow(
                                      'Smartcard Number',
                                      _smartcardController.text,
                                      isDark,
                                    ),
                                    buildDetailRow(
                                      'Customer Name',
                                      _verifiedUserName ?? '',
                                      isDark,
                                    ),
                                    buildDetailRow(
                                      'Provider',
                                      ref
                                              .read(
                                                cableSelectedProviderProvider,
                                              )
                                              ?.planName ??
                                          '',
                                      isDark,
                                    ),
                                    buildDetailRow(
                                      'Package',
                                      ref.read(cableSelectedPlanProvider) ?? '',
                                      isDark,
                                    ),
                                    buildDetailRow(
                                      'Amount',
                                      currencyFormatter(_planAmount),
                                      isDark,
                                    ),
                                    buildDetailRow(
                                      'Fee',
                                      currencyFormatter('0.0'),
                                      isDark,
                                    ),
                                    const Divider(),
                                    buildDetailRow(
                                      'Total Amount',
                                      currencyFormatter(_planAmount),
                                      isDark,
                                      isTotal: true,
                                    ),
                                  ],
                                  onButtonPressed: () => _handlePin(),
                                  onBiometricButtonPressed:
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final plans = ref.read(cablePlansNotifierProvider).data;
        final providers =
            plans != null && plans.isNotEmpty
                ? plans.map((e) => e.planName).toSet().toList().cast<String>()
                : <String>[];
        return CableTvProviderSelectorModal(
          selectedProvider:
              ref.read(cableSelectedProviderProvider)?.planName ??
              'Select Provider',
          providers: providers,
          onProviderSelected: (providerName) {
            if (plans != null && plans.isNotEmpty) {
              final match = plans.firstWhere(
                (p) => p.planName == providerName,
                orElse: () => plans.first,
              );
              ref.read(cableSelectedProviderProvider.notifier).state = match;
              ref
                  .read(cableVariationNotifierProvider.notifier)
                  .getVariations(billerCode: match.billerCode);
            }
          },
        );
      },
    );
  }

  void _showPlanSelector(BuildContext context) {
    final variations = ref.read(cableVariationNotifierProvider).data;
    final planNames = (variations ?? []).map((v) => v.name).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CableTvPlanSelectorModal(
            selectedPlan: ref.read(cableSelectedPlanProvider) ?? '',
            plans: planNames,
            onPlanSelected: (plan) {
              ref.read(cableSelectedPlanProvider.notifier).state = plan;
              if (variations != null && variations.isNotEmpty) {
                final selectedVar = variations.firstWhere(
                  (v) => v.name == plan,
                  orElse: () => variations.first,
                );
                setState(() {
                  _planAmount = (selectedVar.payAmount ?? selectedVar.amount)
                      .toStringAsFixed(0);
                });
              }
            },
          ),
    );
  }
}
