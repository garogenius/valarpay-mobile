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
  CurrencyModel fromCurrency = CurrencyModel(
    code: 'NGN',
    name: 'Nigerian Naira',
    flagAsset: 'assets/images/nigerian.png',
    symbol: '#',
  );
  CurrencyModel toCurrency = CurrencyModel(
    code: 'USD',
    name: 'US Dollar',
    flagAsset: 'assets/images/USA.png',
    symbol: '\$',
  );
  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();

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

    ref.read(currencyNotifierProvider.notifier).convertCurrency(
      amount: amount,
      fromCurrency: fromCurrency.code,
      toCurrency: toCurrency.code,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(currencyNotifierProvider, (previous, next) {
      print('[SwapCurrencyScreen] State changed. isDataAvailable: ${next.isDataAvailable}');
      if (next.isDataAvailable && next.singleData != null) {
        final data = next.singleData!;
        print('[SwapCurrencyScreen] Conversion result: ${data.convertedAmount}');
        toAmountController.text = currencyFormatter(data.convertedAmount.toStringAsFixed(2), symbol: '');
        
        setState(() {
          // The API parameters are swapped to handle backend inversion, 
          // so we use local state currencies for correct display.
          // data.rate is the multiplier used (approximately).
          
          if (data.exchangeRate < 1 && data.exchangeRate > 0) {
             // Rate is like 0.0007. 1/rate is ~1400.
             // We want "1 USD = 1400 NGN"
             // In our swapped context: 
             // Request was USD->NGN. Result ~0.0007.
             // User view is NGN->USD.
             // We want to show "1 USD = 1400 NGN".
             // USD is 'toCurrency' in UI. NGN is 'fromCurrency' in UI.
             // Display: 1 {to} = {1/rate} {from}
             _displayRate = '1 ${toCurrency.code} = ${currencyFormatter((1/data.exchangeRate).toStringAsFixed(2), symbol: '')} ${fromCurrency.code}';
          } else {
             // Rate is > 1. e.g. 1400.
             // User view USD->NGN.
             // Request NGN->USD. Result ~1400.
             // We want "1 USD = 1400 NGN".
             // USD is 'fromCurrency' in UI.
             // Display: 1 {from} = {rate} {to}
             _displayRate = '1 ${fromCurrency.code} = ${currencyFormatter(data.exchangeRate.toStringAsFixed(2), symbol: '')} ${toCurrency.code}';
          }
        });
      } else if (next.message != null && !next.isInitialLoading) {
         // Optionally handle error
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
      body:
          !isBvnVerified
              ? const KycNotSetWidget(
                title: 'KYC Not Completed',
                subtitle: 'Complete your KYC verification to swap currency',
              )
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
                            : Text(
                                _displayRate.isNotEmpty
                                    ? _displayRate
                                    : 'Enter amount to see rate',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 16, // Reduced slightly to fit
                                  fontWeight: FontWeight.w600,
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
      builder:
          (context) => CurrencySelectorModal(
            selectedCurrency:
                isFromCurrency ? fromCurrency.code : toCurrency.code,
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
//     final isBvnVerified = user?.isBvnVerified ?? false;
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
