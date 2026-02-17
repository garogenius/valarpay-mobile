import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/features/models/savings_models.dart';
import 'package:valarpay/features/notifiers/savings_notifier.dart';
import 'package:valarpay/features/dashboard/view/finance/widgets/finance_plan_card.dart';

class TargetSavingsScreen extends ConsumerStatefulWidget {
  const TargetSavingsScreen({super.key});

  @override
  ConsumerState<TargetSavingsScreen> createState() => _TargetSavingsScreenState();
}

class _TargetSavingsScreenState extends ConsumerState<TargetSavingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _type = 'TARGET';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savingsPlanNotifierProvider.notifier).fetchUserPlans();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savingsState = ref.watch(savingsPlanNotifierProvider);
    final allPlans = savingsState.data ?? [];
    final targetPlans = allPlans.where((p) => p.type.contains('FLEX_SAVE')).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Target Savings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push('/finance/transaction-history'),
            child: Text(
              'History',
              style: TextStyle(color: appTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: targetPlans.isEmpty && !savingsState.isInitialLoading
          ? _buildEmptyState(isDark)
          : Column(
              children: [
                _buildSummaryHeader(targetPlans, isDark),
                const SizedBox(height: 0), // Reduced gap
                _buildTabBar(isDark),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPlansList(targetPlans.where((p) => p.status.toUpperCase() == 'ACTIVE').toList(), isDark),
                      _buildPlansList(targetPlans.where((p) => p.status.toUpperCase() != 'ACTIVE').toList(), isDark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader(List<SavingsPlan> plans, bool isDark) {
    final totalSaved = plans.fold(0.0, (sum, p) => sum + p.currentAmount);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isDark ? null : Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Total Targets', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('${plans.length}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Total Saved', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(
                      '₦${NumberFormat('#,###.##').format(totalSaved)}',
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.track_changes, // Target icon
                size: 120,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: const Color(0xFFF76301),
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: isDark ? Colors.white : Colors.black,
                unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                dividerColor: Colors.transparent,
                labelPadding: const EdgeInsets.only(right: 20),
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/finance/savings/create/TARGET'),
            child: Text(
              'Create New Goal',
              style: TextStyle(
                color: appTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList(List<SavingsPlan> plans, bool isDark) {
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.account_balance_wallet_outlined, size: 80, color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 16),
            Text(
              _tabController.index == 0 ? 'You do not have any active Target' : 'You do not have any completed Target',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/finance/savings/create/TARGET'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF76301),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Create Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return FinancePlanCard(
          title: plan.name,
          amount: plan.currentAmount,
          targetAmount: plan.goalAmount,
          status: plan.status,
          date: plan.createdAt,
          durationDays: plan.durationMonths * 30,
          type: FinancePlanType.target,
          onTap: () => context.push('/finance/savings/details/${plan.id}'),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryHeader([], isDark),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Start', 
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a popular savings goal or create your own.', 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildRecommendationCard(
                        title: 'House Rent', 
                        subtitle: 'Save specifically for your rent',
                        icon: Icons.home_work_outlined,
                        color: const Color(0xFF2196F3),
                        isDark: isDark,
                        onTap: () => context.push('/finance/savings/create/TARGET', extra: {'targetType': 'Rent'}),
                      ),
                      _buildRecommendationCard(
                        title: 'New Car', 
                        subtitle: 'Drive your dream car sooner',
                        icon: Icons.directions_car_outlined,
                        color: const Color(0xFFFF9800),
                        isDark: isDark,
                        onTap: () => context.push('/finance/savings/create/TARGET', extra: {'targetType': 'Travel'}), 
                      ),
                      _buildRecommendationCard(
                        title: 'Business', 
                        subtitle: 'Grow your business capital',
                        icon: Icons.business_center_outlined,
                        color: const Color(0xFF4CAF50),
                        isDark: isDark,
                        onTap: () => context.push('/finance/savings/create/TARGET', extra: {'targetType': 'Business'}),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/finance/savings/create/TARGET'),
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Create Custom Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color, 
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : Border.all(color: Colors.grey.shade100),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle, 
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        )
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward, size: 16, color: isDark ? Colors.white54 : Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
