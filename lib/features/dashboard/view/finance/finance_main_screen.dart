import 'package:valarpay/features/models/savings_models.dart';
import 'package:valarpay/features/models/easylife_models.dart';
import 'package:valarpay/features/models/fixed_deposit_models.dart';
import 'package:valarpay/features/notifiers/savings_notifier.dart';
import 'package:valarpay/features/notifiers/easylife_notifier.dart';
import 'package:valarpay/features/notifiers/fixed_deposit_notifier.dart';
import 'package:valarpay/features/dashboard/view/finance/widgets/finance_plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/themes/color_utils.dart';

class FinanceMainScreen extends ConsumerStatefulWidget {
  const FinanceMainScreen({super.key});

  @override
  ConsumerState<FinanceMainScreen> createState() => _FinanceMainScreenState();
}

class _FinanceMainScreenState extends ConsumerState<FinanceMainScreen> {
  bool _isSavingsTab = true;
  String _savingsStatus = 'Active';
  String _fdStatus = 'Active';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check if user has seen the intro slider
      final hasSeenIntro = await LocalStorageService.getBool('has_seen_finance_intro') ?? false;
      if (!hasSeenIntro && mounted) {
        context.push('/finance-intro');
      }

      ref.read(savingsPlanNotifierProvider.notifier).fetchUserPlans();
      ref.read(savingsProductNotifierProvider.notifier).fetchProducts();
      ref.read(easyLifePlanNotifierProvider.notifier).fetchUserPlans();
      ref.read(easyLifeProductNotifierProvider.notifier).fetchProductInfo();
      ref.read(fixedDepositNotifierProvider.notifier).fetchUserDeposits();
      ref.read(fixedDepositPlanNotifierProvider.notifier).fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Finance',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push('/finance/transaction-history'),
            icon: Icon(Icons.history, size: 22, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(savingsPlanNotifierProvider.notifier).fetchUserPlans();
          await ref.read(savingsProductNotifierProvider.notifier).fetchProducts();
          await ref.read(easyLifePlanNotifierProvider.notifier).fetchUserPlans();
          await ref.read(easyLifeProductNotifierProvider.notifier).fetchProductInfo();
          await ref.read(fixedDepositNotifierProvider.notifier).fetchUserDeposits();
          await ref.read(fixedDepositPlanNotifierProvider.notifier).fetchPlans();
        },
        color: const Color(0xFFF76301),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 16),
            // Text(
            //   'Grow your wealth with Valarpay',
            //   style: TextStyle(
            //     color: isDark ? Colors.white70 : Colors.black54,
            //     fontSize: 14,
            //   ),
            // ),
            const SizedBox(height: 24),
            
            _buildFinanceCard(
              title: 'Target Savings',
              subtitle: 'Save with discipline towards a specific goal or project',
              interest: '${((ref.watch(savingsProductNotifierProvider).data?.where((p) => p.name.contains('FLEX_SAVE')).firstOrNull?.interestRate ?? 0.17) * 100).toInt()}% p.a',
              icon: Icons.track_changes,
              onTap: () => context.push('/finance/savings/target/plans'),
              isDark: isDark,
              gradientColors: [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)], // Blue
            ),
            const SizedBox(height: 20),
            _buildFinanceCard(
              title: 'Easylife Savings',
              subtitle: 'Save effortlessly with flexible rules that fit your lifestyle',
              interest: '${((ref.watch(easyLifeProductNotifierProvider).data?.firstOrNull?.interestRatePerAnnum ?? 0.0) * 100).toInt()}% p.a',
              icon: Icons.auto_awesome_outlined,
              onTap: () => context.push('/finance/easylife/intro'),
              isDark: isDark,
              gradientColors: [const Color(0xFF1A567E), const Color(0xFF133E5B)], // Teal/Dark Blue
            ),
            const SizedBox(height: 20),
            _buildFinanceCard(
              title: 'Fixed Deposit',
              subtitle: 'Lock a lump sum for a set period and earn higher interest',
              interest: '${((ref.watch(fixedDepositPlanNotifierProvider).data?.firstOrNull?.interestRate ?? 0.17) * 100).toInt()}% p.a',
              icon: Icons.lock_outline,
              onTap: () => context.push('/finance/fixed-deposit/plans'),
              isDark: isDark,
              gradientColors: [const Color(0xFF4338CA), const Color(0xFF3730A3)], // Indigo
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceCard({
    required String title,
    required String subtitle,
    String? interest,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Icon(icon, size: 140, color: Colors.white),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (interest != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            color: Color(0xFFF76301),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
