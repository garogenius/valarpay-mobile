import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/features/dashboard/widgets/Kyc/tier1_card.dart';
import 'package:valarpay/features/dashboard/widgets/Kyc/tier2_kyc.dart';
import 'package:valarpay/features/dashboard/widgets/Kyc/tier3_card.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class UpgradeKycScreen extends ConsumerStatefulWidget {
  const UpgradeKycScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UpgradeKycScreen> createState() => _UpgradeKycScreenState();
}

class _UpgradeKycScreenState extends ConsumerState<UpgradeKycScreen> {
  bool _isTier1Expanded = true;
  bool _isTier2Expanded = false;
  bool _isTier3Expanded = false;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final user =
        userState.data?.isNotEmpty == true ? userState.data!.first : null;
    final isNinVerified = user?.isNinVerified ?? false;
    final isAddressSubmitted = user?.isAddressVerified ?? false;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upgrade your account',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Tier 1 Card
            Tier1Card(
              isExpanded: _isTier1Expanded,
              user: user,
              onToggle: () {
                setState(() {
                  _isTier1Expanded = !_isTier1Expanded;
                });
              },
            ),
            SizedBox(height: 16.h),

            // Tier 2 Card
            Tier2Card(
              isExpanded: _isTier2Expanded,
              user: user,
              onToggle: () {
                setState(() {
                  _isTier2Expanded = !_isTier2Expanded;
                });
              },
            ),
            SizedBox(height: 16.h),

            // Tier 3 Card
            Tier3Card(
              isExpanded: _isTier3Expanded,
              isNinVerified: isNinVerified,
              isAddressSubmitted: isAddressSubmitted,
              user: user,
              onToggle: () {
                setState(() {
                  _isTier3Expanded = !_isTier3Expanded;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
