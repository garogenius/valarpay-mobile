import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/features/providers/idle_provider.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class ProfileHeaderCard extends ConsumerStatefulWidget {
  final VoidCallback? onSecurityTipsTap;
  final VoidCallback? onRewardsTap;

  const ProfileHeaderCard({Key? key, this.onSecurityTipsTap, this.onRewardsTap})
    : super(key: key);

  @override
  ConsumerState<ProfileHeaderCard> createState() => _ProfileHeaderCardState();
}

class _ProfileHeaderCardState extends ConsumerState<ProfileHeaderCard> {
  bool isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
    // Refresh user profile when screen loads to get latest wallet data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(userNotifierProvider.notifier).refreshUserProfile();

      final bool isLoggedIn = await SessionService.isLoggedIn();
      if (!isLoggedIn) {
        SessionService(context).logout();
        ref.read(userIdleProvider.notifier).stopMonitoring();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get user data from provider
    final user = ref.watch(userProvider);
    final wallet =
        user?.wallets.isNotEmpty == true ? user!.wallets.first : null;

    // Extract user data
    String userName = "Guest";
    if (user?.fullname != null && user!.fullname.isNotEmpty) {
      userName = user.username;
    } else if (user?.username != null) {
      userName = user!.username;
    }

    // Capitalize first letter of username
    if (userName.isNotEmpty) {
      userName = userName[0].toUpperCase() + userName.substring(1);
    }
    final accountNumber = wallet?.accountNumber ?? '0000000000';
    final balance = wallet?.balance ?? 0.0;

    const double rewardsAmount = 0.00;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Top Row (Profile + Settings)
          Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                child: ClipOval(
                  child:
                      user?.profileImageUrl != null &&
                              user!.profileImageUrl!.isNotEmpty
                          ? Image.network(
                            user.profileImageUrl!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          )
                          : Icon(
                            Icons.person,
                            size: 24,
                            color:
                                isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                          ),
                ),
              ),

              const SizedBox(width: 12),

              // Name + Account
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $userName",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            accountNumber,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? const Color(0xFF6B7280)
                                      : Colors.black,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: accountNumber),
                            );

                            AppMessenger.show(
                              context,
                              type: MessageType.success,
                              message: 'Account number copied',
                            );
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Settings icon
              InkWell(
                onTap: () => context.push('/settings'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/settings_icon.svg",
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF4B5563),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance + Rewards
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Your Balance",
                          style: TextStyle(
                            color:
                                isDark ? const Color(0xFF6B7280) : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isBalanceVisible = !isBalanceVisible;
                            });
                          },
                          child: Icon(
                            isBalanceVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 14,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBalanceVisible
                          ? currencyFormatter(balance.toString())
                          : "₦ •••••",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: widget.onRewardsTap,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Your Rewards",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "₦${rewardsAmount.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Security button
              InkWell(
                onTap: widget.onSecurityTipsTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: appTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "View Security Tips",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
