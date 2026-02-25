import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/utils/responsive_utils.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool showNairaBalance = false;
  bool showDollarBalance = false;

  @override
  void initState() {
    super.initState();
    // Refresh user profile when screen loads to get latest wallet data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userNotifierProvider.notifier).refreshUserProfile();
      _showProfileReminder();
    });
  }

  void _showProfileReminder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "Update Your Profile",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Please make sure you first update your profile and fill all the information in your profile before creating a multi-currency account.",
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Got it",
              style: TextStyle(
                color: appTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.push('/edit-profile');
            },
            child: const Text(
              "Update Profile",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get user data from provider
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final wallet =
        user?.wallets.isNotEmpty == true ? user!.wallets.first : null;

    // Extract wallet data
    final formattedBalance = wallet?.formattedBalance ?? '₦0.00';
    final bankName = wallet?.bankName ?? 'ValarPay Bank';
    final accountName =
        wallet?.accountName ?? user?.fullname ?? 'Not Available';
    final accountNumber = wallet?.accountNumber ?? 'Not Available';
    final tierLevel = user?.tierLevel ?? 'notSet';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Account",
           style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),),
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle:
                  'Complete your KYC verification to view your account details',
            )
          : SingleChildScrollView(
        padding: ResponsiveUtils.paddingAll16,
        child: Column(
          children: [
            // Naira Account Card
            _accountCard(
              currency: "₦",
              balance: formattedBalance,
              bankName: bankName,
              accountName: accountName,
              accountNumber: accountNumber,
              tierLevel: tierLevel,
              isVisible: showNairaBalance,
              onToggle: () =>
                  setState(() => showNairaBalance = !showNairaBalance),
            ),
            SizedBox(height: 20.h),

            // Get USD Account
            _accountSetupCard(
              flag: "assets/images/usflag.png",
              title: "Get USD Account",
              subtitle: "Open a secure dollar account",
              onTap: () {
                context.push('/account-setup', extra: 'USD');
              },
            ),
            SizedBox(height: 12.h),

            // Get Euro Account
            _accountSetupCard(
              flag: "assets/images/euflag.png",
              title: "Get Euro Account",
              subtitle: "Open a secure euro account",
              onTap: () {
                context.push('/account-setup', extra: 'EUR');
              },
            ),
            SizedBox(height: 12.h),

            // Get Pound Account
            _accountSetupCard(
              flag: "assets/images/pounds2.png",
              title: "Get Pound Account",
              subtitle: "Open a secure pounds account",
              onTap: () {
                context.push('/account-setup', extra: 'GBP');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Account Card
  Widget _accountCard({
    required String currency,
    required String balance,
    required String bankName,
    required String accountName,
    required String accountNumber,
    required String tierLevel,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: ResponsiveUtils.paddingAll16,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveUtils.borderRadius12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Your Balance",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 14.sp),
                  ),
                  IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).iconTheme.color,
                      size: 20.sp,
                    ),
                    onPressed: onToggle,
                  ),
                ],
              ),
              _buildTierUpgradeButton(tierLevel),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            isVisible ? balance : "$currency •••••",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16.h),

          // Bank Name
          _infoRow("Bank Name", bankName),
          SizedBox(height: 12.h),

          // Account Name
          _infoRow("Account Name", accountName),
          SizedBox(height: 12.h),

          // Account Number
          _infoRow("Account Number", accountNumber),
        ],
      ),
    );
  }

  // Info Row with copy icon
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 13.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.copy,
              size: 18.sp, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$label copied to clipboard"),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  // Build tier upgrade button based on current tier
  Widget _buildTierUpgradeButton(String tierLevel) {
    String displayText;
    String nextTier;

    switch (tierLevel.toLowerCase()) {
      case 'one':
      case '1':
        displayText = 'Upgrade to Tier 2';
        nextTier = '2';
        break;
      case 'two':
      case '2':
        displayText = 'Upgrade to Tier 3';
        nextTier = '3';
        break;
      case 'three':
      case '3':
        displayText = 'Tier 3';
        nextTier = '3';
        break;
      default:
        displayText = 'Tier ${tierLevel.toUpperCase()}';
        nextTier = '1';
    }

    // If already at Tier 3, just show the tier level
    if (tierLevel.toLowerCase() == 'three' || tierLevel == '3') {
      return Text(
        displayText,
        style: TextStyle(
          color: appTheme.primaryColor,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // Otherwise, show clickable upgrade link
    return GestureDetector(
      onTap: () {
        context.push('/upgrade-kyc');
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayText,
            style: TextStyle(
              color: appTheme.primaryColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.arrow_forward_ios,
            color: appTheme.primaryColor,
            size: 12.sp,
          ),
        ],
      ),
    );
  }

  // Account setup card (Euro / Pound)
  Widget _accountSetupCard({
    required String flag,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: ResponsiveUtils.paddingAll12,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveUtils.borderRadius12,
      ),
      child: ListTile(
        leading: CircleAvatar(radius: 18.r, backgroundImage: AssetImage(flag)),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          style:
              Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13.sp),
        ),
        trailing: TextButton(
          onPressed: onTap,
          child: Text(
            "Setup",
            style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp),
          ),
        ),
      ),
    );
  }
}
