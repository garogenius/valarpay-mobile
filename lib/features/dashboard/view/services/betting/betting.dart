import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/features/dashboard/widgets/services_widgets/betting_widgets/provider_selector_modal.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/betting_notifier.dart';
import 'package:valarpay/features/models/betting_models.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/features/models/beneficiary_models.dart';
import 'saved_beneficiary_screen.dart';

class BettingScreen extends ConsumerStatefulWidget {
  const BettingScreen({super.key});

  @override
  ConsumerState<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends ConsumerState<BettingScreen> {
  BettingPlatformModel? selectedPlatform;
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool saveBeneficiary = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bettingPlatformsNotifierProvider.notifier).fetchPlatforms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final platformsState = ref.watch(bettingPlatformsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Betting',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: null,
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC verification to fund betting accounts',
            )
          : CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
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
                          onTap: () {
                            if (platformsState.isDataAvailable) {
                              _showProviderSelector(context, platformsState.data ?? []);
                            } else if (platformsState.isInitialLoading) {
                              AppMessenger.show(context, message: 'Loading platforms...', type: MessageType.info);
                            } else {
                               ref.read(bettingPlatformsNotifierProvider.notifier).fetchPlatforms();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedPlatform?.name ?? 'Select Provider',
                                  style: const TextStyle(fontSize: 16),
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

                        // User ID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'User ID',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BettingSavedBeneficiaryScreen(),
                                  ),
                                );

                                if (result is Beneficiary && mounted) {
                                  setState(() {
                                    userIdController.text = result.accountNumber ?? '';
                                    final platforms = ref.read(bettingPlatformsNotifierProvider).data;
                                    if (platforms != null) {
                                      try {
                                        selectedPlatform = platforms.firstWhere(
                                          (p) => p.name.toLowerCase() == result.accountName?.toLowerCase() ||
                                                 p.code.toLowerCase() == result.accountName?.toLowerCase()
                                        );
                                      } catch (_) {}
                                    }
                                  });
                                }
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
                          textInputType: TextInputType.text,
                          isReadOnly: false,
                          hintText: '123 456 789',
                          controller: userIdController,
                          showCountryLabel: false,
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
                          amountController: amountController,
                          prefixText: '₦',
                          hintText: '500',
                        ),

                        const Spacer(),

                        // Continue Button
                        FullWidthButton(
                          text: 'Continue',
                          isEnabled: selectedPlatform != null &&
                              userIdController.text.isNotEmpty &&
                              amountController.text.isNotEmpty,
                          onPressed: () => _navigateToConfirmation(context, isDark),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            )
    );
  }

  void _navigateToConfirmation(BuildContext context, bool isDark) {
    if (selectedPlatform == null) return;
    
    final amount = double.tryParse(amountController.text.replaceAll(',', '')) ?? 0.0;
    
    if (amount < selectedPlatform!.minAmount) {
      AppMessenger.show(context, message: 'Minimum amount is ₦${selectedPlatform!.minAmount}', type: MessageType.error);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReuseableTransactionDetailsScreen(
          totalAmount: amount,
          saveBeneficiary: saveBeneficiary,
          onSaveBeneficiaryChanged: (value) {
            setState(() => saveBeneficiary = value);
          },
          hasBottom: false,
          topTitleText: 'Transaction',
          topTransactionsDetailsList: [
            buildDetailRow('Recipient ID', userIdController.text, isDark),
            buildDetailRow('Provider', selectedPlatform!.name, isDark),
            buildDetailRow('Amount', '₦${currencyFormatter(amount.toString())}', isDark),
          ],
          onButtonPressed: () => _handlePinEntry(context, amount),
          onBiometricButtonPressed: () => _handleBiometricEntry(context, amount),
        ),
      ),
    );
  }

  Future<void> _handlePinEntry(BuildContext context, double amount) async {
    final pin = await TransactionPinModal.show(context);
    if (pin != null && pin.length == 4) {
      _processPayment(context, pin, amount);
    }
  }

  Future<void> _handleBiometricEntry(BuildContext context, double amount) async {
    // Biometric logic would go here, for now let's just use pin if biometric fails or isn't fully implemented here
    final pin = await TransactionPinModal.show(context);
    if (pin != null && pin.length == 4) {
      _processPayment(context, pin, amount);
    }
  }

  Future<void> _processPayment(BuildContext context, String pin, double amount) async {
    final request = BettingPayRequest(
      platform: selectedPlatform!.code,
      platformUserId: userIdController.text,
      amount: amount,
      walletPin: pin,
      description: 'Funding ${selectedPlatform!.name} account',
      addBeneficiary: saveBeneficiary,
    );

    // manual loader removed

    await ref.read(bettingPayNotifierProvider.notifier).payBetting(request);
    
    if (mounted) {
      final state = ref.read(bettingPayNotifierProvider);
      if (state.isDataAvailable && state.data != null) {
        final response = state.data!.first;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionReceiptWidget(
              headerText: 'Betting',
              amount: amount.toString(),
              topDetails: [
                TransactionDetail(label: 'Transaction ID', value: response.transactionRef, showCopyIcon: true),
                TransactionDetail(label: 'Recipient ID', value: response.platformUserId),
                TransactionDetail(label: 'Provider', value: response.platform),
                TransactionDetail(label: 'Payment Source', value: 'ValarPay Account'),
                TransactionDetail(label: 'Date & Time', value: '${DateTime.now().day} ${_getMonth(DateTime.now().month)}, ${DateTime.now().year} | ${_formatTime(DateTime.now())}'),
              ],
            ),
          ),
        );
      } else {
        AppMessenger.show(context, message: state.message ?? 'Payment failed', type: MessageType.error);
      }
    }
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'pm' : 'am';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  void _showProviderSelector(BuildContext context, List<BettingPlatformModel> platforms) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BettingProviderSelectorModal(
        platforms: platforms,
        selectedPlatform: selectedPlatform,
        onPlatformSelected: (platform) {
          setState(() {
            selectedPlatform = platform;
          });
        },
      ),
    );
  }
}
