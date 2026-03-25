import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/services_widgets/profile_widgets/profile_header.dart';
import '../../widgets/services_widgets/profile_widgets/profile_menu_item.dart';
import 'personal_details_screen.dart';
import 'contact_details_screen.dart';
import 'address_screen.dart';
import 'edit_profile_screen.dart';
import '../KYC/upgrade_kyc.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            ProfileHeader(
              context: context,
              onEditTap: () {
                // Handle edit profile picture
              },
            ),

            const SizedBox(height: 24),

            // Profile Menu Items
            ProfileMenuItem(
              icon: Icons.edit_note_outlined,
              title: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Personal Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalDetailsScreen(),
                  ),
                );
              },
            ),

            ProfileMenuItem(
              icon: Icons.contact_phone_outlined,
              title: 'Contact Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactDetailsScreen(),
                  ),
                );
              },
            ),

            ProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Address',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressScreen(),
                  ),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.verified_user_outlined,
              title: 'Account Verification',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpgradeKycScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
