// import 'package:flutter/material.dart';
// import 'package:valarpay/core/utils/currency_formatter.dart';
// import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
// import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
// import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
// import 'package:valarpay/core/widgets/transaction_details_screen.dart';
// import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
// import '../../../widgets/services_widgets/flight_widgets/gender_selector_modal.dart';

// class PassengerDetailsScreen extends StatefulWidget {
//   final Map<String, String> flightData;

//   const PassengerDetailsScreen({
//     super.key,
//     required this.flightData,
//   });

//   @override
//   State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
// }

// class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
//   final List<Map<String, dynamic>> passengers = [];
//   String serviceFee = '500';
//   bool saveBeneficiary = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializePassengers();
//   }

//   void _initializePassengers() {
//     final adults = int.parse(widget.flightData['adults'] ?? '0');
//     final children = int.parse(widget.flightData['children'] ?? '0');

//     // Add adults
//     for (int i = 0; i < adults; i++) {
//       passengers.add({
//         'type': 'Adult ${i + 1} (12+ years)',
//         'fullName': TextEditingController(),
//         'dateOfBirth': null,
//         'gender': 'Male',
//       });
//     }

//     // Add children
//     for (int i = 0; i < children; i++) {
//       passengers.add({
//         'type': 'Child ${i + 1} (2-11years)',
//         'fullName': TextEditingController(),
//         'dateOfBirth': null,
//         'gender': 'Male',
//       });
//     }
//   }

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
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Instruction text
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Center(
//                   child: Text(
//                     'Passenger Details',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Text(
//                   'Enter traveller information as it appears on your valid ID or passport',
//                   style: TextStyle(
//                     color: isDark ? Colors.white70 : Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Passengers list
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: passengers.length,
//               itemBuilder: (context, index) {
//                 return _buildPassengerForm(passengers[index], index, isDark);
//               },
//             ),
//           ),

//           // Continue button\
//           FullWidthButton(
//             text: 'Continue', 
//             onPressed: () {
//               Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ReuseableTransactionDetailsScreen(
//                           totalAmount: double.parse((int.parse('45000') + int.parse(serviceFee) + int.parse(serviceFee) + int.parse('35000') + int.parse('25000')).toString()),
//                           saveBeneficiary: saveBeneficiary,
//                           onSaveBeneficiaryChanged: (value) {
//                         setState(() {
//                           saveBeneficiary = value;
//                         });
//                       },
//                           topTitleText: 'Flight',
//                           bottomTitleText: 'Fare Breakdown',
//                           hasBottom: true,
//                           topTransactionsDetailsList: [
//                             buildDetailRow('Route',
//                                 '${widget.flightData['departure']} → ${widget.flightData['destination']}', isDark),
//                             buildDetailRow('Airline', widget.flightData['flightName']!, isDark),
//                             buildDetailRow(
//                                 'Class Type', widget.flightData['class'] ?? 'Economy', isDark),
//                             buildDetailRow(
//                                 'Number of Passengers', '${passengers.length}', isDark),
//                             buildDetailRow(
//                                 'Phone Number',
//                                  widget.flightData['phone'] ?? '0000000000000',
//                                 isDark),
//                             buildDetailRow(
//                                 'Email Address', widget.flightData['email'] ?? 'email@valarpay.com', isDark),
//                             buildDetailRow(
//                                 'Depature Date',
//                                 '10 Oct 2025, 9:00 AM', isDark),
                
//                           ],
//                           bottomTransactionsDetailsList: [
//                                 buildDetailRow(
//                                 'Adults Fare',
//                                 '₦45,000',
//                                 isDark),
//                                 buildDetailRow(
//                                 'Children Fare',
//                                 '₦35,000',
//                                 isDark),
//                                 buildDetailRow(
//                                 'Infants Fare',
//                                 '₦25,000',
//                                 isDark),
//                             buildDetailRow(
//                                 'Taxes and Fees', currencyFormatter(serviceFee), isDark),
//                             buildDetailRow(
//                                 'Service Charges', currencyFormatter(serviceFee), isDark),
//                             buildDetailRow(
//                                 'Total Amount',
//                                 currencyFormatter(
//                                     '${int.parse('45000') + int.parse(serviceFee) + int.parse(serviceFee) + int.parse('35000') + int.parse('25000')}'),
//                                 isDark,
//                                 isTotal: true)
//                           ],
//                           onButtonPressed: () async {
//                             final pin = await BiometricTransactionPinModal.show(context);
//                             if (pin != null && pin.length == 4 && mounted) {
//                               if (mounted) {
//                                 Navigator.pushReplacement(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             TransactionReceiptWidget(
//                                               headerText: 'Transaction',
//                                               amount:
//                                                   '${int.parse('45000') + int.parse(serviceFee) + int.parse(serviceFee) + int.parse('35000') + int.parse('25000')}',
//                                               topDetails: [
//                                                 TransactionDetail(
//                                                     label: passengers[0]['fullName'],
//                                                     value:
//                                                         'TXN${DateTime.now().millisecondsSinceEpoch}',
//                                                     showCopyIcon: true),
//                                                  TransactionDetail(
//                                                     label: passengers[1]['fullName'] ?? '',
//                                                     value:
//                                                         'TXN${DateTime.now().millisecondsSinceEpoch}',
//                                                     showCopyIcon: true),
//                                                  TransactionDetail(
//                                                     label: passengers[2]['fullName'] ?? '',
//                                                     value:
//                                                         'TXN${DateTime.now().millisecondsSinceEpoch}',
//                                                     showCopyIcon: true),
//                                                  TransactionDetail(
//                                                     label: 'Route',
//                                                     value:
//                                                         '${widget.flightData['departure']} → ${widget.flightData['destination']}'),
//                                                 TransactionDetail(
//                                                     label: 'Class Type',
//                                                     value: widget.flightData['class'] ?? 'Economy'),
//                                                  TransactionDetail(
//                                                     label: 'Total Amount',
//                                                     value: currencyFormatter(
//                                                         '50000')),
//                                                 TransactionDetail(
//                                                     label: 'Fee',
//                                                     value: currencyFormatter(
//                                                         serviceFee)),
//                                                 TransactionDetail(
//                                                     label: 'Total Debit',
//                                                     value: currencyFormatter(
//                                                         '${int.parse('50000') + int.parse(serviceFee)}')),
//                                               ],
//                                               bottomDetails: [
//                                                  TransactionDetail(
//                                                     label: 'Booking Reference',
//                                                     value:
//                                                         'TXN${DateTime.now().millisecondsSinceEpoch}',
//                                                     showCopyIcon: true),
//                                                 TransactionDetail(
//                                                     label: 'Transaction ID',
//                                                     value:
//                                                         'TXN${DateTime.now().millisecondsSinceEpoch}',
//                                                     showCopyIcon: true),
//                                                 TransactionDetail(
//                                                     label: 'Contact Information',
//                                                     value:
//                                                         '${widget.flightData['phone']} | ${widget.flightData['email']}'),
//                                                 TransactionDetail(
//                                                     label: 'Airline',
//                                                     value: widget.flightData['flightName']!),
                          
//                                                 TransactionDetail(
//                                                     label: 'Payment Source',
//                                                     value: 'ValarPay Account'),
//                                                 TransactionDetail(
//                                                     label: 'Date & Time',
//                                                     value:
//                                                         '29 Sep 2025 | 8:15 pm'),
//                                               ],
//                                               onShareReceipt: () {
//                                                 // TODO: Implement share receipt functionality
//                                               },
//                                             )));
//                               }
//                             }
//                           },
//                         ),
//                       ),
//                     );
                 
//           })
//          ],
//       ),
//     );
//   }

//   Widget _buildPassengerForm(
//       Map<String, dynamic> passenger, int index, bool isDark) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 24),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor.withOpacity(0.4),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Passenger type
//           Text(
//             passenger['type'],
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Full Name
//           Text(
//             'Full Name',
//             style: TextStyle(
//               color: isDark ? Colors.white70 : Colors.grey[600],
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 8),
//           ReuseableTextFieldWithCountry(
//               controller: passenger['fullName'],
//               hintText: 'Full Name',
//               isReadOnly: false,
//               textInputType: TextInputType.text,
//               showCountryLabel: false),
          

