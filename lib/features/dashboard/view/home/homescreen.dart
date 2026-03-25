import 'dart:async';
import 'package:valarpay/features/dashboard/view/home/widgets/balance_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/notifiers/notification_notifier.dart';
import 'package:valarpay/features/providers/idle_provider.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../../widgets/home_widgets/payment_widget_icons.dart';
import '../../widgets/home_widgets/kyc_widget.dart';
import '../../widgets/home_widgets/ourservice.dart';
import '../KYC/BVN.dart';
import '../KYC/NIN.dart';
import '../KYC/setup_pin.dart';
import '../settings/create_passcode.dart';

import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/services/dashboard_service.dart';
import '../../widgets/home_widgets/dashboard_customize_widgets.dart';
import '../../../notifiers/transaction_notifier.dart';
import 'package:valarpay/features/providers/wallet_providers.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/services/local_storage_service.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  bool _isBalanceVisible = true;
  static const String _balanceVisibilityKey = 'is_balance_visible';
  int _currentImageIndex = 0;
  Timer? _timer;
  late PageController _pageController;

  final List<String> _bannerImages = const [
    'assets/images/valar_ban1.png',
    'assets/images/valar_ban2.png',
    'assets/images/valar_ban3.png',
    'assets/images/valar_ban4.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startBannerRotation();
    _loadBalanceVisibility();

    // Fetch user data immediately on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
      ref.read(userIdleProvider.notifier).startMonitoring();
      // Fetch only notification count (lightweight)
      ref.read(notificationNotifierProvider.notifier).fetchUnreadCount();
      // Fetch transactions for recent transactions widget
      ref.read(transactionNotifierProvider.notifier).fetchTransactions(refresh: true, limit: 2);
    });
  }

  Future<void> _loadBalanceVisibility() async {
    final isVisible = await LocalStorageService.getBool(_balanceVisibilityKey);
    if (isVisible != null && mounted) {
      setState(() {
        _isBalanceVisible = isVisible;
      });
    }
  }

  Future<void> _toggleBalanceVisibility() async {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
    await LocalStorageService.saveBool(_balanceVisibilityKey, _isBalanceVisible);
  }

  void _startBannerRotation() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _bannerImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _refreshData() async {
    try {
      final updatedUser =
          await ref.read(userNotifierProvider.notifier).refreshUserProfile();
      if (updatedUser != null) {
        ref.read(userProvider.notifier).setUser(updatedUser);
      }
      // Refresh only notification count (lightweight)
      ref.read(notificationNotifierProvider.notifier).fetchUnreadCount();
      // Refresh transactions for the customized widget
      await ref.read(transactionNotifierProvider.notifier).fetchTransactions(refresh: true, limit: 2);
    } catch (e) {
      if (mounted) {
        AppMessenger.show(
          context,
          message: 'Failed to refresh data',
          type: MessageType.error,
        );
      }
    } finally {
      // Logic handled by DashboardWrapper
    }
  }

  // Consolidated security and registration checks into DashboardWrapper
  void _checkSecurityAndKycStatus() {}

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    // Fallbacks for safety
    final userName = user?.username ?? 'Guest';
    final capitalizedUserName =
        userName[0].toUpperCase() + userName.substring(1);
    // Get wallet data
    final wallet =
        user?.wallets.isNotEmpty == true ? user!.wallets.first : null;
    final balance = wallet?.formattedBalance ?? '₦0.00';
    final accountNumber = wallet?.accountNumber ?? '';

    final greeting = _getGreeting();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _HomeAppBar(
                  firstName: capitalizedUserName,
                  greeting: greeting,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      user == null 
                      ? const BalanceSkeleton() 
                      : _BalanceCard(
                        balance: balance,
                        accountNumber: accountNumber,
                        isBalanceVisible: _isBalanceVisible,
                        onToggleVisibility: _toggleBalanceVisibility,
                      ),
// Security tips card removed as requested
                      const SizedBox(height: 16),
                      const PaymentWidget(),
                      Consumer(
                        builder: (context, ref, child) {
                          final user = ref.watch(userProvider);
                          if (user != null) {
                            final isBvnVerified = user.isBvnVerified;
                            final isWalletPinSet =
                                user.isWalletPinSet;

                            // Show KYC widget if BVN is not verified OR wallet PIN is not set
                            final shouldShowKyc =
                                !isBvnVerified || !isWalletPinSet;

                            if (!shouldShowKyc) {
                              return const SizedBox(height: 12);
                            }

                            return Column(
                              children: [
                                const SizedBox(height: 16),
                                KYCWidget(user: user),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final dashboardWidget = ref.watch(dashboardProvider);
                          
                          switch (dashboardWidget) {
                            case DashboardWidgetType.banner:
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: Image.asset(
                                    _bannerImages[_currentImageIndex],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            case DashboardWidgetType.transactions:
                              return const DashboardRecentTransactionsWidget();
                            case DashboardWidgetType.kyc:
                            case DashboardWidgetType.none:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      const OurServicesWidget(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- App Bar ----------
class _HomeAppBar extends ConsumerStatefulWidget {
  final String firstName;
  final String greeting;

  const _HomeAppBar({Key? key, required this.firstName, required this.greeting})
    : super(key: key);

  @override
  ConsumerState<_HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends ConsumerState<_HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              context.push('/profile');
            },
            child: CircleAvatar(
              radius: 20,
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
                          size: 36,
                          color:
                              isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                        ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Hello, ${widget.firstName}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                widget.greeting,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: appTheme.primaryColor,
                ),
              ),
            ),
          ),
          Row(
            children: [
              _IconButton(
                svgPath: 'assets/images/payment_wid/Grouping (1).svg',
                onTap: () => context.push('/customer-service'),
              ),
              const SizedBox(width: 16),
              _IconButton(
                svgPath: 'assets/images/payment_wid/scanning.svg',
                onTap: () => context.push('/decode-qrcode'),
              ),
              const SizedBox(width: 16),
              _NotificationIconButton(
                svgPath: 'assets/images/payment_wid/bell.svg',
                onTap: () => context.push('/notifications'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final String svgPath;
  final VoidCallback? onTap;

  const _IconButton({Key? key, required this.svgPath, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        svgPath,
        width: 24,
        height: 24,
        // ignore: deprecated_member_use
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }
}

class _NotificationIconButton extends ConsumerWidget {
  final String svgPath;
  final VoidCallback? onTap;

  const _NotificationIconButton({Key? key, required this.svgPath, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the notification state to trigger rebuilds when count changes
    ref.watch(notificationNotifierProvider);

    // Get the unread count from the notifier
    final unreadCount =
        ref.read(notificationNotifierProvider.notifier).unreadCount;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SvgPicture.asset(
            svgPath,
            width: 24,
            height: 24,
            // ignore: deprecated_member_use
            color: Theme.of(context).iconTheme.color,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ---------- Balance Card ----------
class _BalanceCard extends StatelessWidget {
  final String balance;
  final String accountNumber;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;

  const _BalanceCard({
    Key? key,
    required this.balance,
    required this.accountNumber,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/payment_wid/security-safe.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFD1D5DB),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Main Balance',
                style: textTheme.bodySmall?.copyWith(color: onPrimary),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                  color: onPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/transaction-history'),
                child: Row(
                  children: [
                    Text(
                      'Transaction History',
                      style: textTheme.bodySmall?.copyWith(color: onPrimary),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      'assets/icons/arrow_right_icon.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(onPrimary, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          /// Balance Row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBalanceVisible
                        ? currencyFormatter(balance)
                        : '₦ ••••••••',
                    style: textTheme.headlineSmall?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const _AddMoneyButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddMoneyButton extends StatelessWidget {
  const _AddMoneyButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : appTheme.primaryColor;

    return GestureDetector(
      onTap: () => context.push('/add-money'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: appTheme.primaryColor, size: 20),
            const SizedBox(width: 4),
            Text(
              'Add Money',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}
