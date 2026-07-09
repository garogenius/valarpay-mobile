import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/models/wallet.dart';

class MultiCurrencyDashboardScreen extends ConsumerStatefulWidget {
  final String currency;

  const MultiCurrencyDashboardScreen({super.key, required this.currency});

  @override
  ConsumerState<MultiCurrencyDashboardScreen> createState() => _MultiCurrencyDashboardScreenState();
}

class _MultiCurrencyDashboardScreenState extends ConsumerState<MultiCurrencyDashboardScreen> {
  bool _isBalanceVisible = true;
  bool _isLoading = true;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(userNotifierProvider.notifier).refreshUserProfile();
      if (mounted) {
        final user = ref.read(userProvider);
        int initialIndex = 0;
        if (user != null && user.wallets.isNotEmpty) {
          initialIndex = user.wallets.indexWhere((w) => w.currency.toUpperCase() == widget.currency.toUpperCase());
          if (initialIndex == -1) initialIndex = 0;
        }
        
        setState(() {
          _isLoading = false;
          _currentPage = initialIndex;
        });
        
        if (initialIndex > 0 && _pageController.hasClients) {
          _pageController.jumpToPage(initialIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final wallets = user?.wallets ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          "Global Accounts",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Theme.of(context).iconTheme.color),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Theme.of(context).iconTheme.color),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWalletsCarousel(wallets),
                  const SizedBox(height: 16),
                  _buildPageIndicator(wallets.length),
                  const SizedBox(height: 32),
                  _buildActionRow(),
                  const SizedBox(height: 32),
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildWalletsCarousel(List<WalletModel> wallets) {
    if (wallets.isEmpty) {
      return Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text("No accounts found.")),
      );
    }

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          // Use different gradients based on currency
          final isNgn = wallet.currency.toUpperCase() == 'NGN';
          final gradientColors = isNgn
              ? [appTheme.primaryColor, appTheme.primaryColor.withOpacity(0.8)]
              : [const Color(0xFF3A486B), const Color(0xFF5A6A8E)];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildWalletCard(wallet, gradientColors),
          );
        },
      ),
    );
  }

  Widget _buildWalletCard(WalletModel wallet, List<Color> gradientColors) {
    final balance = wallet.formattedBalance;
    final currencyCode = wallet.currency.toUpperCase();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$currencyCode WALLET',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AVAILABLE BALANCE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _isBalanceVisible ? balance : '••••••••',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (wallet.currency.toUpperCase() == 'NGN') {
                        context.push('/add-money');
                      } else {
                        context.push('/swap-currency');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(wallet.currency.toUpperCase() == 'NGN' ? Icons.add : Icons.currency_exchange, color: appTheme.primaryColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            wallet.currency.toUpperCase() == 'NGN' ? 'Add' : 'Convert',
                            style: TextStyle(
                              color: appTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    if (count <= 1) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: isActive ? 24 : 6,
          decoration: BoxDecoration(
            color: isActive ? appTheme.primaryColor : Colors.grey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionItem(
            icon: Icons.send,
            label: 'Payout',
            onTap: () => context.push('/payout/${widget.currency}'),
          ),
          _buildActionItem(
            icon: Icons.currency_exchange,
            label: 'Swap',
            onTap: () => context.push('/swap-currency'),
          ),
          _buildActionItem(
            icon: Icons.credit_card,
            label: 'Cards',
            onTap: () => context.push('/cards'),
          ),
          _buildActionItem(
            icon: Icons.account_balance,
            label: 'Account',
            onTap: () => context.push('/account-setup', extra: widget.currency),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: appTheme.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/transaction-history'),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: appTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: appTheme.primaryColor, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildTransactionItem(
                  title: 'No recent activity',
                  subtitle: 'Your transactions will appear here',
                  amount: '',
                  icon: Icons.history,
                  isPositive: false,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    required bool isPositive,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.1) : appTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isPositive ? Colors.green : appTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (amount.isNotEmpty)
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
      ],
    );
  }
}
