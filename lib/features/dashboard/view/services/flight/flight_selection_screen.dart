import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/responsive_utils.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/dashboard/view/services/flight/flight_screen.dart';
import 'package:valarpay/features/models/remita_models.dart';
import 'package:valarpay/features/notifiers/remita_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class FlightSelectionScreen extends ConsumerStatefulWidget {
  const FlightSelectionScreen({super.key});

  @override
  ConsumerState<FlightSelectionScreen> createState() =>
      _FlightSelectionScreenState();
}

class _FlightSelectionScreenState extends ConsumerState<FlightSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(remitaBillersProvider.notifier).fetchBillers('flight');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false) || (user?.wallets.isNotEmpty ?? false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final billerState = ref.watch(remitaBillersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Flight',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC verification to pay for flight tickets',
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      hintText: "Search airlines",
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: ResponsiveUtils.borderRadius12,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                    Expanded(
                    child: billerState.isInitialLoading
                        ? const Center(child: CircularProgressIndicator())
                        : billerState.message != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    billerState.message!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              )
                            : billerState.data == null || billerState.data!.isEmpty
                                ? const Center(child: Text('No airlines found'))
                                : ListView.builder(
                                    itemCount: billerState.data!.length,
                                    itemBuilder: (context, index) {
                                      final biller = billerState.data![index];
                                      return _buildFlightTile(biller, isDark);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFlightTile(RemitaBiller biller, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: biller.billerLogoUrl != null
                ? Image.network(
                    biller.billerLogoUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.flight, color: Colors.orange),
                  )
                : const Icon(Icons.flight, color: Colors.orange),
          ),
        ),
        title: Text(
          biller.billerName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDark ? Colors.white70 : Colors.grey[600],
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlightScreen(
                flightName: biller.billerName,
                billerId: biller.billerId,
              ),
            ),
          );
        },
      ),
    );
  }
}

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
            // Expanded(
            //   child: ListView(
            //     children: [
            //       _buildFlightTile('Air Peace', isDark),
            //       _buildFlightTile('Arik Air', isDark),
            //       _buildFlightTile('Dana Air', isDark),
            //       _buildFlightTile('Ibom Air', isDark),
            //     ],
            //   ),
            // ),
//           ],
//         ),
//       ),
//     );
//   }

// }
