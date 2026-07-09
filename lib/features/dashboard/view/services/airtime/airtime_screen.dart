import 'dart:developer';
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
import 'package:valarpay/features/models/network_provider.dart';
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
  AirtimeBeneficiary? _selectedBeneficiary;
  bool _showRecentBeneficiaries = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(airtimeBeneficiaryNotifierProvider.notifier)
          .getAirtimeBeneficiaries();
      ref.read(airtimeProvidersNotifierProvider.notifier).fetchProviders();
    });
  }

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

    // Removal of manual loader usage

  bool _isFormValid(String network, int operatorId) {
    return _phoneController.text.isNotEmpty &&
      _amountController.text.isNotEmpty &&
      network.isNotEmpty;
  }

  void _detectNetworkProvider(String phoneNumber) {
    final formatted = _formatTo11(phoneNumber);
    final cleanedPhone = formatted.replaceAll(RegExp(r'\D'), '');

    if (cleanedPhone.length >= 4) {
      final providers = ref.read(airtimeProvidersNotifierProvider).data ?? [];
      if (providers.isNotEmpty) {
        final prefix = formatted.substring(0, 4);
        
        String? detectedBillerId;
        
        // Comprehensive Nigerian Network Prefixes
        const mtnPrefixes = {'0803', '0806', '0810', '0813', '0814', '0816', '0703', '0706', '0903', '0906', '0704'};
        const airtelPrefixes = {'0802', '0808', '0812', '0701', '0708', '0902', '0907', '0901', '0904'};
        const gloPrefixes = {'0805', '0807', '0811', '0815', '0705', '0905'};
        const mobile9Prefixes = {'0809', '0817', '0818', '0909', '0908'};

        if (mtnPrefixes.contains(prefix)) {
          detectedBillerId = 'MTN';
        } else if (airtelPrefixes.contains(prefix)) {
          detectedBillerId = 'AIRTEL';
        } else if (gloPrefixes.contains(prefix)) {
          detectedBillerId = 'GLO';
        } else if (mobile9Prefixes.contains(prefix)) {
          detectedBillerId = '9MOBILE';
        }

        if (detectedBillerId != null) {
          try {
            final p = providers.cast<NetworkProvider?>().firstWhere(
              (provider) =>
                  provider != null && (
                  provider.billerId == detectedBillerId ||
                  provider.network.toUpperCase().contains(detectedBillerId!) ||
                  provider.id.toString() == detectedBillerId),
              orElse: () => null,
            );
            
            if (p != null) {
              // Manual OperatorID mapping for local PalmPay billers (since API doesn't return them)
              int opId = p.operatorId;
              if (opId == 0) {
                final bId = p.billerId?.toUpperCase() ?? p.network.toUpperCase();
                if (bId.contains('MTN')) opId = 341;
                else if (bId.contains('AIRTEL')) opId = 342;
                else if (bId.contains('GLO')) opId = 344;
                else if (bId.contains('9MOBILE') || bId.contains('ETISALAT')) opId = 340;
              }

              // Set all relevant providers state
              ref.read(airtimeSelectedNetworkProvider.notifier).state = p.network;
              ref.read(airtimeSelectedOperatorIdProvider.notifier).state = opId;
              ref.read(airtimeSelectedBillerIdProvider.notifier).state = p.billerId;
              ref.read(airtimeSelectedBillItemIdProvider.notifier).state = p.billItemId;
            }
            
            if (mounted) setState(() {});
          } catch (e) {
            log('[AirtimeScreen] Provider matching error: $e');
          }
        }
      }
      
      // Fetch plan from backend if phone is complete
      if (cleanedPhone.length == 11) {
        ref.read(airtimePlanNotifierProvider.notifier).getPlan(
          phone: formatted, 
          currency: 'NGN',
        ).then((_) {
          final plans = ref.read(airtimePlanNotifierProvider).data;
          if (plans != null && plans.isNotEmpty && mounted) {
            final plan = plans.first;
            if (plan.operatorId != 0) {
              ref.read(airtimeSelectedOperatorIdProvider.notifier).state = plan.operatorId;
            }
            if (plan.billItemId.isNotEmpty) {
              ref.read(airtimeSelectedBillItemIdProvider.notifier).state = plan.billItemId;
            }
          }
        }).catchError((e) {
          log('[AirtimeScreen] getPlan error: $e');
        });
      }
    }
    if (mounted) {
      setState(() {});
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

      // manual loader removed

    try {
      final billerId = ref.read(airtimeSelectedBillerIdProvider);
      String? billItemId = ref.read(airtimeSelectedBillItemIdProvider);
      
      // Fallback if billItemId is empty or null
      if (billItemId == null || billItemId.isEmpty) {
        final providers = ref.read(airtimeProvidersNotifierProvider).data ?? [];
        final selectedNetwork = ref.read(airtimeSelectedNetworkProvider);
        if (providers.isNotEmpty) {
          try {
            final match = providers.firstWhere((p) =>
              (billerId != null && billerId.isNotEmpty && p.billerId == billerId) ||
              (p.network.toLowerCase().contains(selectedNetwork.toLowerCase()) || 
               selectedNetwork.toLowerCase().contains(p.network.toLowerCase()))
            );
            billItemId = match.billItemId;
          } catch (_) {}
        }
      }

      final request = AirtimePurchaseRequest(
        walletPin: pin,
        amount: Helpers.parsedAmount(_amountController.text),
        operatorId: operatorId,
        billerId: billerId,
        itemId: billItemId,
        phone: _phoneController.text.trim(),
        currency: 'NGN',
        addBeneficiary: _saveBeneficiary,
      );

      await ref
          .read(airtimePurchaseNotifierProvider.notifier)
          .purchase(request);

      // manual loader removed

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
      // manual loader removed

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
              amount: _amountController.text.replaceAll(',', ''),
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

        // manual loader removed
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      // manual loader removed

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
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
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
                      const SizedBox(height: 10),
                      Expanded(
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
                                final formattedNumber = Helpers.formatTo11(number);
                                _phoneController.text = formattedNumber;
                                _detectNetworkProvider(formattedNumber);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              );
            },
          );
        },
      );
    } catch (e) {
    // manual loader removed
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
    final isVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false) || (user?.wallets.isNotEmpty ?? false);
    final network = ref.watch(airtimeSelectedNetworkProvider);
    final operatorId = ref.watch(airtimeSelectedOperatorIdProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(airtimeProvidersNotifierProvider, (previous, next) {
      if (next.isDataAvailable && next.data != null && next.data!.isNotEmpty) {
        if (_phoneController.text.isNotEmpty) {
          _detectNetworkProvider(_phoneController.text);
        }
      }
    });

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Airtime',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !isVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC to purchase airtime.',
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Bar: Provider | Phone | Contact
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                // Provider Selector
                                GestureDetector(
                                  onTap: () => _showProviderModal(context),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.transparent, // Asset should handle bg or fit
                                        ),
                                        child: ClipOval(
                                          child: Builder(
                                            builder: (context) {
                                              final providers = ref.watch(airtimeProvidersNotifierProvider).data ?? [];
                                              final selectedBillerId = ref.watch(airtimeSelectedBillerIdProvider);
                                              String? iconUrl;
                                                try {
                                                  iconUrl = providers.firstWhere((p) {
                                                    // Ensure we are matching on non-empty, meaningful values
                                                    if (selectedBillerId != null && selectedBillerId != '' && p.billerId == selectedBillerId) return true;
                                                    if (network != '' && p.network.toLowerCase() == network.toLowerCase()) return true;
                                                    return false;
                                                  }).billerIcon;
                                                } catch (_) {}

                                              if (iconUrl != null && iconUrl.isNotEmpty) {
                                                return Image.network(
                                                  iconUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, o, s) => Image.asset(_assetForProvider(network)),
                                                );
                                              }
                                              return Image.asset(
                                                _assetForProvider(network),
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, o, s) => Container(
                                                  color: Colors.grey, 
                                                  child: const Icon(Icons.phone_android, size: 20, color: Colors.white),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: isDark ? Colors.grey : Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 24,
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.5),
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                // Phone Input
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0000 0000 000',
                                      hintStyle: TextStyle(
                                        color: isDark ? Colors.white38 : Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _showRecentBeneficiaries = !_showRecentBeneficiaries;
                                          });
                                        },
                                        child: Icon(
                                          _showRecentBeneficiaries
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: isDark ? Colors.grey : Colors.black54,
                                        ),
                                      )
                                    ),
                                    onChanged: (v) {
                                        _detectNetworkProvider(v);
                                        setState(() {});
                                    },
                                  ),
                                ),
                                // Contact Picker
                                GestureDetector(
                                  onTap: _pickContact,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryColor, // Brand Primary Color
                                    ),
                                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (_showRecentBeneficiaries)
                            _buildRecentBeneficiariesDropdown(),

                          const SizedBox(height: 24),

                          // Top Up Title
                          Text(
                            'Top up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Top Up Grid
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1,
                            children: [50, 100, 200, 500, 1000, 2000].map((amount) {
                              final cashback = (amount * 0.01).toStringAsFixed(amount < 100 ? 1 : 0); // Mock cashback logic
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _amountController.text = amount.toString();
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: _amountController.text == amount.toString() 
                                      ? Border.all(color: AppColors.primaryColor, width: 1.5)
                                      : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '₦$cashback Cashback',
                                          style: const TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        currencyFormatter(amount.toString()),
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          const AirtimeServicesSection(),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Input Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.1),
                           blurRadius: 10,
                           offset: const Offset(0, -2),
                         )
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black : Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '₦',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey : Colors.black54,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '50-500,000',
                                      hintStyle: TextStyle(
                                        color: isDark ? Colors.grey[700] : Colors.grey[500],
                                        fontSize: 16,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          height: 50,
                          width: 100,
                          child: ElevatedButton(
                            onPressed: _isFormValid(network, operatorId) 
                                ? () => _navigateToDetails(network, operatorId)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor, // Brand Primary Color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Pay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showProviderModal(BuildContext context) {
    final providers = ref.watch(airtimeProvidersNotifierProvider).data ?? [];
    final currentNetwork = ref.watch(airtimeSelectedNetworkProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Select Provider',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Provider List
              if (providers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No providers available'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: providers.length,
                    itemBuilder: (context, index) {
                      final p = providers[index];
                      final isSelected = currentNetwork == p.network;
                      return InkWell(
                        onTap: () {
                          // Manual OperatorID mapping for local PalmPay billers
                          int opId = p.operatorId;
                          if (opId == 0) {
                            final bId = p.billerId?.toUpperCase() ?? p.network.toUpperCase();
                            if (bId.contains('MTN')) opId = 341;
                            else if (bId.contains('AIRTEL')) opId = 342;
                            else if (bId.contains('GLO')) opId = 344;
                            else if (bId.contains('9MOBILE') || bId.contains('ETISALAT')) opId = 340;
                          }

                          ref.read(airtimeSelectedNetworkProvider.notifier).state = p.network;
                          ref.read(airtimeSelectedOperatorIdProvider.notifier).state = opId;
                          ref.read(airtimeSelectedBillerIdProvider.notifier).state = p.billerId;
                          ref.read(airtimeSelectedBillItemIdProvider.notifier).state = p.billItemId;
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: p.billerIcon != null && p.billerIcon!.isNotEmpty
                                      ? Image.network(
                                          p.billerIcon!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Image.asset(_assetForProvider(p.network)),
                                        )
                                      : Image.asset(_assetForProvider(p.network)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                p.network,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.primaryColor, size: 24),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentBeneficiariesDropdown() {
    final state = ref.watch(airtimeBeneficiaryNotifierProvider);
    final beneficiaries = state.data ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.read(userProvider);
    final userPhone = user?.phoneNumber != null ? _formatTo11(user!.phoneNumber!) : null;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2725) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.isInitialLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (beneficiaries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No recent beneficiaries')),
            )
          else ...[
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: beneficiaries.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final b = beneficiaries[index];
                  final isMe = userPhone != null && _formatTo11(b.phoneNumber) == userPhone;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Row(
                      children: [
                        Text(
                          Helpers.formatPhoneNumber(b.phoneNumber),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'me',
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (b.network != null)
                          Text(
                            (b.network ?? '').toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.close, size: 16, color: Colors.grey),
                      ],
                    ),
                  onTap: () {
                      _phoneController.text = b.phoneNumber;
                      setState(() {
                         _showRecentBeneficiaries = false;
                      });
                      _detectNetworkProvider(b.phoneNumber);
                  },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            TextButton.icon(
              onPressed: () {
                 // ref.read(airtimeBeneficiaryNotifierProvider.notifier).clearAll();
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete All'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ],
      ),
    );
  }
} // End _AirtimeScreenState
