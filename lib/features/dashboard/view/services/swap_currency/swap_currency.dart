import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';

import 'package:valarpay/features/dashboard/view/services/swap_currency/swap_currency_card.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../../../widgets/services_widgets/swap_currency_widgets/currency_selector_modal.dart';
import 'transaction_details_screen.dart';

import 'dart:async';
import 'package:valarpay/features/notifiers/currency_notifier.dart';

class SwapCurrencyScreen extends ConsumerStatefulWidget {
  const SwapCurrencyScreen({super.key});

  @override
  ConsumerState<SwapCurrencyScreen> createState() => _SwapCurrencyScreenState();
}

class _SwapCurrencyScreenState extends ConsumerState<SwapCurrencyScreen> {
  CurrencyModel fromCurrency = const CurrencyModel(
    code: 'NGN',
    name: 'Nigerian Naira',
    flagAsset: 'assets/images/nigerian.png',
    symbol: '₦',
    emoji: '🇳🇬',
  );
  CurrencyModel toCurrency = const CurrencyModel(
    code: 'USD',
    name: 'US Dollar',
    flagAsset: 'assets/images/USA.png',
    symbol: '\$',
    emoji: '🇺🇸',
  );
  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();

  bool _walletsInitialized = false;
  List<String> _allowedCurrencies = [];

  Timer? _debounce;
  String _displayRate = '';

