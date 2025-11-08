// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:valarpay/core/widgets/reuseable_appbar_text_button.dart';
// import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
// import 'package:valarpay/features/providers/user_provider.dart';
// import 'package:valarpay/features/notifiers/airtime_notifier.dart';
// import 'package:valarpay/features/models/network_provider.dart';
// import 'saved_beneficiary_screen.dart';
// import 'country_provider_screen.dart';

// class InternationalAirtimeScreen extends ConsumerStatefulWidget {
//   const InternationalAirtimeScreen({super.key});

//   @override
//   ConsumerState<InternationalAirtimeScreen> createState() =>
//       _InternationalAirtimeScreenState();
// }

// class _InternationalAirtimeScreenState
//     extends ConsumerState<InternationalAirtimeScreen> {
//   String selectedCountry = '';

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // fetch network providers to show dynamically
//       ref.read(airtimeProvidersNotifierProvider.notifier).fetchProviders();
//     });
//   }

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
//           'International Airtime',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: isBvnVerified
//             ? [
//                 ReuseableAppbarTextButton(
//                     onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 const InternationalAirtimeSavedBeneficiaryScreen(),
//                           ),
//                         ),
//                     text: 'Saved Beneficiary')
//               ]
//             : null,
//       ),
//       body: !isBvnVerified
//           ? const KycNotSetWidget(
//               title: 'KYC Not Completed',
//               subtitle:
//                   'Complete your KYC verification to purchase international airtime',
//             )
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Countries/Providers List (dynamic)
//                   Expanded(
//                     child: Consumer(builder: (context, ref, _) {
//                       final providersState =
//                           ref.watch(airtimeProvidersNotifierProvider);
//                       final providers =
//                           providersState.data ?? <NetworkProvider>[];

//                       if (providersState.isInitialLoading &&
//                           providers.isEmpty) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       if (!providersState.isDataAvailable &&
//                           providers.isEmpty) {
//                         return Center(
//                           child: Text(
//                             providersState.message ?? 'No providers available',
//                             style: const TextStyle(color: Colors.grey),
//                           ),
//                         );
//                       }

//                       return ListView.builder(
//                         itemCount: providers.length,
//                         itemBuilder: (context, index) {
//                           final p = providers[index];
//                           return _buildCountryTile(p, isDark);
//                         },
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildCountryTile(NetworkProvider provider, bool isDark) {
//     final displayName =
//         '${provider.network} ${_mapIsoToCountry(provider.countryISOCode)}';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         tileColor: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         title: Text(
//           displayName,
//           style: const TextStyle(
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
//               builder: (context) => CountryProviderScreen(
//                 countryProvider: displayName,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   String _mapIsoToCountry(String iso) {
//     final code = iso.toUpperCase();
//     switch (code) {
//       case 'GH':
//         return 'Ghana';
//       case 'CA':
//       case 'CAN':
//         return 'Canada';
//       case 'KE':
//         return 'Kenya';
//       case 'SN':
//         return 'Senegal';
//       default:
//         return iso;
//     }
//   }
// }
