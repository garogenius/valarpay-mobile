// import 'package:flutter/material.dart';
// import 'package:valarpay/core/widgets/reuseable_appbar_text_button.dart';
// import 'package:valarpay/features/dashboard/view/services/flight/flight_screen.dart';
// import 'package:valarpay/features/dashboard/view/services/flight/saved_beneficiary_screen.dart';
// // import 'package:valarpay/features/dashboard/view/services/international_airtime/country_provider_screen.dart';

// class FlightSelectionScreen extends StatefulWidget {
//   const FlightSelectionScreen({super.key});

//   @override
//   State<FlightSelectionScreen> createState() => _FlightSelectionScreenState();
// }

// class _FlightSelectionScreenState extends State<FlightSelectionScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Flight',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: [
//           ReuseableAppbarTextButton(
//               onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           const FlightSavedBeneficiaryScreen(),
//                     ),
//                   ),
//               text: 'Saved Beneficiary')
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Countries/Providers List
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildFlightTile('Air Peace', isDark),
//                   _buildFlightTile('Arik Air', isDark),
//                   _buildFlightTile('Dana Air', isDark),
//                   _buildFlightTile('Ibom Air', isDark),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFlightTile(String flightName, bool isDark) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         tileColor: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         title: Text(
//           flightName,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios,
//           color: isDark ? Colors.white70 : Colors.grey[600],
//           size: 16,
//         ),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => FlightScreen(
//                 flightName: flightName,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
