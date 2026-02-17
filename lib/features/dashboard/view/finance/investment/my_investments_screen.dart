import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/features/notifiers/investment_notifier.dart';

class MyInvestmentsScreen extends ConsumerStatefulWidget {
  const MyInvestmentsScreen({super.key});

  @override
  ConsumerState<MyInvestmentsScreen> createState() => _MyInvestmentsScreenState();
}

class _MyInvestmentsScreenState extends ConsumerState<MyInvestmentsScreen> {
  String? _selectedStatus;
  int _currentPage = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInvestments();
    });
  }

  void _fetchInvestments() {
    ref.read(investmentListNotifierProvider.notifier).fetchUserInvestments(
      status: _selectedStatus,
      page: _currentPage,
      limit: _limit,
      isBackgroundLoad: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(investmentListNotifierProvider);
    final investments = state.data ?? [];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        title: Text('Invest', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => context.go('/finance'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push('/finance/transaction-history'),
            child: Text('History', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          // Summary Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            height: 140,
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
                          Text('Total Investment', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
                          const SizedBox(height: 8),
                          Text(
                            '₦${NumberFormat('#,###').format(_calculateTotal(investments))}',
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Interest Earned', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
                          const SizedBox(height: 8),
                          Text(
                            '₦${NumberFormat('#,###').format(_calculateInterest(investments))}',
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
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
                      Icons.trending_up, // Investment icon
                      size: 150,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status Filter Tabs (Styled closer to standard tabs)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildFilterChip('Active', 'ACTIVE'),
                const SizedBox(width: 16), // Increased spacing
                _buildFilterChip('Completed', 'MATURED'),
                const SizedBox(width: 16),
                _buildFilterChip('Cancelled', 'CANCELLED'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // "Create New Goal" / "New Investment" - aligned with list
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/finance/investment/create'),
                  child: Text(
                    'Create New Investment',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isInitialLoading
                ? const SizedBox.shrink()
                : !state.isDataAvailable || investments.isEmpty
                      ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async => _fetchInvestments(),
                        color: Theme.of(context).primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: investments.length,
                          itemBuilder: (context, index) {
                            final investment = investments[index];
                            return _buildInvestmentCard(investment, isDark);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/finance/investment/create'),
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Investment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: isDark ? null : [
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
          Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = (_selectedStatus == status) || 
                       (_selectedStatus == null && status == 'ACTIVE');
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
          _currentPage = 1;
        });
        _fetchInvestments();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : (isDark ? const Color(0xFF1F1F1F) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInvestmentCard(investment, bool isDark) {
    final statusColor = _getStatusColor(investment.status);
    final daysLeft = investment.maturityDate.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () => context.push('/finance/investment/details/${investment.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
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
                child: const Icon(Icons.trending_up, size: 140, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Premium Investment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          investment.status,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Principal', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '₦${NumberFormat('#,###.##').format(investment.amount)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Returns', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '₦${NumberFormat('#,###.##').format(investment.expectedReturn)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(investment.roiRate * 100).toInt()}% ROI',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        daysLeft > 0 ? '$daysLeft days left' : 'Matured',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: isDark ? Colors.white.withOpacity(0.3) : Colors.black12),
          const SizedBox(height: 16),
          Text(
            'You have no active investments',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Start investing today to grow your wealth',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/finance/investment/create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Investing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFF4CAF50);
      case 'MATURED':
        return const Color(0xFF2196F3);
      case 'PAID_OUT':
        return const Color(0xFF9C27B0);
      case 'CANCELLED':
        return const Color(0xFFF44336);
      case 'PENDING':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  double _calculateTotal(List investments) {
    return investments.fold(0.0, (sum, inv) => sum + inv.amount);
  }

  double _calculateInterest(List investments) {
    return investments.fold(0.0, (sum, inv) => sum + (inv.expectedReturn - inv.amount));
  }
}