  @override
  void initState() {
    super.initState();
    fromAmountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _fetchConversion();
    });
  }

  void _fetchConversion() {
    final amountText = fromAmountController.text;
    if (amountText.isEmpty) {
      toAmountController.text = '';
      return;
    }

    final amount = double.tryParse(amountText.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;

    final user = ref.read(userProvider);

    ref.read(currencyNotifierProvider.notifier).convertCurrency(
      amount: amount,
      fromCurrency: fromCurrency.code,
      toCurrency: toCurrency.code,
      userId: user?.id ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false) || (user?.wallets.isNotEmpty ?? false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fetch available wallets & distinct currency codes owned by the user
    final userWallets = user?.wallets ?? [];
    final userCurrencyCodes = userWallets.map((w) => w.currency.toUpperCase()).toList();

    // Persist allowed currency code list to filter dynamic modal picks
    _allowedCurrencies = userCurrencyCodes;

    // Automatically dynamically prioritize and default select active user wallets once ready
    if (!_walletsInitialized && userCurrencyCodes.length >= 2) {
      final String defaultFrom = userCurrencyCodes[0];
      final String defaultTo = userCurrencyCodes[1];

      final fromModel = supportedCurrencies.firstWhere(
        (c) => c.code.toUpperCase() == defaultFrom,
        orElse: () => supportedCurrencies.first,
      );
      final toModel = supportedCurrencies.firstWhere(
        (c) => c.code.toUpperCase() == defaultTo,
        orElse: () => supportedCurrencies.firstWhere((c) => c.code == 'USD', orElse: () => supportedCurrencies[1]),
      );

      Future.microtask(() {
        if (mounted) {
          setState(() {
            fromCurrency = fromModel;
            toCurrency = toModel;
            _walletsInitialized = true;
          });
        }
      });
    }

    ref.listen(currencyNotifierProvider, (previous, next) {
      if (next.isDataAvailable && next.singleData != null) {
        final data = next.singleData!;
        toAmountController.text = currencyFormatter(data.convertedAmount.toStringAsFixed(2), symbol: '');
        
        setState(() {
          if (data.exchangeRate < 1 && data.exchangeRate > 0) {
             _displayRate = '1 ${toCurrency.code} = ${currencyFormatter((1/data.exchangeRate).toStringAsFixed(2), symbol: '')} ${fromCurrency.code}';
          } else if (data.exchangeRate >= 1) {
             _displayRate = '1 ${fromCurrency.code} = ${currencyFormatter(data.exchangeRate.toStringAsFixed(2), symbol: '')} ${toCurrency.code}';
          } else {
             // Fallback if exchangeRate is 0 or missing, we can calculate it
             if (data.amount > 0 && data.convertedAmount > 0) {
                 double calculatedRate = data.convertedAmount / data.amount;
                 _displayRate = '1 ${fromCurrency.code} = ${currencyFormatter(calculatedRate.toStringAsFixed(2), symbol: '')} ${toCurrency.code}';
             } else {
                 _displayRate = 'Rate unavailable';
             }
          }
        });
      } else if (next.message != null && !next.isInitialLoading) {
         setState(() {
            _displayRate = next.message!;
         });
         toAmountController.text = '0.00';
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message!), backgroundColor: Colors.red));
      }
    });

    final currencyState = ref.watch(currencyNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Swap Currency',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions:
            isBvnVerified
                ? [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Saved Beneficiary',
                      style: TextStyle(color: Color(0xFFF76301), fontSize: 14),
                    ),
                  ),
                ]
                : null,
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC verification to swap currency',
            )
          : userCurrencyCodes.length < 2
              ? _buildNeedWalletsWidget(isDark)
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        CurrencyAmountInput(
                          label: "I have",
                          controller: fromAmountController,
                          currencyCode: fromCurrency.code,
                          currencySymbol: fromCurrency.symbol,
                          flagAsset: fromCurrency.flagAsset,
                          emoji: fromCurrency.emoji,
                          isEditable: true,
                          onCurrencyTap: () => _showCurrencySelector(true),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: _swapCurrencies,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF76301),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.swap_vert,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CurrencyAmountInput(
                          label: "You’ll receive",
                          controller: toAmountController,
                          currencyCode: toCurrency.code,
                          currencySymbol: toCurrency.symbol,
                          flagAsset: toCurrency.flagAsset,
                          emoji: toCurrency.emoji,
                          isEditable: false,
                          onCurrencyTap: () => _showCurrencySelector(false),
                        ),
                        SizedBox(height: 50.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rate:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            ref.watch(currencyNotifierProvider).isInitialLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Expanded(
                                    child: Text(
                                      _displayRate.isNotEmpty
                                          ? _displayRate
                                          : 'Enter amount to see rate',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transaction Fee:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '${fromCurrency.symbol} 0.00',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: fromAmountController.text.isNotEmpty &&
                                    !ref.watch(currencyNotifierProvider).isInitialLoading
                                ? () {
                                    final conversionState = ref.read(currencyNotifierProvider);
                                    final rate = conversionState.singleData?.exchangeRate ?? 1.0;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SwapCurrencyTransactionDetailsScreen(
                                          transactionData: {
                                            'fromCurrency': fromCurrency.code,
                                            'toCurrency': toCurrency.code,
                                            'fromAmount': fromAmountController.text,
                                            'toAmount': toAmountController.text,
                                            'exchangeRate': rate.toString(),
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF76301),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Continue',
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
                ),
    );
  }

  void _swapCurrencies() {
    setState(() {
      CurrencyModel temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;

      // Recalculate amounts
      _fetchConversion();
    });
  }

  void _showCurrencySelector(bool isFromCurrency) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencySelectorModal(
        selectedCurrency: isFromCurrency ? fromCurrency.code : toCurrency.code,
        allowedCurrencies: _allowedCurrencies, // Pass our calculated valid filter
        onCurrencySelected: (currency) {
          setState(() {
            if (isFromCurrency) {
              fromCurrency = currency;
            } else {
              toCurrency = currency;
            }
            _fetchConversion();
          });
        },
      ),
    );
  }

  Widget _buildNeedWalletsWidget(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF76301).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: Color(0xFFF76301),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Multiple Accounts Needed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Currency swapping is available only if you have opened more than one currency account. You can convert funds seamlessly between them once they are created!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF76301),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
// import 'package:valarpay/features/providers/user_provider.dart';
// import '../../../widgets/services_widgets/swap_currency_widgets/currency_selector_modal.dart';
// import 'transaction_details_screen.dart';

// class SwapCurrencyScreen extends ConsumerStatefulWidget {
//   const SwapCurrencyScreen({super.key});

//   @override
//   ConsumerState<SwapCurrencyScreen> createState() => _SwapCurrencyScreenState();
// }

// class _SwapCurrencyScreenState extends ConsumerState<SwapCurrencyScreen> {
//   String fromCurrency = 'NGN';
//   String toCurrency = 'USD';
//   final TextEditingController fromAmountController = TextEditingController();
//   final TextEditingController toAmountController = TextEditingController();

