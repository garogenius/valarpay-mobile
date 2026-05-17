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
import 'package:valarpay/features/dashboard/widgets/services_widgets/swap_currency_widgets/currency_selector_modal.dart'; // Import supportedCurrencies
import 'package:valarpay/features/models/wallet.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool showBalances = false;

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
    final wallets = user?.wallets ?? [];
    final tierLevel = user?.tierLevel ?? 'notSet';
    
    // Map existing currencies to speed up filtering
    final existingCurrencies = wallets.map((w) => w.currency.toUpperCase()).toSet();
    
    // Filter supported currencies to show ONLY those NOT yet activated
    // We skip NGN from the list as it is the base account
    final availableSetupCurrencies = supportedCurrencies.where((c) {
      final code = c.code.toUpperCase();
      return code != 'NGN' && !existingCurrencies.contains(code);
    }).toList();

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
          "Accounts",
           style: TextStyle(
            fontSize: 18.sp,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Render Active Wallet Cards
            ...wallets.map((wallet) {
              final isNgn = wallet.currency.toUpperCase() == 'NGN';
              
              return Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: _accountCard(
                  wallet: wallet,
                  tierLevel: tierLevel,
                  showTierUpgrade: isNgn, // Only show upgrade link on main NGN wallet
                  isVisible: showBalances,
                  onToggle: () => setState(() => showBalances = !showBalances),
                ),
              );
            }),

            // 2. Display "Get a new account" header if there are available currencies
            if (availableSetupCurrencies.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                child: Text(
                  "Get a New Account",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 3. Render Setup Cards dynamically for non-activated currencies
              ...availableSetupCurrencies.map((currency) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _accountSetupCard(
                    flag: currency.flagAsset,
                    emoji: currency.emoji,
                    title: "Get ${currency.code} Account",
                    subtitle: "Open a secure ${currency.name.toLowerCase()} account",
                    onTap: () {
                      context.push('/account-setup', extra: currency.code);
                    },
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  // Reusable Account Card
  Widget _accountCard({
    required WalletModel wallet,
    required String tierLevel,
    required bool showTierUpgrade,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    final currency = wallet.currency.toUpperCase();
    final formattedBalance = wallet.formattedBalance;
    final bankName = wallet.bankName.isNotEmpty ? wallet.bankName : "ValarPay";
    final accountName = wallet.accountName;
    final accountNumber = wallet.accountNumber;

    // Get masked symbol
    String masked = "$currency •••••";
    if (currency == 'NGN') masked = "₦ •••••";
    else if (currency == 'USD') masked = "\$ •••••";
    else if (currency == 'EUR') masked = "€ •••••";
    else if (currency == 'GBP') masked = "£ •••••";
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
              if (showTierUpgrade) _buildTierUpgradeButton(tierLevel),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            isVisible ? formattedBalance : masked,
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
    String? emoji,
  }) {
    return Container(
      padding: ResponsiveUtils.paddingAll12,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveUtils.borderRadius12,
      ),
      child: ListTile(
        leading: emoji != null
            ? Text(
                emoji,
                style: TextStyle(fontSize: 24.sp),
              )
            : CircleAvatar(radius: 18.r, backgroundImage: AssetImage(flag)),
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