//           const SizedBox(height: 16),

//           // Date of Birth
//           Text(
//             'Date of Birth',
//             style: TextStyle(
//               color: isDark ? Colors.white70 : Colors.grey[600],
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 8),
//           GestureDetector(
//             onTap: () => _selectDate(passenger),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor.withOpacity(0.4),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     passenger['dateOfBirth'] != null
//                         ? '${passenger['dateOfBirth'].day}-${passenger['dateOfBirth'].month}-${passenger['dateOfBirth'].year}'
//                         : 'DD-MM-YYYY',
//                     style: TextStyle(
//                       fontSize: 16,
//                     ),
//                   ),
//                   Icon(
//                     Icons.calendar_today,
//                     color: isDark ? Colors.white70 : Colors.grey[600],
//                     size: 20,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Gender
//           Text(
//             'Gender',
//             style: TextStyle(
//               color: isDark ? Colors.white70 : Colors.grey[600],
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 8),
//           GestureDetector(
//             onTap: () => _showGenderSelector(passenger),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor.withOpacity(0.4),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     passenger['gender'],
//                     style: TextStyle(
//                       fontSize: 16,
//                     ),
//                   ),
//                   Icon(
//                     Icons.keyboard_arrow_down,
//                     color: isDark ? Colors.white70 : Colors.grey[600],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDate(Map<String, dynamic> passenger) async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (date != null) {
//       setState(() {
//         passenger['dateOfBirth'] = date;
//       });
//     }
//   }

//   void _showGenderSelector(Map<String, dynamic> passenger) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => GenderSelectorModal(
//         selectedGender: passenger['gender'],
//         onGenderSelected: (gender) {
//           setState(() {
//             passenger['gender'] = gender;
//           });
//         },
//       ),
//     );
//   }
// }
