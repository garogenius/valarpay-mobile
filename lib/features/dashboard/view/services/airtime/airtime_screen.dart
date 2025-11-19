import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/check_balance.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/utils/helpers.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/features/dashboard/widgets/services_widgets/airtime_services_section.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/notifiers/airtime_notifier.dart';
import 'package:valarpay/features/providers/airtime_providers.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/models/airtime_models.dart';
import 'saved_beneficiary_screen.dart';

class AirtimeScreen extends ConsumerStatefulWidget {
  const AirtimeScreen({super.key});

  @override
  ConsumerState<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends ConsumerState<AirtimeScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _saveBeneficiary = false;
  bool _loadingShown = false;
  AirtimeBeneficiary? _selectedBeneficiary;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _assetForProvider(String network) {
    final n = network.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (n.contains('mtn')) return 'assets/images/mtn.png';
    if (n.contains('airtel')) return 'assets/images/airtel.png';
    if (n.contains('9mobile') || n.contains('etisalat') || n.contains('9'))
      return 'assets/images/9mobile.png';
    if (n.contains('glo')) return 'assets/images/glo.png';
    // fallback
    return 'assets/images/default.png';
  }

  String _formatTo11(String raw) {
    if (raw.isEmpty) return raw;
    var digits = raw.replaceAll(RegExp(r'\D'), '');

    // If starts with country code '234', strip it
    if (digits.startsWith('234')) {
      final rest = digits.substring(3);
      if (rest.length == 10) return '0$rest';
      if (rest.length == 11 && rest.startsWith('0')) return rest;
      // fallback to last 10 digits
      if (rest.length > 10) return '0' + rest.substring(rest.length - 10);
    }

    // If starts with leading '+' (already stripped) or other
    if (digits.length == 11 && digits.startsWith('0')) return digits;
    if (digits.length == 10) return '0$digits';
    if (digits.length > 11) return '0' + digits.substring(digits.length - 10);

    // otherwise return as-is
    return digits;
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

  bool _isFormValid(String network, int operatorId) =>
      _phoneController.text.isNotEmpty &&
      _amountController.text.isNotEmpty &&
      network.isNotEmpty &&
      operatorId > 0;

  void _detectNetworkProvider(String phoneNumber) {
    final formatted = _formatTo11(phoneNumber);
    final cleanedPhone = formatted.replaceAll(RegExp(r'\D'), '');

    if (cleanedPhone.length >= 10) {
      ref
          .read(airtimePlanNotifierProvider.notifier)
          .getPlan(phone: formatted, currency: 'NGN')
          .then((_) {
            final s = ref.read(airtimePlanNotifierProvider);
            if (s.isDataAvailable && s.data!.isNotEmpty) {
              final p = s.data!.first;
              ref.read(airtimeSelectedNetworkProvider.notifier).state = p.name;
              ref.read(airtimeSelectedOperatorIdProvider.notifier).state =
                  p.operatorId;
            }
            if (mounted) {
              setState(() {});
            }
          })
          .catchError((e) {
            if (mounted) {
              setState(() {});
            }
          });
    }
  }

  Future<void> _handlePin({bool biometric = false}) async {
    final user = ref.read(userProvider);
    final hasEnough = checkBalanceLeft(
      context,
      user?.wallets.first.balance.toString() ?? '0',
      _amountController.text.replaceAll(',', ''),
    );
    if (!hasEnough) return;

    final pin =
        biometric
            ? await BiometricTransactionPinModal.show(context)
            : await TransactionPinModal.show(context);

    if (pin == null || pin.length != 4 || !mounted) return;
    Navigator.pop(context);
    final operatorId = ref.read(airtimeSelectedOperatorIdProvider);

    _showLoading();

    try {
      final request = AirtimePurchaseRequest(
        walletPin: pin,
        amount: Helpers.parsedAmount(_amountController.text),
        operatorId: operatorId,
        phone: _phoneController.text.trim(),
        currency: 'NGN',
        addBeneficiary: _saveBeneficiary,
      );

      await ref
          .read(airtimePurchaseNotifierProvider.notifier)
          .purchase(request);

      _hideLoading();

      if (!mounted) return;

      final state = ref.read(airtimePurchaseNotifierProvider);

      if (state.isDataAvailable) {
        _navigateToReceipt();
      } else {
        // Check if the error message indicates incorrect PIN
        final errorMessage =
            state.message ?? 'Transaction failed. Please try again.';

        // Common patterns for incorrect PIN errors
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

  // ------------------- Navigation -------------------
  void _navigateToReceipt() {
    final selectedNetwork = ref.read(airtimeSelectedNetworkProvider);
    final now = DateTime.now();

    // Create receipt data while State is mounted
    final receiptData = [
      ShareableTransactionReceiptDetail(
        label: 'Amount',
        value: currencyFormatter(_amountController.text.replaceAll(',', '')),
      ),
      ShareableTransactionReceiptDetail(label: 'Currency', value: 'NGN'),
      ShareableTransactionReceiptDetail(
        label: 'Transaction Type',
        value: 'Airtime Purchase',
      ),
      ShareableTransactionReceiptDetail(
        label: 'Provider',
        value: selectedNetwork.toUpperCase(),
      ),
      ShareableTransactionReceiptDetail(
        label: 'Phone Number',
        value: _phoneController.text.trim(),
      ),
      ShareableTransactionReceiptDetail(
        label: 'Transaction ID',
        value: 'TXN${now.millisecondsSinceEpoch}',
      ),
      ShareableTransactionReceiptDetail(
        label: 'Status',
        value: 'Successful',
        isSuccessful: true,
      ),
    ];

    final receiptDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} | ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TransactionReceiptWidget(
              headerText: 'Transaction',
              amount: currencyFormatter(
                _amountController.text.replaceAll(',', ''),
              ),
              topDetails: [
                TransactionDetail(
                  label: 'Transaction ID',
                  value: 'TXN${now.millisecondsSinceEpoch}',
                  showCopyIcon: true,
                ),
                TransactionDetail(
                  label: 'Recipient Number',
                  value: _phoneController.text,
                ),
                TransactionDetail(
                  label: 'Network',
                  value: selectedNetwork.toUpperCase(),
                ),
                TransactionDetail(
                  label: 'Amount',
                  value: currencyFormatter(
                    _amountController.text.replaceAll(',', ''),
                  ),
                ),
              ],
              shareableDetails: receiptData,
              receiptDate: receiptDate,
            ),
      ),
    );
  }

  void _navigateToDetails(String network, int operatorId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ReuseableTransactionDetailsScreen(
              totalAmount: double.parse(_amountController.text),
              hasBottom: false,
              saveBeneficiary: _saveBeneficiary,
              onSaveBeneficiaryChanged:
                  (v) => setState(() => _saveBeneficiary = v),
              topTitleText: 'Transaction',
              topTransactionsDetailsList: [
                buildDetailRow(
                  'Recipient Number',
                  _phoneController.text,
                  isDark,
                ),
                buildDetailRow('Provider', network, isDark),
                buildDetailRow(
                  'Amount',
                  currencyFormatter(_amountController.text.replaceAll(',', '')),
                  isDark,
                ),
              ],
              onButtonPressed: () => _handlePin(biometric: false),
              onBiometricButtonPressed: () => _handlePin(biometric: true),
              onAutomaticallyShowBiometric: () => _handlePin(biometric: true),
            ),
      ),
    );
  }

  Future<void> _pickContact() async {
    try {
      final status = await Permission.contacts.status;

      if (status.isDenied || status.isRestricted) {
        final result = await Permission.contacts.request();
        if (!result.isGranted) {
          AppMessenger.show(
            context,
            message: 'Contacts permission denied',
            type: MessageType.error,
          );
          return;
        }
      } else if (status.isPermanentlyDenied) {
        AppMessenger.show(
          context,
          message:
              'Contacts permission permanently denied. Enable it in settings.',
          type: MessageType.error,
        );
        await openAppSettings();
        return;
      }

      _showLoading();
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      _hideLoading();

      final list = contacts.where((c) => c.phones.isNotEmpty).toList();
      if (list.isEmpty) {
        AppMessenger.show(
          context,
          message: 'No contacts found',
          type: MessageType.error,
        );
        return;
      }

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) {
          final searchController = TextEditingController();
          List<Contact> filtered = List.from(list);

          return StatefulBuilder(
            builder: (context, setModalState) {
              void filter(String query) {
                final q = query.toLowerCase();
                setModalState(() {
                  filtered =
                      list
                          .where(
                            (c) =>
                                c.displayName.toLowerCase().contains(q) ||
                                (c.phones.isNotEmpty &&
                                    c.phones.first.number.contains(q)),
                          )
                          .toList();
                });
              }

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Select Contact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search contact...',
                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).cardColor.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: filter,
                        ),
                      ),
                      SizedBox(
                        height: 450,
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final c = filtered[i];
                            final number =
                                c.phones.isNotEmpty
                                    ? c.phones.first.number
                                    : '';
                            return ListTile(
                              title: Text(c.displayName),
                              subtitle: Text(number),
                              onTap: () {
                                _phoneController.text = Helpers.formatTo11(
                                  number,
                                );
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      _hideLoading();
      AppMessenger.show(
        context,
        message: 'Failed to load contacts',
        type: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isVerified = user?.isBvnVerified ?? false;
    final network = ref.watch(airtimeSelectedNetworkProvider);
    final operatorId = ref.watch(airtimeSelectedOperatorIdProvider);
    final planState = ref.watch(airtimePlanNotifierProvider);
    final plan =
        planState.data?.isNotEmpty == true ? planState.data!.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Airtime',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions:
            isVerified
                ? [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AirtimeSavedBeneficiaryScreen(
                                onSelectBeneficiary: (beneficiary) {
                                  setState(() {
                                    _selectedBeneficiary = beneficiary;
                                    _phoneController.text =
                                        beneficiary.phoneNumber;
                                  });

                                  // Trigger network detection for saved beneficiary
                                  _detectNetworkProvider(
                                    beneficiary.phoneNumber,
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    child: Text(
                      'Saved Beneficiary',
                      style: TextStyle(color: appTheme.primaryColor),
                    ),
                  ),
                ]
                : null,
      ),
      body:
          !isVerified
              ? const KycNotSetWidget(
                title: 'KYC Not Completed',
                subtitle: 'Complete your KYC to purchase airtime.',
              )
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Selected Beneficiary if available
                      if (_selectedBeneficiary != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: appTheme.primaryColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Network Icon
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: appTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.phone,
                                    color: Color(0xFFF76301),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Beneficiary Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedBeneficiary!.phoneNumber,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (_selectedBeneficiary!.network != null)
                                        Text(
                                          _selectedBeneficiary!.network!
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Clear button
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _selectedBeneficiary = null;
                                      _phoneController.clear();
                                    });
                                  },
                                  tooltip: 'Clear selection',
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ReuseableTextFieldWithCountry(
                        controller: _phoneController,
                        maxLength: 11,
                        countryCode: '+234 ',
                        flagImagePath: 'assets/images/ngflag.png',
                        hintText: '812 345 6789',
                        textInputType: TextInputType.phone,
                        suffixWidget: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: appTheme.primaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          onPressed: _pickContact,
                        ),
                        onChanged: (v) {
                          setState(() {});
                          _detectNetworkProvider(v);
                        },
                        isReadOnly: false,
                        showCountryLabel: true,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Network Provider',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            (planState.isInitialLoading && plan == null)
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : plan == null
                                ? const Text(
                                  'Enter phone number to automatically detect network provider',
                                  style: TextStyle(color: Colors.orange),
                                )
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 80,
                                      width: 80,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).cardColor.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: appTheme.primaryColor
                                                .withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: Image.asset(
                                              _assetForProvider(plan.name),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Amount',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ReuseableAmountTextfield(
                        amountController: _amountController,
                        prefixText: '₦',
                        hintText: '500',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      // Quick Amount Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [100, 200, 300, 400, 500, 1000, 2000]
                                .map(
                                  (amount) => InkWell(
                                    onTap: () {
                                      setState(() {
                                        _amountController.text =
                                            amount.toString();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).cardColor.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: appTheme.primaryColor
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '₦$amount',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _amountController.text ==
                                                      amount.toString()
                                                  ? appTheme.primaryColor
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 30),
                      FullWidthButton(
                        text: 'Continue',
                        isEnabled: _isFormValid(network, operatorId),
                        onPressed:
                            () => _navigateToDetails(network, operatorId),
                      ),
                      const SizedBox(height: 40),
                      const AirtimeServicesSection(),
                    ],
                  ),
                ),
              ),
    );
  }
}
