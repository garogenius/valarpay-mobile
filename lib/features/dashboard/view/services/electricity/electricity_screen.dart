import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/check_balance.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/features/models/electricity.dart';
import 'package:valarpay/features/notifiers/electricity_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../../../widgets/services_widgets/electricity_widgets/disco_selector_modal.dart';
import '../../../widgets/services_widgets/electricity_widgets/meter_type_modal.dart';
import 'saved_beneficiary_screen.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';

class ElectricityScreen extends ConsumerStatefulWidget {
  const ElectricityScreen({super.key});

  @override
  ConsumerState<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends ConsumerState<ElectricityScreen> {
  final TextEditingController _meterNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final NumberFormat _formatter = NumberFormat('#,###');
  bool _saveBeneficiary = false;

  VerifyMeterNumberData? _verifyMeterNumberData;
  String _serviceFee = '500';
  String _customerName = '';
  bool _isMeterVerified = false;
  bool _hasError = false;
  bool _isNotMinimumAmount = false;
  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(electricityNotifierProvider.notifier)
          .getElectricityPlans(currency: 'NGN');
    });
    _amountController.addListener(() {
      final text = _amountController.text.replaceAll(',', '');
      if (text.isEmpty) return;

      try {
        final newText = _formatter.format(int.parse(text));
        if (newText != _amountController.text) {
          final cursorPos = newText.length;
          _amountController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: cursorPos),
          );
        }
      } catch (e) {
        // Invalid number format, skip formatting
      }

      try {
        if (double.parse(text) < _verifyMeterNumberData!.minimum) {
          setState(() {
            _isNotMinimumAmount = true;
          });
        } else {
          setState(() {
            _isNotMinimumAmount = false;
          });
        }
      } catch (e) {
        // Invalid number format
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final electricityState = ref.watch(electricityNotifierProvider);
    final billInfoState = ref.watch(electricityBillInfoNotifierProvider);
    final paymentState = ref.watch(electricityPaymentNotifierProvider);

    int _totalAmount = 0;
    try {
      _totalAmount =
          int.parse(_amountController.text.replaceAll(',', '')) +
          int.parse(_serviceFee);
    } catch (e) {
      _totalAmount = 0;
    }

    _buildElectricityReceiptData() {
      final paymentResponse =
          ref.read(electricityPaymentNotifierProvider).singleData;

      return [
        ShareableTransactionReceiptDetail(
          label: 'Amount',
          value: currencyFormatter(_amountController.text..replaceAll(',', '')),
        ),
        ShareableTransactionReceiptDetail(
          label: 'Fee',
          value: currencyFormatter(_serviceFee),
        ),
        ShareableTransactionReceiptDetail(label: 'Currency', value: 'NGN'),
        ShareableTransactionReceiptDetail(
          label: 'Transaction Type',
          value: 'Electricity Purchase',
        ),
        ShareableTransactionReceiptDetail(
          label: 'Token',
          value: paymentResponse!.data.rechargeToken,
        ),
        ShareableTransactionReceiptDetail(
          label: 'Meter Details',
          value:
              '${_meterNumberController.text.trim()}\n${ref.read(electricitySelectedMeterTypeProvider)?.categoryName}',
        ),
        ShareableTransactionReceiptDetail(
          label: 'Customer Name',
          value: _verifyMeterNumberData?.name ?? '',
        ),
        ShareableTransactionReceiptDetail(
          label: 'Discos',
          value: ref.read(electricitySelectedDiscoProvider)?.planName ?? '',
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

    bool _canProceed() {
      return ref.read(electricitySelectedDiscoProvider) != null &&
          ref.read(electricitySelectedMeterTypeProvider) != null &&
          _meterNumberController.text.isNotEmpty &&
          _amountController.text.isNotEmpty &&
          _isMeterVerified &&
          _verifyMeterNumberData != null &&
          !_isNotMinimumAmount;
    }

    void _verifyMeterNumber() async {
      if (ref.read(electricitySelectedMeterTypeProvider) == null ||
          ref.read(electricitySelectedDiscoProvider) == null)
        return;

      setState(() {
        _hasError = false;
      });

      final selectedMeterType = ref.read(electricitySelectedMeterTypeProvider)!;
      final selectedDisco = ref.read(electricitySelectedDiscoProvider)!;

      final request = VerifyMeterNumberRequest(
        billPaymentProductId: selectedMeterType.itemCode ?? '',
        customerId: _meterNumberController.text,
        billerCode: selectedDisco.billerCode,
      );

      final response = await ref
          .read(electricityPaymentNotifierProvider.notifier)
          .verifyMeterNumber(request);

      if (response != null && response.data != null) {
        // validate-customer returns 200 with data.name when successful
        final success = response.data!.name.isNotEmpty;
        if (success) {
          setState(() {
            _isMeterVerified = true;
            _verifyMeterNumberData = response.data;
            _customerName = _verifyMeterNumberData?.name ?? '';
            // set minimum amount as service fee baseline if provided
            try {
              final feeInt = response.data!.fee.toInt();
              if (feeInt > 0) _serviceFee = feeInt.toString();
            } catch (_) {}
          });
          return;
        }
      }
      // Fallthrough: no data or empty name = error
      setState(() {
        _hasError = true;
        _isMeterVerified = false;
        _customerName = '';
      });
    }

    // cable plans are read when needed (e.g. in modal builders)

    void _navigateToReceipt() {
      final paymentResponse =
          ref.read(electricityPaymentNotifierProvider).singleData;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => TransactionReceiptWidget(
                headerText: 'Transaction',
                amount:
                    '${int.parse(_amountController.text) + int.parse(_serviceFee)}',
                topDetails: [
                  TransactionDetail(
                    label: 'Token',
                    value: paymentResponse!.data.rechargeToken,
                    showCopyIcon: true,
                  ),
                  TransactionDetail(
                    label: 'Amount',
                    value: currencyFormatter(_amountController.text),
                  ),
                  TransactionDetail(
                    label: 'Fee',
                    value: currencyFormatter(_serviceFee),
                  ),
                  TransactionDetail(
                    label: 'Total Debit',
                    value: currencyFormatter(
                      '${int.parse(_amountController.text) + int.parse(_serviceFee)}',
                    ),
                  ),
                ],
                bottomDetails: [
                  TransactionDetail(
                    label: 'Transaction ID',
                    value: 'TXN${DateTime.now().millisecondsSinceEpoch}',
                    showCopyIcon: true,
                  ),
                  TransactionDetail(
                    label: 'Meter Details',
                    value:
                        '${_meterNumberController.text} | ${ref.read(electricitySelectedMeterTypeProvider)?.categoryName}',
                  ),
                  TransactionDetail(
                    label: 'Customer Name',
                    value: _customerName,
                  ),
                  TransactionDetail(
                    label: 'Disco',
                    value:
                        ref.read(electricitySelectedDiscoProvider)?.planName ??
                        '',
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
                shareableDetails: _buildElectricityReceiptData(),
                receiptDate:
                    '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} | ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}',
              ),
        ),
      );
    }

    Future<void> _processPayment(String pin) async {
      if (!_canProceed()) return;

      final selectedMeterType = ref.read(electricitySelectedMeterTypeProvider)!;
      final selectedDisco = ref.read(electricitySelectedDiscoProvider)!;

      final request = ElectricityPaymentRequest(
        walletPin: pin,
        itemCode: selectedMeterType.itemCode,
        billerCode: selectedDisco.billerCode,
        currency: 'NGN',
        billerNumber: _meterNumberController.text,
        amount: double.parse(_amountController.text.replaceAll(',', '')),
      );

      try {
        await ref
            .read(electricityPaymentNotifierProvider.notifier)
            .payElectricity(request);

        if (!mounted) return;

        final state = ref.read(electricityPaymentNotifierProvider);

        if (state.isDataAvailable && state.singleData != null) {
          _navigateToReceipt();
        } else {
          final errorMessage =
              state.message ?? 'Payment failed. Please try again.';

          // Check if the error message indicates incorrect PIN
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

        // Check if the exception message indicates incorrect PIN
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

    void _showDiscoSelector(BuildContext context) {
      final electricityState = ref.read(electricityNotifierProvider);
      if (!electricityState.isDataAvailable || electricityState.data == null)
        return;

      // Deduplicate plans by billerCode or billerName to show unique Discos
      final uniqueDiscosMap = <String, ElectricityPlan>{};
      for (var plan in electricityState.data!) {
        // Use billerCode as primary key, or billerName if code not available
        final key = plan.billerCode.isNotEmpty ? plan.billerCode : (plan.billerName ?? '');
        if (key.isNotEmpty && !uniqueDiscosMap.containsKey(key)) {
          // We want to store a representative plan for the Disco.
          // Ideally one with a generic name like "Eko Disco" instead of "Eko Disco Prepaid"
          // But usually they share the same billerName/Icon so any plan works for display.
          uniqueDiscosMap[key] = plan;
        }
      }
      final uniqueDiscos = uniqueDiscosMap.values.toList();

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder:
            (context) => DiscoSelectorModal(
              discos: uniqueDiscos, // Pass the deduplicated list
              selectedDisco: ref.read(electricitySelectedDiscoProvider),
              onDiscoSelected: (disco) {
                ref.read(electricitySelectedDiscoProvider.notifier).state =
                    disco;
                ref.read(electricitySelectedMeterTypeProvider.notifier).state =
                    null;
                setState(() {
                  _isMeterVerified = false;
                  _customerName = '';
                });
                // Call getBillInfo to fetch meter types for the newly selected Disco
                ref.read(electricityBillInfoNotifierProvider.notifier).getBillInfo(billerId: disco.billerCode);
              },
            ),
      );
    }

    void _showMeterTypeModal(BuildContext context) {
      final billInfoState = ref.read(electricityBillInfoNotifierProvider);
      final selectedDisco = ref.read(electricitySelectedDiscoProvider);
      
      if (!billInfoState.isDataAvailable || billInfoState.data == null || selectedDisco == null) return;

      final meterTypes = billInfoState.data!;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder:
            (context) => MeterTypeModal(
              meterTypes: meterTypes,
              selectedType: ref.read(electricitySelectedMeterTypeProvider),
              onTypeSelected: (type) {
                ref.read(electricitySelectedMeterTypeProvider.notifier).state =
                    type;
                setState(() {
                  _isMeterVerified = false;
                  _customerName = '';
                });
                // Verify meter number if already entered
                if (_meterNumberController.text.length >= 10) {
                  _verifyMeterNumber();
                }
              },
            ),
      );
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

      // ✅ Close the transaction details screen FIRST
      if (!mounted) return;
      Navigator.pop(context);

      // ✅ THEN process payment
      await _processPayment(pin);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Electricity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: null,
      ),
      body:
          !isBvnVerified
              ? const KycNotSetWidget(
                title: 'KYC Not Completed',
                subtitle:
                    'Complete your KYC verification to pay electricity bills',
              )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Select Disco
                    Text(
                      'Select Disco',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap:
                          electricityState.isDataAvailable
                              ? () => _showDiscoSelector(context)
                              : null,
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
                            Expanded(
                              child: Row(
                                children: [
                                  if (ref.watch(electricitySelectedDiscoProvider)?.billerIcon != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: ClipOval(
                                        child: Image.network(
                                          ref.watch(electricitySelectedDiscoProvider)!.billerIcon!,
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(Icons.flash_on, size: 20),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      ref
                                              .watch(electricitySelectedDiscoProvider)
                                              ?.planName ??
                                          'Select Disco',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            ref.watch(
                                                      electricitySelectedDiscoProvider,
                                                    ) ==
                                                    null
                                                ? Colors.grey
                                                : (isDark ? Colors.white : Colors.black),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            electricityState.isInitialLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
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

                    // Meter Type
                    Text(
                      'Meter Type',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap:
                          electricityState.isDataAvailable && ref.watch(electricitySelectedDiscoProvider) != null
                              ? () => _showMeterTypeModal(context)
                              : null,
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
                            Expanded(
                              child: Text(
                                ref
                                        .watch(
                                          electricitySelectedMeterTypeProvider,
                                        )
                                        ?.name ??
                                    'Select Meter Type',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      ref.watch(
                                                electricitySelectedMeterTypeProvider,
                                              ) ==
                                              null
                                          ? Colors.grey
                                          : (isDark ? Colors.white : Colors.black),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            billInfoState.isInitialLoading
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
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

                    // Meter Number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meter Number',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (isBvnVerified)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SavedBeneficiaryScreen(
                                        onSelectBeneficiary: (beneficiary) {
                                          setState(() {
                                            _meterNumberController.text =
                                                beneficiary.meterNumber;
                                          });
                                          // Verify meter number
                                          if (ref.read(
                                                electricitySelectedMeterTypeProvider,
                                              ) !=
                                              null) {
                                            _verifyMeterNumber();
                                          }
                                        },
                                      ),
                                ),
                              );
                            },
                            child: const Text(
                              'Saved Beneficiary',
                              style: TextStyle(
                                color: Color(0xFFF76301),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ReuseableTextFieldWithCountry(
                      controller: _meterNumberController,
                      hintText: 'Enter Meter Number',
                      isReadOnly:
                          ref.watch(electricitySelectedDiscoProvider) == null ||
                          ref.watch(electricitySelectedMeterTypeProvider) ==
                              null,
                      textInputType: TextInputType.number,
                      showCountryLabel: false,
                      onChanged: (value) {
                        if (value.length >= 10 &&
                            ref.read(electricitySelectedMeterTypeProvider) !=
                                null) {
                          _verifyMeterNumber();
                        } else {
                          setState(() {
                            _isMeterVerified = false;
                            _customerName = '';
                            _hasError = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Meter verification status
                    if (_meterNumberController.text.isNotEmpty &&
                        ref.watch(electricitySelectedMeterTypeProvider) != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _isMeterVerified
                                  ? Colors.green.withOpacity(0.1)
                                  : _hasError
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                _isMeterVerified
                                    ? Colors.green
                                    : _hasError
                                    ? Colors.red
                                    : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isMeterVerified
                                  ? Icons.check_circle
                                  : Icons.info,
                              color:
                                  _isMeterVerified
                                      ? Colors.green
                                      : _hasError
                                      ? Colors.red
                                      : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isMeterVerified
                                    ? 'Account Name: $_customerName \nMinimum: ${currencyFormatter(_verifyMeterNumberData?.minimum.toString() ?? '')} \nAddress: ${_verifyMeterNumberData?.address}'
                                    : paymentState.isInitialLoading
                                    ? 'Verifying meter number...'
                                    : _hasError
                                    ? paymentState.message ??
                                        'Error verifying meter number'
                                    : 'Enter valid meter number to verify',
                                style: TextStyle(
                                  color:
                                      _isMeterVerified
                                          ? Colors.green
                                          : _hasError
                                          ? Colors.red
                                          : Colors.orange,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Amount
                    Text(
                      'Amount',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ReuseableAmountTextfield(
                      amountController: _amountController,
                      prefixText: '₦',
                      isReadOnly: _verifyMeterNumberData == null,
                      hintText: '10,000',
                    ),
                    if (_isNotMinimumAmount) SizedBox(height: 12),
                    if (_isNotMinimumAmount)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Please enter a value greater or equal to ${currencyFormatter(_verifyMeterNumberData!.minimum.toString())}',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 60),

                    // Continue Button
                    FullWidthButton(
                      text: 'Continue',
                      isEnabled: _canProceed(),
                      onPressed: () {
                        if (_canProceed()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) => ReuseableTransactionDetailsScreen(
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
                                        'Meter Number',
                                        _meterNumberController.text,
                                        isDark,
                                      ),
                                      buildDetailRow(
                                        'Disco',
                                        ref
                                                .read(
                                                  electricitySelectedDiscoProvider,
                                                )
                                                ?.planName ??
                                            '',
                                        isDark,
                                      ),
                                      buildDetailRow(
                                        'Meter Type',
                                        ref
                                                .read(
                                                  electricitySelectedMeterTypeProvider,
                                                )
                                                ?.categoryName ??
                                            '',
                                        isDark,
                                      ),
                                      buildDetailRow(
                                        'Customer Name',
                                        _customerName,
                                        isDark,
                                      ),
                                      buildDetailRow(
                                        'Amount',
                                        currencyFormatter(
                                          _amountController.text
                                            ..replaceAll(',', ''),
                                        ),
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
                                          _totalAmount.toString(),
                                        ),
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
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
