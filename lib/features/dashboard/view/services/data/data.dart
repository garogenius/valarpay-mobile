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
import 'package:valarpay/core/utils/helpers.dart';
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
  DataBeneficiary? _selectedBeneficiary;
  bool _showRecentBeneficiaries = false;
  int _selectedTabIndex = 0; // 0: HOT, 1: Daily, 2: Weekly, 3: Monthly

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onTextChanged);
    _amountController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dataBeneficiaryNotifierProvider.notifier)
          .getDataBeneficiaries();
      
      // Fetch PalmPay billers (networks)
      ref.read(dataProvidersNotifierProvider.notifier).fetchProviders().then((_) {
        final state = ref.read(dataProvidersNotifierProvider);
        if (state.isDataAvailable && state.data!.isNotEmpty) {
           final providers = state.data!;
           final selectedNetwork = ref.read(dataSelectedNetworkProvider);
           
           NetworkProvider? currentPlan;
           try {
             currentPlan = providers.firstWhere((p) => 
               p.network.toLowerCase().contains(selectedNetwork.toLowerCase()) || 
               selectedNetwork.toLowerCase().contains(p.network.toLowerCase())
             );
           } catch (_) {}

           if (currentPlan != null) {
              ref.read(dataSelectedNetworkProvider.notifier).state = currentPlan.network;
              ref.read(dataSelectedBillerIdProvider.notifier).state = currentPlan.billerId;
              ref.read(dataSelectedOperatorIdProvider.notifier).state = currentPlan.operatorId;
              final currentCategory = ['HOT', 'Daily', 'Weekly', 'Monthly'][_selectedTabIndex];
               ref.read(dataVariationNotifierProvider.notifier).getVariation(
                 network: currentPlan.network,
                 operatorId: currentPlan.operatorId,
                 billerId: currentPlan.billerId,
                 filterCategory: currentCategory,
               );
            }
        }
      });
    });
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onTextChanged);
    _amountController.removeListener(_onTextChanged);
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _assetForProvider(String network) {
    final n = network.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (n.contains('mtn')) return 'assets/images/mtn.png';
    if (n.contains('airtel')) return 'assets/images/airtel.png';
    if (n.contains('9mobile') || n.contains('etisalat') || n.contains('ethysalat') || n.contains('9'))
      return 'assets/images/9mobile.png';
    if (n.contains('glo')) return 'assets/images/glo.png';
    // fallback
    return 'assets/images/default.png';
  }


  bool _isFormValid() {
    final selectedNetwork = ref.watch(dataSelectedNetworkProvider);
    final selectedPlan = ref.watch(dataSelectedPlanProvider);

    return _phoneController.text.trim().isNotEmpty &&
        _amountController.text.trim().isNotEmpty &&
        _amountController.text.trim() != '0' &&
        selectedNetwork.isNotEmpty &&
        selectedPlan.isNotEmpty;
  }

  String _formatTo11(String raw) {
    if (raw.isEmpty) return raw;
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('234')) {
      final rest = digits.substring(3);
      if (rest.length == 10) return '0$rest';
      if (rest.length == 11 && rest.startsWith('0')) return rest;
      if (rest.length > 10) return '0' + rest.substring(rest.length - 10);
    }
    if (digits.length == 11 && digits.startsWith('0')) return digits;
    if (digits.length == 10) return '0$digits';
    if (digits.length > 11) return '0' + digits.substring(digits.length - 10);
    return digits;
  }

  void _detectNetworkProvider(String phoneNumber) {
    final formatted = _formatTo11(phoneNumber);
    final cleanedPhone = formatted.replaceAll(RegExp(r'\D'), '');

    if (cleanedPhone.length >= 4) {
      final providers = ref.read(dataProvidersNotifierProvider).data ?? [];
      if (providers.isNotEmpty) {
        final prefix = formatted.substring(0, 4);
        
        String? detectedBillerId;
        
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
              ref.read(dataSelectedNetworkProvider.notifier).state = p.network;
              ref.read(dataSelectedOperatorIdProvider.notifier).state = p.operatorId;
              ref.read(dataSelectedBillerIdProvider.notifier).state = p.billerId;
            }
            
            if (mounted) setState(() {});
          } catch (e) {
            // Log or ignore
          }
        }
      }
      
      if (cleanedPhone.length == 11) {
        ref.read(dataPlansNotifierProvider.notifier).getPlans(
          phone: formatted, 
          currency: 'NGN',
        ).then((_) {
          final plans = ref.read(dataPlansNotifierProvider).data;
          // In PalmPay if we get back targeted plan info, we can auto-select its operator. 
          // Often the current setup simply needs us to know the phone is valid, and fetch variations
          final network = ref.read(dataSelectedNetworkProvider);
          final operatorId = ref.read(dataSelectedOperatorIdProvider);
          final billerId = ref.read(dataSelectedBillerIdProvider);
          if (network.isNotEmpty) {
               final currentCategory = ['HOT', 'Daily', 'Weekly', 'Monthly'][_selectedTabIndex];
               ref.read(dataVariationNotifierProvider.notifier).getVariation(
                 network: network,
                 operatorId: operatorId,
                 billerId: billerId,
                 filterCategory: currentCategory,
               );
          }
        }).catchError((e) {
          // Log or handle
        });
      }

    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false) || (user?.wallets.isNotEmpty ?? false);
    final selectedNetwork = ref.watch(dataSelectedNetworkProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Data',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC verification to purchase data',
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
                                          color: Colors.transparent,
                                        ),
                                        child: ClipOval(
                                          child: Builder(
                                            builder: (context) {
                                              final plans = ref.watch(dataProvidersNotifierProvider).data ?? [];
                                              final selectedBillerId = ref.watch(dataSelectedBillerIdProvider);
                                              
                                              String? iconUrl;
                                                try {
                                                  iconUrl = plans.firstWhere((p) {
                                                    // Ensure we are matching on non-empty, meaningful values
                                                    if (selectedBillerId != null && selectedBillerId != '' && p.billerId == selectedBillerId) return true;
                                                    if (selectedNetwork != '' && p.network.toLowerCase() == selectedNetwork.toLowerCase()) return true;
                                                    return false;
                                                  }).billerIcon;
                                                } catch (_) {}

                                              if (iconUrl != null && iconUrl.isNotEmpty) {
                                                return Image.network(
                                                  iconUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, o, s) => Image.asset(_assetForProvider(selectedNetwork)),
                                                );
                                              }
                                              return Image.asset(
                                                _assetForProvider(selectedNetwork),
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, o, s) => Container(
                                                  color: Colors.grey,
                                                  child: const Icon(Icons.cell_wifi, size: 20, color: Colors.white),
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
                                      ),
                                    ),
                                    onChanged: (v) => _detectNetworkProvider(v),
                                  ),
                                ),
                                // Contact Picker
                                GestureDetector(
                                  onTap: _showContactAccessDialog,
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

                          // Data Plans Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Data Plans',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              // Row(
                              //   children: [
                              //     Icon(Icons.grid_view, color: AppColors.primaryColor, size: 20),
                              //     const SizedBox(width: 8),
                              //     Icon(Icons.grid_view_rounded, color: Colors.grey, size: 20),
                              //   ],
                              // ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tabs
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ['HOT', 'Daily', 'Weekly', 'Monthly'].asMap().entries.map((entry) {
                                final index = entry.key;
                                final title = entry.value;
                                final isSelected = _selectedTabIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTabIndex = index;
                                    });
                                    // Fetch plans for the selected category if network is selected
                                    final network = ref.read(dataSelectedNetworkProvider);
                                    if (network.isNotEmpty) {
                                      final operatorId = ref.read(dataSelectedOperatorIdProvider);
                                      final billerId = ref.read(dataSelectedBillerIdProvider);
                                      final category = ['HOT', 'Daily', 'Weekly', 'Monthly'][index];
                                      ref.read(dataVariationNotifierProvider.notifier)
                                          .getVariation(
                                            network: network,
                                            operatorId: operatorId > 0 ? operatorId : null,
                                            billerId: billerId,
                                            filterCategory: category,
                                          );
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 24),
                                    child: Column(
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                            color: isSelected ? AppColors.primaryColor : Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (isSelected)
                                          Container(
                                            height: 3,
                                            width: 20,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Plans Grid
                          _buildPlansGrid(isDark),
                          const SizedBox(height: 24),
                          const DataServicesSection(),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Payment Section
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
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 'Total Amount',
                                 style: TextStyle(
                                   color: Colors.grey,
                                   fontSize: 12,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               Text(
                                 currencyFormatter(_amountController.text),
                                 style: TextStyle(
                                   color: isDark ? Colors.white : Colors.black,
                                   fontSize: 24,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ],
                           ),
                         ),
                        SizedBox(
                          height: 50,
                          width: 120,
                          child: ElevatedButton(
                            onPressed: _isFormValid() ? _handleContinue : null,
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

  Widget _buildPlansGrid(bool isDark) {
    final variationState = ref.watch(dataVariationNotifierProvider);
    final bundles = variationState.data ?? <DataPlanBundle>[];
    
    if (variationState.isInitialLoading) {
      return const SizedBox.shrink();
    }

    if (bundles.isEmpty) {
       return Container(
         width: double.infinity,
         padding: const EdgeInsets.all(32),
         child: Column(
            children: [
                Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Select a network provider above to see plans', style: TextStyle(color: Colors.grey)),
            ]
         )
       );
    }

    // Use bundles directly as they are now filtered by category at the API level
    List<DataPlanBundle> filteredBundles = bundles;
    
    if (filteredBundles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('No plans in this category')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75, 
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredBundles.length,
      itemBuilder: (context, index) {
        final bundle = filteredBundles[index];
        final isSelected = ref.watch(dataSelectedPlanProvider) == bundle.id;

        return GestureDetector(
          onTap: () {
             ref.read(dataSelectedPlanProvider.notifier).state = bundle.id;
             
             if (bundle.operatorId != null && bundle.operatorId! > 0) {
                ref.read(dataSelectedOperatorIdProvider.notifier).state = bundle.operatorId!;
             }

             setState(() {
                _amountController.text = bundle.amount.toStringAsFixed(0);
             });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isSelected 
                  ? Border.all(color: AppColors.primaryColor, width: 1.5)
                  : Border.all(color: Colors.transparent),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    bundle.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bundle.validity,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter(bundle.amount.toStringAsFixed(0)),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                   decoration: BoxDecoration(
                     color: AppColors.primaryColor.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(4),
                   ),
                   child: Text(
                     '₦${(bundle.amount * 0.01).toStringAsFixed(1)} Cashback',
                     style: const TextStyle(
                       color: AppColors.primaryColor,
                       fontSize: 10,
                       fontWeight: FontWeight.bold,
                     ),
                     textAlign: TextAlign.center,
                   ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProviderModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final providersState = ref.watch(dataProvidersNotifierProvider);
        final providers = providersState.data ?? [];
        final selectedNetwork = ref.watch(dataSelectedNetworkProvider);

        // Filter out invalid/empty providers
        final filteredProviders = providers.where((p) => p.network.trim().isNotEmpty).toList(); 
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              if (providersState.isInitialLoading)
                const Center(child: CircularProgressIndicator())
              else
                 Flexible(
                   child: ListView.builder(
                     shrinkWrap: true,
                     itemCount: filteredProviders.length,
                     itemBuilder: (context, index) {
                       final p = filteredProviders[index];
                       final isSelected = selectedNetwork.toLowerCase() == p.network.toLowerCase();
                       return InkWell(
                         onTap: () async {
                           ref.read(dataSelectedNetworkProvider.notifier).state = p.network;
                           ref.read(dataSelectedBillerIdProvider.notifier).state = p.billerId;
                           ref.read(dataSelectedOperatorIdProvider.notifier).state = p.operatorId;
                           ref.read(dataSelectedPlanProvider.notifier).state = '';
                           
                           // Close modal immediately to avoid context issues and show immediate response
                           Navigator.pop(context);
                           
                           // Trigger variation fetch with network name and current category
                           final currentCategory = ['HOT', 'Daily', 'Weekly', 'Monthly'][_selectedTabIndex];
                           ref.read(dataVariationNotifierProvider.notifier)
                                .getVariation(
                                  network: p.network,
                                  operatorId: p.operatorId,
                                  billerId: p.billerId,
                                  filterCategory: currentCategory,
                                );
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
                                   p.planName, 
                                   style: TextStyle(
                                     color: isDark ? Colors.white : Colors.black,
                                     fontSize: 18,
                                     fontWeight: FontWeight.w500,
                                   ),
                                 ),
                                 const Spacer(),
                                 Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? AppColors.primaryColor : Colors.grey,
                                        width: 2,
                                      ),
                                      color: isSelected ? AppColors.primaryColor : Colors.transparent,
                                    ),
                                    child: isSelected 
                                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                                        : null,
                                  ),
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

  Widget _buildRecentBeneficiariesDropdown() {
    final state = ref.watch(dataBeneficiaryNotifierProvider);
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                            b.network!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.close, size: 16, color: Colors.grey),
                      ],
                    ),
                    onTap: () async {
                      setState(() {
                        _phoneController.text = b.phoneNumber;
                        _showRecentBeneficiaries = false;
                      });
                      
                      if (b.network != null) {
                        final providers = ref.read(dataPlansNotifierProvider).data ?? [];
                        String? billerId;
                        try {
                           billerId = providers.firstWhere((p) => p.network.toLowerCase() == b.network!.toLowerCase()).billerId;
                        } catch (_) {}

                        ref.read(dataSelectedNetworkProvider.notifier).state = b.network!;
                        ref.read(dataSelectedBillerIdProvider.notifier).state = billerId;
                        if (b.operatorId != null) {
                          ref.read(dataSelectedOperatorIdProvider.notifier).state = b.operatorId!;
                        }
                        ref.read(dataSelectedPlanProvider.notifier).state = '';
                        
                        final currentCategory = ['HOT', 'Daily', 'Weekly', 'Monthly'][_selectedTabIndex];
                        await ref.read(dataVariationNotifierProvider.notifier).getVariation(
                          network: b.network!,
                          operatorId: b.operatorId,
                          billerId: billerId,
                          filterCategory: currentCategory,
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement clearAll for data beneficiaries
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
                                        _detectNetworkProvider(formatted);

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
    final bundles = ref.read(dataVariationNotifierProvider).data ?? [];
    
    // Find selected bundle to get its name/description
    final selectedBundle = bundles.firstWhere(
      (b) => b.id == selectedPlan,
      orElse: () => DataPlanBundle(id: '0', name: '₦${_amountController.text} Data', amount: double.tryParse(_amountController.text) ?? 0, validity: ''),
    );
    
    final planDescription = selectedBundle.validity.isNotEmpty 
        ? '${selectedBundle.name} ${selectedBundle.validity} Plan' 
        : selectedBundle.name;

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
    final selectedBillerId = ref.read(dataSelectedBillerIdProvider);
    final selectedPlanId = ref.read(dataSelectedPlanProvider);
    
      // manual loader removed

    try {
      final amount = double.tryParse(_amountController.text) ?? 0;

      final request = DataPurchaseRequest(
        walletPin: pin,
        amount: amount,
        operatorId: selectedOperatorId > 0 ? selectedOperatorId : null,
        billerId: selectedBillerId,
        itemId: selectedPlanId.isNotEmpty ? selectedPlanId : null,
        phone: _phoneController.text,
        currency: 'NGN',
        addBeneficiary: _saveBeneficiary,
      );

      await ref.read(dataPurchaseNotifierProvider.notifier).purchase(request);
        // manual loader removed

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

  void _navigateToReceipt() {
    final selectedNetwork = ref.read(dataSelectedNetworkProvider);
    final selectedPlan = ref.read(dataSelectedPlanProvider);
    final bundles = ref.read(dataVariationNotifierProvider).data ?? [];
    
    // Find selected bundle to get its name
    final selectedBundle = bundles.firstWhere(
      (b) => b.id.toString() == selectedPlan,
      orElse: () => DataPlanBundle(id: '0', name: '₦${_amountController.text} Data', amount: double.tryParse(_amountController.text) ?? 0, validity: ''),
    );
    
    final planDescription = selectedBundle.validity.isNotEmpty 
        ? '${selectedBundle.name} ${selectedBundle.validity} Plan' 
        : selectedBundle.name;

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
