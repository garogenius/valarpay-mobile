// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
// import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
// import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
// import 'package:valarpay/features/providers/user_provider.dart';
// import '../../../widgets/services_widgets/flight_widgets/destination_selector_modal.dart';
// import '../../../widgets/services_widgets/flight_widgets/class_selector_modal.dart';
// // import 'saved_beneficiary_screen.dart';
// import 'passenger_details_screen.dart';

// class FlightScreen extends ConsumerStatefulWidget {
//   String flightName;
//   FlightScreen({required this.flightName, super.key});

//   @override
//   ConsumerState<FlightScreen> createState() => _FlightScreenState();
// }

// class _FlightScreenState extends ConsumerState<FlightScreen> {
//   String selectedDeparture = 'Benin City';
//   String selectedDestination = 'Abuja';
//   String selectedClass = 'Economy';
//   DateTime? departureDate;
//   final TextEditingController controller = TextEditingController();
//   final TextEditingController emailController = TextEditingController();

//   int adults = 1;
//   int children = 0;
//   int infants = 0;

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
//           widget.flightName,
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
//             // Place of Departure
//             _buildSectionTitle('Place of Departure', isDark),
//             const SizedBox(height: 8),
//             _buildDropdownField(
//               selectedDeparture,
//               () => _showDestinationSelector(context, true),
//               isDark,
//             ),

//             const SizedBox(height: 24),

//             // Departure Date
//             _buildSectionTitle('Departure Date', isDark),
//             const SizedBox(height: 8),
//             _buildDateField(isDark),

//             const SizedBox(height: 24),

//             // Destination
//             _buildSectionTitle('Destination', isDark),
//             const SizedBox(height: 8),
//             _buildDropdownField(
//               selectedDestination,
//               () => _showDestinationSelector(context, false),
//               isDark,
//             ),

//             const SizedBox(height: 24),

//             // Class Type
//             _buildSectionTitle('Class Type', isDark),
//             const SizedBox(height: 8),
//             _buildDropdownField(
//               selectedClass,
//               () => _showClassSelector(context),
//               isDark,
//             ),

//             const SizedBox(height: 24),

//             // Email Address
//             _buildSectionTitle('Email Address', isDark),
//             const SizedBox(height: 8),
//             _buildTextField(emailController, 'email@valarpay.com', isDark),

//             const SizedBox(height: 24),

//             // Phone Number
//             _buildSectionTitle('Phone Number', isDark),
//             const SizedBox(height: 8),
//             _buildPhoneField(isDark),

//             const SizedBox(height: 24),

//             // Passengers
//             _buildSectionTitle('Passengers', isDark),
//             const SizedBox(height: 16),
//             _buildPassengerCounter('Adults (12+ years)', adults, (value) {
//               setState(() => adults = value);
//             }, isDark),
//             const SizedBox(height: 12),
//             _buildPassengerCounter('Children (2-11 years)', children, (value) {
//               setState(() => children = value);
//             }, isDark),
//             const SizedBox(height: 12),
//             _buildPassengerCounter('Infants (under 2 years)', infants, (value) {
//               setState(() => infants = value);
//             }, isDark),

//             const SizedBox(height: 60),

//             // Continue Button
//             FullWidthButton(
//                 text: 'Continue',
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => PassengerDetailsScreen(
//                         flightData: {
//                           'departure': selectedDeparture,
//                           'destination': selectedDestination,
//                           'class': selectedClass,
//                           'departureDate': departureDate?.toString() ?? '',
//                           'adults': adults.toString(),
//                           'children': children.toString(),
//                           'infants': infants.toString(),
//                           'email': emailController.text,
//                           'phone': controller.text,
//                           'flightName': widget.flightName
//                         },
//                       ),
//                     ),
//                   );
//                 })
//           ],
//         ),
//       ));
//   }

//   Widget _buildSectionTitle(String title, bool isDark) {
//     return Text(
//       title,
//       style: TextStyle(
//         color: isDark ? Colors.white70 : Colors.grey[600],
//         fontSize: 14,
//       ),
//     );
//   }

//   Widget _buildDropdownField(String value, VoidCallback onTap, bool isDark) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor.withOpacity(0.4),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//             Icon(
//               Icons.keyboard_arrow_down,
//               color: isDark ? Colors.white70 : Colors.grey[600],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String hint, bool isDark) {
//     return ReuseableTextFieldWithCountry(
//         controller: controller,
//         hintText: hint,
//         isReadOnly: false,
//         textInputType: TextInputType.text,
//         showCountryLabel: false);
//   }

//   Widget _buildDateField(bool isDark) {
//     return GestureDetector(
//       onTap: () async {
//         final date = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime.now(),
//           lastDate: DateTime.now().add(const Duration(days: 365)),
//         );
//         if (date != null) {
//           setState(() => departureDate = date);
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor.withOpacity(0.4),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               departureDate != null
//                   ? '${departureDate!.day}-${departureDate!.month}-${departureDate!.year}'
//                   : 'DD-MM-YYYY',
//               style: TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//             Icon(
//               Icons.calendar_today,
//               color: isDark ? Colors.white70 : Colors.grey[600],
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPhoneField(bool isDark) {
//     return ReuseableTextFieldWithCountry(
//         controller: controller,
//         hintText: '123 4567 890',
//         isReadOnly: false,
//         textInputType: TextInputType.number,
//         showCountryLabel: true);
//   }

//   Widget _buildPassengerCounter(
//       String title, int count, Function(int) onChanged, bool isDark) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//           ),
//         ),
//         Row(
//           children: [
//             IconButton(
//               onPressed: count > 0 ? () => onChanged(count - 1) : null,
//               icon: Icon(
//                 Icons.remove_circle_outline,
//                 color: count > 0
//                     ? (isDark ? Colors.white : Colors.black)
//                     : Colors.grey,
//               ),
//             ),
//             Text(
//               count.toString(),
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             IconButton(
//               onPressed: () => onChanged(count + 1),
//               icon: Icon(
//                 Icons.add_circle_outline,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   void _showDestinationSelector(BuildContext context, bool isDeparture) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DestinationSelectorModal(
//         isDeparture: isDeparture,
//         selectedDestination:
//             isDeparture ? selectedDeparture : selectedDestination,
//         onDestinationSelected: (destination) {
//           setState(() {
//             if (isDeparture) {
//               selectedDeparture = destination;
//             } else {
//               selectedDestination = destination;
//             }
//           });
//         },
//       ),
//     );
//   }

//   void _showClassSelector(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => ClassSelectorModal(
//         selectedClass: selectedClass,
//         onClassSelected: (classType) {
//           setState(() {
//             selectedClass = classType;
//           });
//         },
//       ),
//     );
//   }
// }
