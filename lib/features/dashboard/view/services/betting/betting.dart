// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:valarpay/core/utils/currency_formatter.dart';
// import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
// import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
// import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
// import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
// import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
// import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
// import 'package:valarpay/core/widgets/transaction_details_screen.dart';
// import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
// import 'package:valarpay/features/dashboard/widgets/services_widgets/betting_widgets/provider_selector_modal.dart';
// import 'package:valarpay/features/providers/user_provider.dart';
// import 'saved_beneficiary_screen.dart';

// class BettingScreen extends ConsumerStatefulWidget {
//   const BettingScreen({super.key});

//   @override
//   ConsumerState<BettingScreen> createState() => _BettingScreenState();
// }

// class _BettingScreenState extends ConsumerState<BettingScreen> {
//   String selectedProvider = 'Bet9ja';
//   final TextEditingController userIdController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//   bool saveBeneficiary = false;

//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(userProvider);
//     final isBvnVerified = user?.isBvnVerified ?? false;
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Betting',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//         actions:
//             isBvnVerified
//                 ? [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) =>
//                                   const BettingSavedBeneficiaryScreen(),
//                         ),
//                       );
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
//           !isBvnVerified
//               ? const KycNotSetWidget(
//                 title: 'KYC Not Completed',
//                 subtitle:
//                     'Complete your KYC verification to fund betting accounts',
//               )
//               : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Select Provider
//                     Text(
//                       'Select Provider',
//                       style: TextStyle(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     GestureDetector(
//                       onTap: () => _showProviderSelector(context),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).cardColor.withOpacity(0.4),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               selectedProvider,
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             Icon(
//                               Icons.keyboard_arrow_down,
//                               color: isDark ? Colors.white70 : Colors.grey[600],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // User ID
//                     Text(
//                       'User ID',
//                       style: TextStyle(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     ReuseableTextFieldWithCountry(
//                       textInputType: TextInputType.phone,
//                       isReadOnly: false,
//                       hintText: '123 456 789',
//                       controller: userIdController,
//                       showCountryLabel: false,
//                     ),
//                     const SizedBox(height: 24),

//                     // Amount
//                     Text(
//                       'Amount',
//                       style: TextStyle(
//                         color: isDark ? Colors.white70 : Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     ReuseableAmountTextfield(
//                       amountController: amountController,
//                       prefixText: '₦',
//                       hintText: '500',
//                     ),

//                     const SizedBox(height: 50),

//                     // Continue Button
//                     FullWidthButton(
//                       text: 'Continue',
//                       onPressed: () {
//                         if (userIdController.text.isNotEmpty &&
//                             amountController.text.isNotEmpty) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (context) =>
//                                       ReuseableTransactionDetailsScreen(
//                                         totalAmount: double.parse(amountController.text),
//                                         saveBeneficiary: saveBeneficiary,
//                                         onSaveBeneficiaryChanged: (value) {
//                                           setState(() {
//                                             saveBeneficiary = value;
//                                           });
//                                         },
//                                         hasBottom: false,
//                                         topTitleText: 'Transaction',
//                                         topTransactionsDetailsList: [
//                                           buildDetailRow(
//                                             'Recipient ID',
//                                             userIdController.text,
//                                             isDark,
//                                           ),
//                                           buildDetailRow(
//                                             'Provider',
//                                             selectedProvider,
//                                             isDark,
//                                           ),
//                                           buildDetailRow(
//                                             'Amount',
//                                             currencyFormatter(
//                                               amountController.text,
//                                             ),
//                                             isDark,
//                                           ),
//                                         ],
//                                         onButtonPressed: _handlePinEntry,
//                                         onBiometricButtonPressed: _handleBiometricPinEntry,
//                                       ),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }

//   _handlePinEntry() async {
//     final pin = await TransactionPinModal.show(context);
//     if (pin != null && pin.length == 4) {
//       if (mounted) Navigator.pop(context);
//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) => TransactionReceiptWidget(
//                   headerText: 'Transaction',
//                   amount: amountController.text,
//                   topDetails: [
//                     TransactionDetail(
//                       label: 'Transaction ID',
//                       value: 'TXN${DateTime.now().millisecondsSinceEpoch}',
//                       showCopyIcon: true,
//                     ),
//                     TransactionDetail(
//                       label: 'Recipient ID',
//                       value: userIdController.text,
//                     ),
//                     TransactionDetail(
//                       label: 'Provider',
//                       value: selectedProvider,
//                     ),
//                     TransactionDetail(
//                       label: 'Payment Source',
//                       value: 'ValarPay Account',
//                     ),
//                     TransactionDetail(
//                       label: 'Date & Time',
//                       value: '29 Sep 2025 | 8:15 pm',
//                     ),
//                   ],
//                   onShareReceipt: () {},
//                 ),
//           ),
//         );
//       }
//     }
//   }


// _handleBiometricPinEntry() async {
//     final pin = await BiometricTransactionPinModal.show(context);
//     if (pin != null && pin.length == 4) {
//       if (mounted) Navigator.pop(context);
//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) => TransactionReceiptWidget(
//                   headerText: 'Transaction',
//                   amount: amountController.text,
//                   topDetails: [
//                     TransactionDetail(
//                       label: 'Transaction ID',
//                       value: 'TXN${DateTime.now().millisecondsSinceEpoch}',
//                       showCopyIcon: true,
//                     ),
//                     TransactionDetail(
//                       label: 'Recipient ID',
//                       value: userIdController.text,
//                     ),
//                     TransactionDetail(
//                       label: 'Provider',
//                       value: selectedProvider,
//                     ),
//                     TransactionDetail(
//                       label: 'Payment Source',
//                       value: 'ValarPay Account',
//                     ),
//                     TransactionDetail(
//                       label: 'Date & Time',
//                       value: '29 Sep 2025 | 8:15 pm',
//                     ),
//                   ],
//                   onShareReceipt: () {},
//                 ),
//           ),
//         );
//       }
//     }
//   }

 
//   void _showProviderSelector(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder:
//           (context) => BettingProviderSelectorModal(
//             selectedProvider: selectedProvider,
//             onProviderSelected: (provider) {
//               setState(() {
//                 selectedProvider = provider;
//               });
//             },
//           ),
//     );
//   }
// }
