// import 'package:flutter/material.dart';
// import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
// import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
// import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
// import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
// import 'package:valarpay/core/widgets/transaction_details_screen.dart';
// import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
// import '../../../widgets/services_widgets/shopping_widgets/service_option_modal.dart';

// class ShoppingProviderPaymentScreen extends StatefulWidget {
//   final String providerName;

//   const ShoppingProviderPaymentScreen({
//     super.key,
//     required this.providerName,
//   });

//   @override
//   State<ShoppingProviderPaymentScreen> createState() =>
//       _ShoppingProviderPaymentScreenState();
// }

// class _ShoppingProviderPaymentScreenState
//     extends State<ShoppingProviderPaymentScreen> {
//   final TextEditingController orderIdController = TextEditingController();
//   String selectedTransactionType = 'Select an Option';
//   final TextEditingController amountController = TextEditingController();
//   int serviceFee = 500;
//   bool saveBeneficiary = false;

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           widget.providerName,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Order ID
//             Text(
//               'Order ID',
//               style: TextStyle(
//                 color: isDark ? Colors.white70 : Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 8),
//             ReuseableTextFieldWithCountry(
//                 controller: orderIdController,
//                 hintText: '01234',
//                 isReadOnly: false,
//                 textInputType: TextInputType.text,
//                 showCountryLabel: false),

//             const SizedBox(height: 24),

//             // Transaction Type
//             Text(
//               'Transaction Type',
//               style: TextStyle(
//                 color: isDark ? Colors.white70 : Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 8),
//             GestureDetector(
//               onTap: () => _showServiceOptionModal(context),
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       selectedTransactionType,
//                       style: TextStyle(
//                         color: isDark ? Colors.white : Colors.black,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Icon(
//                       Icons.keyboard_arrow_down,
//                       color: isDark ? Colors.white70 : Colors.grey[600],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Amount
//             Text(
//               'Amount',
//               style: TextStyle(
//                 color: isDark ? Colors.white70 : Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 8),
//             ReuseableAmountTextfield(
//                 amountController: amountController,
//                 prefixText: '₦',
//                 hintText: 'Enter Amount'),
//             const SizedBox(height: 60),

//             // Pay Shopping Button

//             FullWidthButton(
//                 text: 'Continue',
//                 onPressed: () {
//                   if (orderIdController.text.isNotEmpty &&
//                       selectedTransactionType != 'Select an Option' &&
//                       amountController.text.isNotEmpty) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) =>
//                               ReuseableTransactionDetailsScreen(
//                                 totalAmount: double.parse(amountController.text),
//                                 saveBeneficiary: saveBeneficiary,
//                                 onSaveBeneficiaryChanged: (value) {
//                                   setState(() {
//                                     saveBeneficiary = value;
//                                   });
//                                 },
//                                 hasBottom: false,
//                           topTitleText: 'Transaction',
//                                 topTransactionsDetailsList: [
//                                   buildDetailRow('Order ID',
//                                       orderIdController.text, isDark),
//                                   buildDetailRow(
//                                       'Store', widget.providerName, isDark),
//                                   buildDetailRow('Amount',
//                                       '₦${amountController.text}', isDark),
//                                   buildDetailRow(
//                                       'Fee', '₦${serviceFee}', isDark),
//                                   Divider(),
//                                   buildDetailRow(
//                                       'Total Amount',
//                                       '${(int.parse(amountController.text) + serviceFee)}',
//                                       isDark,
//                                       isTotal: true)
//                                 ],
//                                 onButtonPressed: () async {
//                                   final pin =
//                                       await BiometricTransactionPinModal.show(context);
//                                   if (pin != null &&
//                                       pin.length == 4 &&
//                                       mounted) {
//                                     if (mounted) Navigator.pop(context);
//                                     if (mounted) {
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   TransactionReceiptWidget(
//                                                     headerText: 'Transaction',
//                                                     amount:
//                                                         '${(int.parse(amountController.text) + serviceFee)}',
//                                                     topDetails: [
//                                                       TransactionDetail(
//                                                           label: 'Order ID',
//                                                           value:
//                                                               orderIdController
//                                                                   .text,
//                                                           showCopyIcon: true),
//                                                       TransactionDetail(
//                                                           label: 'Amount',
//                                                           value:
//                                                               '₦${amountController.text}'),
//                                                       TransactionDetail(
//                                                           label: 'Fee',
//                                                           value:
//                                                               '₦${serviceFee}'),
//                                                       TransactionDetail(
//                                                           label:
//                                                               'Amount Debited',
//                                                           value:
//                                                               '₦${(int.parse(amountController.text) + serviceFee)}'),
//                                                     ],
//                                                     bottomDetails: [
//                                                       TransactionDetail(
//                                                           label:
//                                                               'Transaction ID',
//                                                           value:
//                                                               'TXN${DateTime.now().millisecondsSinceEpoch}',
//                                                           showCopyIcon: true),
//                                                       TransactionDetail(
//                                                           label: 'Store',
//                                                           value: widget
//                                                               .providerName),
//                                                       TransactionDetail(
//                                                           label:
//                                                               'Payment Source',
//                                                           value:
//                                                               'ValarPay Account'),
//                                                       TransactionDetail(
//                                                           label: 'Date & Time',
//                                                           value:
//                                                               '29 Sep 2025 | 8:15 pm')
//                                                     ],
//                                                     onShareReceipt: () {},
//                                                   )));
//                                     }
//                                   }
//                                 },
//                               )),
//                     );
//                   }
//                 })
//           ],
//         ),
//       ),
//     );
//   }

//   void _showServiceOptionModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => ShoppingServiceOptionModal(
//         selectedOption: selectedTransactionType,
//         onOptionSelected: (option) {
//           setState(() {
//             selectedTransactionType = option;
//           });
//         },
//       ),
//     );
//   }
// }
