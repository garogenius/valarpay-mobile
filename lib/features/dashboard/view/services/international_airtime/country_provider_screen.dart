// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:developer';
// import 'package:valarpay/core/utils/app_messenger.dart';
// import 'package:valarpay/features/notifiers/airtime_notifier.dart';
// import 'package:valarpay/features/models/airtime_models.dart';
// import 'package:valarpay/core/utils/currency_formatter.dart';
// import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
// import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
// import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
// import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
// import 'package:valarpay/core/widgets/transaction_details_screen.dart';
// import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';

// class CountryProviderScreen extends ConsumerStatefulWidget {
//   final String countryProvider;

//   const CountryProviderScreen({super.key, required this.countryProvider});

//   @override
//   ConsumerState<CountryProviderScreen> createState() =>
//       _CountryProviderScreenState();
// }

// class _CountryProviderScreenState extends ConsumerState<CountryProviderScreen> {
//   final TextEditingController controller = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//   String selectedAmount = '';

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     // Get country code based on provider
//     String countryCode = _getCountryCode(widget.countryProvider);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           widget.countryProvider,
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Phone Number
//             Text(
//               'Phone Number',
//               style: TextStyle(
//                 color: isDark ? Colors.white70 : Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 8),

//             ReuseableTextFieldWithCountry(
//               showCountryLabel: true,
//               hintText: '123 456 789',
//               isReadOnly: false,
//               textInputType: TextInputType.phone,
//               countryCode: countryCode,
//               flagImagePath: 'assets/images/ghflag.png',
//               controller: controller,
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
//               amountController: amountController,
//               prefixText: '\$',
//               hintText: '1,000',
//             ),

//             const SizedBox(height: 24),

//             // Quick Amount Selection
//             Text(
//               'Quick Select',
//               style: TextStyle(
//                 color: isDark ? Colors.white70 : Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 12,
//               runSpacing: 12,
//               children: [
//                 _buildAmountChip('5.00', isDark),
//                 _buildAmountChip('10.00', isDark),
//                 _buildAmountChip('20.00', isDark),
//                 _buildAmountChip('50.00', isDark),
//                 _buildAmountChip('100.00', isDark),
//               ],
//             ),

//             const SizedBox(height: 50),

//             // Continue Button
//             FullWidthButton(
//               text: 'Continue',
//               onPressed: () async {
//                 if (controller.text.isEmpty ||
//                     (amountController.text.isEmpty && selectedAmount.isEmpty)) {
//                   AppMessenger.show(
//                     context,
//                     message: 'Please enter phone and amount',
//                     type: MessageType.error,
//                   );
//                   return;
//                 }

//                 final countryCode = _getCountryCode(widget.countryProvider);
//                 final fullPhone = '$countryCode${controller.text}';
//                 final rawAmount = (amountController.text.isNotEmpty
//                         ? amountController.text
//                         : selectedAmount)
//                     .replaceAll(',', '');
//                 double amount;
//                 try {
//                   amount = double.parse(rawAmount);
//                 } catch (e) {
//                   AppMessenger.show(
//                     context,
//                     message: 'Invalid amount',
//                     type: MessageType.error,
//                   );
//                   return;
//                 }

//                 // Show loading
//                 showDialog(
//                   context: context,
//                   barrierDismissible: false,
//                   builder:
//                       (_) => const Center(child: CircularProgressIndicator()),
//                 );

//                 try {
//                   // 1) Get international plan for phone
//                   await ref
//                       .read(airtimePlanNotifierProvider.notifier)
//                       .getInternationalPlan(phone: fullPhone);

//                   final planState = ref.read(airtimePlanNotifierProvider);
//                   if (!(planState.isDataAvailable &&
//                       (planState.data?.isNotEmpty ?? false))) {
//                     if (Navigator.canPop(context)) Navigator.pop(context);
//                     AppMessenger.show(
//                       context,
//                       message: planState.message ?? 'Failed to get plan',
//                       type: MessageType.error,
//                     );
//                     return;
//                   }

//                   final plan = planState.data!.first;
//                   final operatorId = plan.operatorId;

//                   // 2) Get FX rate
//                   await ref
//                       .read(internationalFxNotifierProvider.notifier)
//                       .getFxRate(amount: amount, operatorId: operatorId);

