import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'saved_beneficiary_screen.dart';
import 'institution_payment_screen.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final institutions = [
      'Institute Of Management Technology',
      'University of Benin',
      'Ajayi Crowther University',
      'Ajayi Crowther University',
      'Ajayi Crowther University',
      'Ajayi Crowther University',
      'Ajayi Crowther University',
    ];

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
          'Education Payment',
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const EducationSavedBeneficiaryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Saved Beneficiary',
                      style: TextStyle(color: Color(0xFFF76301), fontSize: 14),
                    ),
                  ),
                ]
                : null,
      ),
      body:
          isBvnVerified
              ? const KycNotSetWidget(
                title: 'KYC Not Completed',
                subtitle:
                    'Complete your KYC verification to make education payments',
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Institutions List
                    Expanded(
                      child: ListView.builder(
                        itemCount: institutions.length,
                        itemBuilder: (context, index) {
                          final institution = institutions[index];
                          return _buildInstitutionTile(institution, isDark);
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInstitutionTile(String institution, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF76301).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.school, color: Color(0xFFF76301), size: 20),
        ),
        title: Text(
          institution,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
              builder:
                  (context) =>
                      InstitutionPaymentScreen(institutionName: institution),
            ),
          );
        },
      ),
    );
  }
}