//   double exchangeRate = 1650.0; // NGN to USD rate

//   @override
//   void initState() {
//     super.initState();
//     fromAmountController.addListener(_calculateToAmount);
//   }

//   void _calculateToAmount() {
//     if (fromAmountController.text.isNotEmpty) {
//       try {
//         double fromAmount = double.parse(fromAmountController.text);
//         double toAmount = fromAmount / exchangeRate;
//         toAmountController.text = toAmount.toStringAsFixed(2);
//       } catch (e) {
//         toAmountController.text = '';
//       }
//     } else {
//       toAmountController.text = '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(userProvider);
//     final isBvnVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false) || (user?.wallets.isNotEmpty ?? false);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? Colors.black : Colors.white,
//       appBar: AppBar(
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: isDark ? Colors.white : Colors.black,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Swap Currency',
//           style: TextStyle(
//             color: isDark ? Colors.white : Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions:
//             !isBvnVerified
//                 // isBvnVerified
//                 ? [
//                   TextButton(
//                     onPressed: () {
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder:
//                       //         (context) => SavedBeneficiaryScreen(
//                       //           onSelectBeneficiary: (beneficiary) {
//                       //             setState(() {
//                       //               _meterNumberController.text =
//                       //                   beneficiary.meterNumber;
//                       //             });
//                       //             // Verify meter number
//                       //             if (ref.read(
//                       //                   electricitySelectedMeterTypeProvider,
//                       //                 ) !=
//                       //                 null) {
//                       //               _verifyMeterNumber();
//                       //             }
//                       //           },
//                       //         ),
//                       //   ),
//                       // );
//                     },
//                     child: const Text(
//                       'Saved Beneficiary',
//                       style: TextStyle(color: Color(0xFFF76301), fontSize: 14),
//                     ),
//                   ),
//                 ]
//                 : null,
//       ),
//       body:
//           isBvnVerified
//               ? const KycNotSetWidget(
//                 title: 'KYC Not Completed',
//                 subtitle: 'Complete your KYC verification to swap currency',
//               )
//               : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Exchange Rate Info
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color:
//                             isDark ? const Color(0xFF2B2725) : Colors.grey[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Exchange Rate',
//                             style: TextStyle(
//                               color: isDark ? Colors.white70 : Colors.grey[600],
//                               fontSize: 14,
//                             ),
//                           ),
//                           Text(
//                             '1 USD = ₦${exchangeRate.toStringAsFixed(0)}',
//                             style: TextStyle(
//                               color: isDark ? Colors.white : Colors.black,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // From Currency Section
//                     Text(
//                       'From',
//                       style: TextStyle(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color:
//                             isDark ? const Color(0xFF2B2725) : Colors.grey[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               GestureDetector(
//                                 onTap: () => _showCurrencySelector(true),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: isDark ? Colors.black : Colors.white,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       _getCurrencyFlag(fromCurrency),
//                                       const SizedBox(width: 8),
//                                       Text(
//                                         fromCurrency,
//                                         style: TextStyle(
//                                           color:
//                                               isDark
//                                                   ? Colors.white
//                                                   : Colors.black,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Icon(
//                                         Icons.keyboard_arrow_down,
//                                         color:
//                                             isDark
//                                                 ? Colors.white70
//                                                 : Colors.grey[600],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               const Spacer(),
//                               Text(
//                                 _getCurrencyName(fromCurrency),
//                                 style: TextStyle(
//                                   color:
//                                       isDark
//                                           ? Colors.white70
//                                           : Colors.grey[600],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           TextField(
//                             controller: fromAmountController,
//                             keyboardType: TextInputType.number,
//                             style: TextStyle(
//                               color: isDark ? Colors.white : Colors.black,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             decoration: InputDecoration(
//                               hintText: '0.00',
//                               hintStyle: TextStyle(
//                                 color:
//                                     isDark ? Colors.white38 : Colors.grey[400],
//                                 fontSize: 24,
//                               ),
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // Swap Button
//                     Center(
//                       child: GestureDetector(
//                         onTap: _swapCurrencies,
//                         child: Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF76301),
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                           child: const Icon(
//                             Icons.swap_vert,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // To Currency Section
//                     Text(
//                       'To',
//                       style: TextStyle(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color:
//                             isDark ? const Color(0xFF2B2725) : Colors.grey[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               GestureDetector(
//                                 onTap: () => _showCurrencySelector(false),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: isDark ? Colors.black : Colors.white,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       _getCurrencyFlag(toCurrency),
//                                       const SizedBox(width: 8),
//                                       Text(
//                                         toCurrency,
//                                         style: TextStyle(
//                                           color:
//                                               isDark
//                                                   ? Colors.white
//                                                   : Colors.black,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Icon(
//                                         Icons.keyboard_arrow_down,
//                                         color:
//                                             isDark
//                                                 ? Colors.white70
//                                                 : Colors.grey[600],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               const Spacer(),
//                               Text(
//                                 _getCurrencyName(toCurrency),
//                                 style: TextStyle(
//                                   color:
//                                       isDark
//                                           ? Colors.white70
//                                           : Colors.grey[600],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           TextField(
//                             controller: toAmountController,
//                             readOnly: true,
//                             style: TextStyle(
//                               color: isDark ? Colors.white : Colors.black,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             decoration: InputDecoration(
//                               hintText: '0.00',
//                               hintStyle: TextStyle(
//                                 color:
//                                     isDark ? Colors.white38 : Colors.grey[400],
//                                 fontSize: 24,
//                               ),
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const Spacer(),

//                     // Continue Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed:
//                             fromAmountController.text.isNotEmpty
//                                 ? () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder:
                                  //         (context) =>
                                  //             SwapCurrencyTransactionDetailsScreen(
                                  //               transactionData: {
                                  //                 'fromCurrency': fromCurrency,
                                  //                 'toCurrency': toCurrency,
                                  //                 'fromAmount':
                                  //                     fromAmountController.text,
                                  //                 'toAmount':
                                  //                     toAmountController.text,
                                  //                 'exchangeRate':
                                  //                     exchangeRate.toString(),
                                  //               },
                                  //             ),
                                  //   ),
                                  // );
//                                 }
//                                 : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFF76301),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text(
//                           'Continue',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }

//   Widget _getCurrencyFlag(String currency) {
//     Color flagColor;
//     switch (currency) {
//       case 'NGN':
//         flagColor = Colors.green;
//         break;
//       case 'USD':
//         flagColor = Colors.blue;
//         break;
//       case 'EUR':
//         flagColor = Colors.blue;
//         break;
//       case 'GBP':
//         flagColor = Colors.red;
//         break;
//       default:
//         flagColor = Colors.grey;
//     }

//     return Container(
//       width: 24,
//       height: 16,
//       decoration: BoxDecoration(
//         color: flagColor,
//         borderRadius: BorderRadius.circular(2),
//       ),
//     );
//   }

//   String _getCurrencyName(String currency) {
//     switch (currency) {
//       case 'NGN':
//         return 'Nigerian Naira';
//       case 'USD':
//         return 'US Dollar';
//       case 'EUR':
//         return 'Euro';
//       case 'GBP':
//         return 'British Pound';
//       default:
//         return currency;
//     }
//   }

//   void _swapCurrencies() {
//     setState(() {
//       String temp = fromCurrency;
//       fromCurrency = toCurrency;
//       toCurrency = temp;

//       // Update exchange rate
//       if (fromCurrency == 'USD' && toCurrency == 'NGN') {
//         exchangeRate = 1650.0;
//       } else if (fromCurrency == 'NGN' && toCurrency == 'USD') {
//         exchangeRate = 1650.0;
//       }

//       // Recalculate amounts
//       _calculateToAmount();
//     });
//   }

//   void _showCurrencySelector(bool isFromCurrency) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder:
//           (context) => CurrencySelectorModal(
//             selectedCurrency: isFromCurrency ? fromCurrency : toCurrency,
//             onCurrencySelected: (currency) {
//               setState(() {
//                 if (isFromCurrency) {
//                   fromCurrency = currency;
//                 } else {
//                   toCurrency = currency;
//                 }
//                 _calculateToAmount();
//               });
//             },
//           ),
//     );
//   }

//   @override
//   void dispose() {
//     fromAmountController.dispose();
//     toAmountController.dispose();
//     super.dispose();
//   }
// }
