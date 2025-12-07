import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/utils/responsive_utils.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class AddMoneyTransferScreen extends ConsumerStatefulWidget {
  const AddMoneyTransferScreen({super.key});

  @override
  ConsumerState<AddMoneyTransferScreen> createState() =>
      _AddMoneyTransferScreenState();
}

class _AddMoneyTransferScreenState
    extends ConsumerState<AddMoneyTransferScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user profile when screen loads to get latest wallet data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userNotifierProvider.notifier).refreshUserProfile();
    });
  }

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    AppMessenger.show(
      context,
      message: '$label copied to clipboard',
      type: MessageType.success,
    );
  }

  Future<void> _shareToWhatsApp(
    String bankName,
    String accountName,
    String accountNumber,
  ) async {
    final message =
        'Bank Name: $bankName\nAccount Name: $accountName\nAccount Number: $accountNumber';
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'whatsapp://send?text=$encodedMessage';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          AppMessenger.show(
            context,
            message: 'WhatsApp is not installed on this device',
            type: MessageType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppMessenger.show(
          context,
          message: 'Could not open WhatsApp',
          type: MessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user data from provider
    final user = ref.watch(userProvider);

    final wallet =
        user?.wallets.isNotEmpty == true ? user!.wallets.first : null;

    // Extract wallet data
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
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Bank Transfer",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body:
          wallet == null
              ? _buildNoWalletView(context)
              : Padding(
                padding: ResponsiveUtils.paddingAll16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Card
                    Container(
                      padding: ResponsiveUtils.paddingAll16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: ResponsiveUtils.borderRadius12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tier ${tierLevel == 'one' ? '1' : tierLevel.toUpperCase()}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: appTheme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 12.h),

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
                    ),

                    SizedBox(height: 20.h),

                    // Share Buttons Row
                    Row(
                      children: [
                        // WhatsApp Share Button
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(
                                  0xFF25D366,
                                ), // WhatsApp green
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                              ),
                              onPressed: () {
                                _shareToWhatsApp(
                                  bankName,
                                  accountName,
                                  accountNumber,
                                );
                              },
                              icon: Icon(
                                Icons.chat,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                              label: Text(
                                "WhatsApp",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // General Share Button
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                              ),
                              onPressed: () {
                                Share.share(
                                  'Bank Name: $bankName\nAccount Name: $accountName\nAccount Number: $accountNumber',
                                );
                              },
                              icon: Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                              label: Text(
                                "Share",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Instructions Card
                    Container(
                      width: double.infinity,
                      padding: ResponsiveUtils.paddingAll16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: ResponsiveUtils.borderRadius12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fund your ValarPay wallet easily in three quick steps",
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "Step 1: Copy your unique ValarPay account number from the app.\n"
                            "Step 2: Open your mobile banking app and initiate a transfer.\n"
                            "Step 3: Send the desired amount, and your ValarPay wallet will be credited instantly.",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontSize: 13.sp, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // Info row with copy action
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 13.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.copy,
            size: 18.sp,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => _copyToClipboard(label, value),
        ),
      ],
    );
  }

  // No wallet view - for users without wallet
  Widget _buildNoWalletView(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.paddingAll24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 24.h),
            Text(
              'Virtual Account Not Created',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Complete your BVN verification to create your virtual account and start receiving money',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to KYC setup
                  // context.push('/kyc-setup');
                },
                child: Text(
                  "Complete KYC",
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
