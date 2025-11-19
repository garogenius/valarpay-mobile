import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/check_balance.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/features/dashboard/widgets/services_widgets/contact_access_dialog.dart';
import 'package:valarpay/features/dashboard/widgets/services_widgets/mobile_data_services_section.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/notifiers/data_notifier.dart';
import 'package:valarpay/features/models/data_models.dart';
import 'package:valarpay/features/dashboard/widgets/services_widgets/network_provider_selector.dart';
import 'package:valarpay/features/models/network_provider.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/dashboard/view/services/data/saved_beneficiary_screen.dart';

class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );
  bool _saveBeneficiary = false;
  bool _loadingShown = false;
  DataBeneficiary? _selectedBeneficiary;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
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

  bool _isFormValid() {
    final selectedNetwork = ref.read(dataSelectedNetworkProvider);
    final selectedOperatorId = ref.read(dataSelectedOperatorIdProvider);
    final selectedPlan = ref.read(dataSelectedPlanProvider);

    return _phoneController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _amountController.text != '0' &&
        selectedNetwork.isNotEmpty &&
        selectedPlan.isNotEmpty &&
        selectedOperatorId > 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final plansState = ref.watch(dataPlansNotifierProvider);
    final availablePlans = plansState.data ?? <DataPlanInfo>[];
    final selectedNetwork = ref.watch(dataSelectedNetworkProvider);

    final uniqueNetworks =
        availablePlans.map((plan) => plan.network).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Data',
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
                              (context) => DataSavedBeneficiaryScreen(
                                onSelectBeneficiary: (beneficiary) {
                                  setState(() {
                                    _selectedBeneficiary = beneficiary;
                                    _phoneController.text =
                                        beneficiary.phoneNumber;
                                  });
                                  // Auto-detect network and operator
                                  if (beneficiary.network != null &&
                                      beneficiary.operatorId != null) {
                                    ref
                                        .read(
                                          dataSelectedNetworkProvider.notifier,
                                        )
                                        .state = beneficiary.network!;
                                    ref
                                        .read(
                                          dataSelectedOperatorIdProvider
                                              .notifier,
                                        )
                                        .state = beneficiary.operatorId!;
                                    // Reset selected plan for new operator
                                    ref
                                        .read(dataSelectedPlanProvider.notifier)
                                        .state = '';
                                    // Fetch plans to populate network selector
                                    ref
                                        .read(
                                          dataPlansNotifierProvider.notifier,
                                        )
                                        .getPlans(
                                          phone: beneficiary.phoneNumber,
                                          currency: 'NGN',
                                        );
                                    // Fetch variations for this operator
                                    ref
                                        .read(
                                          dataVariationNotifierProvider
                                              .notifier,
                                        )
                                        .getVariation(
                                          operatorId: beneficiary.operatorId!,
                                        );
                                  }
                                },
                              ),
                        ),
                      );
                    },
                    child: Text(
                      'Saved Beneficiary',
                      style: TextStyle(
                        color: appTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ]
                : null,
      ),
      body:
          !isBvnVerified
              ? const KycNotSetWidget(
                title: 'KYC Not Completed',
                subtitle: 'Complete your KYC verification to purchase data',
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ReuseableTextFieldWithCountry(
                      controller: _phoneController,
                      hintText: "123 567 890",
                      countryCode: '+234',
                      flagImagePath: 'assets/images/ngflag.png',
                      isReadOnly: false,
                      textInputType: TextInputType.phone,
                      showCountryLabel: true,
                      onChanged: (value) {
                        if (value.replaceAll(RegExp(r'\D'), '').length >= 10) {
                          ref
                              .read(dataPlansNotifierProvider.notifier)
                              .getPlans(phone: value, currency: 'NGN')
                              .then((_) {
                                final state = ref.read(
                                  dataPlansNotifierProvider,
                                );
                                if (state.isDataAvailable &&
                                    state.data!.isNotEmpty) {
                                  final plan = state.data!.first;
                                  ref
                                      .read(
                                        dataSelectedNetworkProvider.notifier,
                                      )
                                      .state = plan.network;
                                  ref
                                      .read(
                                        dataSelectedOperatorIdProvider.notifier,
                                      )
                                      .state = plan.operatorId;

                                  // ✅ Auto-fetch variations immediately
                                  ref
                                      .read(
                                        dataVariationNotifierProvider.notifier,
                                      )
                                      .getVariation(
                                        operatorId: plan.operatorId,
                                      );
                                }
                              });
                        }
                        setState(() {});
                      },
                      suffixWidget: IconButton(
                        onPressed: _showContactAccessDialog,
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
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Network Provider Selection
                    _buildNetworkProviderSelector(
                      plansState,
                      uniqueNetworks,
                      availablePlans,
                    ),
                    const SizedBox(height: 24),

                    // Data Amount Selection (from fixed amounts)
                    if (selectedNetwork.isNotEmpty) ...[
                      _buildDataAmountSection(),
                      const SizedBox(height: 24),
                    ],

                    const SizedBox(height: 32),

                    // Continue Button
                    FullWidthButton(
                      text: 'Continue',
                      onPressed: _handleContinue,
                      isEnabled: _isFormValid(),
                    ),
                    const SizedBox(height: 24),
                    const DataServicesSection(),
                  ],
                ),
              ),
    );
  }

  void _showContactAccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => ContactAccessDialog(
            onAllow: () {
              Navigator.of(context).pop();
              _pickContact();
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
    );
  }

  Future<void> _pickContact() async {
    try {
      // 🔹 First, check permission status
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
              'Contacts permission permanently denied. Please enable it in settings.',
          type: MessageType.error,
        );
        await openAppSettings();
        return;
      }

      //
      final contacts = await FlutterContacts.getContacts(withProperties: true);

      if (Navigator.canPop(context)) Navigator.pop(context); // close loading

      final contactList =
          contacts
              .where((c) => (c.phones.isNotEmpty) || (c.emails.isNotEmpty))
              .toList();

      if (contactList.isEmpty) {
        AppMessenger.show(
          context,
          message: 'No contacts with phone numbers found',
          type: MessageType.error,
        );
        return;
      }

      // ✅ Show searchable contact list
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) {
          final TextEditingController searchController =
              TextEditingController();
          List<Contact> filteredContacts = List.from(contactList);

          return StatefulBuilder(
            builder: (context, setModalState) {
              void _filterContacts(String query) {
                query = query.toLowerCase();
                setModalState(() {
                  filteredContacts =
                      contactList.where((c) {
                        final name = c.displayName.toLowerCase();
                        final phone =
                            c.phones.isNotEmpty
                                ? c.phones.first.number.toLowerCase()
                                : '';
                        return name.contains(query) || phone.contains(query);
                      }).toList();
                });
              }

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Select contact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // 🔍 Search Field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                          onChanged: _filterContacts,
                        ),
                      ),

                      // Contact list
                      SizedBox(
                        height: 450,
                        child:
                            filteredContacts.isEmpty
                                ? const Center(
                                  child: Text(
                                    'No contacts found',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                                : ListView.separated(
                                  itemCount: filteredContacts.length,
                                  separatorBuilder:
                                      (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final c = filteredContacts[index];
                                    final phone =
                                        c.phones.isNotEmpty
                                            ? c.phones.first.number
                                            : '';
                                    final displayName =
                                        c.displayName.isNotEmpty
                                            ? c.displayName
                                            : phone;

                                    return ListTile(
                                      title: Text(displayName),
                                      subtitle: Text(phone),
                                      onTap: () async {
                                        final formatted = _formatTo11(phone);
                                        setState(() {
                                          _phoneController.text = formatted;
                                        });

                                        final digitsOnly = formatted.replaceAll(
                                          RegExp(r'\D'),
                                          '',
                                        );
                                        if (digitsOnly.length >= 10) {
                                          await ref
                                              .read(
                                                dataPlansNotifierProvider
                                                    .notifier,
                                              )
                                              .getPlans(
                                                phone: formatted,
                                                currency: 'NGN',
                                              );
                                        }

                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        }
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
      if (Navigator.canPop(context)) Navigator.pop(context);
      AppMessenger.show(
        context,
        message: 'Failed to load contacts',
        type: MessageType.error,
      );
    }
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

  Widget _buildNetworkProviderSelector(
    DataState<DataPlanInfo>? plansState,
    List<String> uniqueNetworks,
    List<DataPlanInfo> availablePlans,
  ) {
    if ((plansState?.isInitialLoading ?? false) && availablePlans.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show message if no plans/networks
    if (uniqueNetworks.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Network Provider',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Enter phone number to automatically detect network provider',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Network Provider',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              (plansState?.isInitialLoading ?? false) && availablePlans.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Builder(
                    builder: (context) {
                      // ✅ Deduplicate by network - get unique networks only
                      final uniqueNetworkPlans = <String, DataPlanInfo>{};
                      for (final plan in availablePlans) {
                        if (!uniqueNetworkPlans.containsKey(plan.network)) {
                          uniqueNetworkPlans[plan.network] = plan;
                        }
                      }

                      // Map unique networks to NetworkProvider models
                      final providerModels =
                          uniqueNetworkPlans.values
                              .map(
                                (p) => NetworkProvider(
                                  id: p.id,
                                  planName: p.planName,
                                  network: p.network,
                                  countryISOCode: p.countryISOCode,
                                  operatorId: p.operatorId,
                                  createdAt: p.createdAt,
                                  updatedAt: p.updatedAt,
                                ),
                              )
                              .toList();

                      final selectedNetwork = ref.watch(
                        dataSelectedNetworkProvider,
                      );

                      return NetworkProviderSelector(
                        selectedNetwork: selectedNetwork,
                        providers: providerModels,
                        onNetworkSelected: (value) async {
                          if (value.isEmpty) return;
                          try {
                            final plan = availablePlans.firstWhere(
                              (p) => p.network == value,
                            );
                            ref
                                .read(dataSelectedNetworkProvider.notifier)
                                .state = value;
                            ref.read(dataSelectedPlanProvider.notifier).state =
                                '';
                            ref
                                .read(dataSelectedOperatorIdProvider.notifier)
                                .state = plan.operatorId;

                            await ref
                                .read(dataVariationNotifierProvider.notifier)
                                .getVariation(operatorId: plan.operatorId);
                          } catch (e) {
                            // Provider not found
                          }
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildDataAmountSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variationState = ref.watch(dataVariationNotifierProvider);
    final dataVariations = variationState.data ?? <DataPlan>[];

    // Get fixed amounts from the first variation (there's usually only one)
    final fixedAmounts =
        dataVariations.isNotEmpty
            ? dataVariations.first.fixedAmounts
            : <double>[];

    // Deduplicate amounts to avoid dropdown issues
    final uniqueAmounts = <double>{...fixedAmounts}.toList();

    // Get descriptions if available
    final descriptions =
        dataVariations.isNotEmpty
            ? dataVariations.first.fixedAmountsDescriptions
            : <String, dynamic>{};

    if (variationState.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (uniqueAmounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'No data plans available for this network',
          style: TextStyle(color: Colors.orange),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Data Plan',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
                  ref.watch(dataSelectedPlanProvider).isEmpty
                      ? null
                      : ref.watch(dataSelectedPlanProvider),
              hint: Text(
                'Select Data Plan',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
              items:
                  uniqueAmounts.map((amount) {
                    final amountKey = amount.toStringAsFixed(2);
                    final description = descriptions[amountKey] ?? '';
                    final displayText =
                        description.isNotEmpty
                            ? '$description - ₦${amount.toStringAsFixed(0)}'
                            : '₦${amount.toStringAsFixed(0)}';

                    return DropdownMenuItem<String>(
                      value: amount.toString(),
                      child: Text(
                        displayText,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(dataSelectedPlanProvider.notifier).state = value;
                  setState(() {
                    _amountController.text = double.parse(
                      value,
                    ).toStringAsFixed(0);
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Handle continue button press
  void _handleContinue() {
    if (!_isFormValid()) {
      AppMessenger.show(
        context,
        message: 'Please fill all required fields',
        type: MessageType.error,
      );

      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedNetwork = ref.read(dataSelectedNetworkProvider);
    final selectedPlan = ref.read(dataSelectedPlanProvider);
    final dataVariations = ref.read(dataVariationNotifierProvider).data ?? [];
    final descriptions =
        dataVariations.isNotEmpty
            ? dataVariations.first.fixedAmountsDescriptions
            : <String, dynamic>{};

    // Get description for selected amount - try both formats (0 and 0.00)
    final amountKey = double.parse(selectedPlan).toStringAsFixed(0);
    final amountKeyWithDecimals = double.parse(selectedPlan).toStringAsFixed(2);
    final description =
        descriptions[amountKey] ?? descriptions[amountKeyWithDecimals] ?? '';
    final planDescription =
        description.isNotEmpty
            ? description
            : '₦${_amountController.text} Data';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReuseableTransactionDetailsScreen(
              totalAmount: double.parse(_amountController.text),
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
                  'Recipient Number',
                  _phoneController.text,
                  isDark,
                ),
                buildDetailRow('Provider', selectedNetwork, isDark),
                buildDetailRow('Data Plan', planDescription, isDark),
                buildDetailRow('Amount', '₦${_amountController.text}', isDark),
              ],
              onButtonPressed: () => _handlePin(biometric: false),
              onBiometricButtonPressed: () => _handlePin(biometric: true),
              onAutomaticallyShowBiometric: () => _handlePin(biometric: true),
            ),
      ),
    );
  }

  Future<void> _handlePin({bool biometric = false}) async {
    final user = ref.read(userProvider);
    final hasEnoughBalance = checkBalanceLeft(
      context,
      user?.wallets.first.balance.toString() ?? '0',
      _amountController.text.replaceAll(',', ''),
    );
    if (!hasEnoughBalance) return;

    final pin =
        biometric
            ? await BiometricTransactionPinModal.show(context)
            : await TransactionPinModal.show(context);

    if (pin == null || pin.length != 4 || !mounted) return;
    if (!mounted) return;
    Navigator.pop(context);

    final selectedOperatorId = ref.read(dataSelectedOperatorIdProvider);
    _showLoading();

    try {
      final amount = double.tryParse(_amountController.text) ?? 0;

      final request = DataPurchaseRequest(
        walletPin: pin,
        amount: amount,
        operatorId: selectedOperatorId,
        phone: _phoneController.text,
        currency: 'NGN',
        addBeneficiary: _saveBeneficiary,
      );

      await ref.read(dataPurchaseNotifierProvider.notifier).purchase(request);
      _hideLoading();

      if (!mounted) return;

      final state = ref.read(dataPurchaseNotifierProvider);

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

  void _navigateToReceipt() {
    final selectedNetwork = ref.read(dataSelectedNetworkProvider);
    final selectedPlan = ref.read(dataSelectedPlanProvider);
    final dataVariations = ref.read(dataVariationNotifierProvider).data ?? [];
    final descriptions =
        dataVariations.isNotEmpty
            ? dataVariations.first.fixedAmountsDescriptions
            : <String, dynamic>{};

    // Get description for selected amount - try both formats (0 and 0.00)
    final amountKey = double.parse(selectedPlan).toStringAsFixed(0);
    final amountKeyWithDecimals = double.parse(selectedPlan).toStringAsFixed(2);
    final description =
        descriptions[amountKey] ?? descriptions[amountKeyWithDecimals] ?? '';
    final planDescription =
        description.isNotEmpty
            ? description
            : '₦${_amountController.text} Data';

    // Create receipt data while State is mounted
    final receiptData = [
      ShareableTransactionReceiptDetail(
        label: 'Amount',
        value: currencyFormatter(_amountController.text.replaceAll(',', '')),
      ),
      ShareableTransactionReceiptDetail(label: 'Currency', value: 'NGN'),
      ShareableTransactionReceiptDetail(
        label: 'Transaction Type',
        value: 'Mobile Data Purchase',
      ),
      ShareableTransactionReceiptDetail(
        label: 'Provider',
        value: selectedNetwork,
      ),
      ShareableTransactionReceiptDetail(label: 'Plan', value: planDescription),
      ShareableTransactionReceiptDetail(
        label: 'Phone Number',
        value: _phoneController.text.trim(),
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
            (_) => TransactionReceiptWidget(
              headerText: 'Transaction',
              amount: currencyFormatter(
                _amountController.text.replaceAll(',', ''),
              ),
              topDetails: [
                TransactionDetail(
                  label: 'Transaction ID',
                  value: 'TXN${DateTime.now().millisecondsSinceEpoch}',
                  showCopyIcon: true,
                ),
                TransactionDetail(
                  label: 'Recipient Number',
                  value: _phoneController.text,
                ),
                TransactionDetail(label: 'Network', value: selectedNetwork),
                TransactionDetail(label: 'Data Plan', value: planDescription),
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
}