//                   final fxState = ref.read(internationalFxNotifierProvider);
//                   if (!(fxState.isDataAvailable &&
//                       (fxState.data?.isNotEmpty ?? false))) {
//                     if (Navigator.canPop(context)) Navigator.pop(context);
//                     AppMessenger.show(
//                       context,
//                       message: fxState.message ?? 'Failed to get FX rate',
//                       type: MessageType.error,
//                     );
//                     return;
//                   }

//                   // 3) Ask for PIN
//                   final pin = await BiometricTransactionPinModal.show(context);
//                   if (pin == null || pin.length != 4) {
//                     if (Navigator.canPop(context)) Navigator.pop(context);
//                     AppMessenger.show(
//                       context,
//                       message: 'Invalid PIN',
//                       type: MessageType.error,
//                     );
//                     return;
//                   }

//                   // 4) Pay for international airtime
//                   final request = AirtimePurchaseRequest(
//                     walletPin: pin,
//                     amount: amount,
//                     operatorId: operatorId,
//                     phone: fullPhone,
//                     currency: 'NGN',
//                     addBeneficiary: false,
//                   );

//                   await ref
//                       .read(internationalPurchaseNotifierProvider.notifier)
//                       .purchase(request);

//                   final purchaseState = ref.read(
//                     internationalPurchaseNotifierProvider,
//                   );
//                   // Close loading
//                   if (Navigator.canPop(context)) Navigator.pop(context);

//                   if (purchaseState.isDataAvailable &&
//                       (purchaseState.data?.isNotEmpty ?? false)) {
//                     // Navigate to receipt
//                     if (mounted) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) => TransactionReceiptWidget(
//                                 headerText: 'Transaction',
//                                 amount: currencyFormatter(rawAmount),
//                                 topDetails: [
//                                   TransactionDetail(
//                                     label: 'Transaction ID',
//                                     value:
//                                         'TXN${DateTime.now().millisecondsSinceEpoch}',
//                                     showCopyIcon: true,
//                                   ),
//                                   TransactionDetail(
//                                     label: 'Recipient Mobile',
//                                     value: fullPhone,
//                                   ),
//                                   TransactionDetail(
//                                     label: 'Provider',
//                                     value: widget.countryProvider,
//                                   ),
//                                   TransactionDetail(
//                                     label: 'Payment Source',
//                                     value: 'ValarPay Account',
//                                   ),
//                                   TransactionDetail(
//                                     label: 'Date & Time',
//                                     value:
//                                         '${DateTime.now().day} ${DateTime.now().month}/${DateTime.now().year} | ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
//                                   ),
//                                 ],
//                                 onShareReceipt: () {},
//                               ),
//                         ),
//                       );
//                     }
//                   } else {
//                     AppMessenger.show(
//                       context,
//                       message: purchaseState.message ?? 'Purchase failed',
//                       type: MessageType.error,
//                     );
//                   }
//                 } catch (e, st) {
//                   log('[International Purchase Flow] $e\n$st');
//                   if (Navigator.canPop(context)) Navigator.pop(context);
//                   AppMessenger.show(
//                     context,
//                     message: 'Error: ${e.toString()}',
//                     type: MessageType.error,
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAmountChip(String amount, bool isDark) {
//     final isSelected = selectedAmount == amount;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedAmount = amount;
//           amountController.text = amount;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color:
//               isSelected
//                   ? const Color(0xFFF76301)
//                   : (isDark ? const Color(0xFF2B2725) : Colors.grey[100]),
//           borderRadius: BorderRadius.circular(20),
//           border:
//               isSelected
//                   ? null
//                   : Border.all(
//                     color: isDark ? Colors.white24 : Colors.grey[300]!,
//                   ),
//         ),
//         child: Text(
//           '\$$amount',
//           style: TextStyle(
//             color:
//                 isSelected
//                     ? Colors.white
//                     : (isDark ? Colors.white : Colors.black),
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   String _getCountryCode(String provider) {
//     if (provider.contains('Ghana')) return '+233';
//     if (provider.contains('Canada')) return '+1';
//     if (provider.contains('Kenya')) return '+254';
//     if (provider.contains('Senegal')) return '+221';
//     return '+233'; // Default
//   }
// }
