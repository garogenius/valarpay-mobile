import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/features/notifiers/investment_notifier.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';

class InvestmentDetailsScreen extends ConsumerStatefulWidget {
  final String investmentId;

  const InvestmentDetailsScreen({super.key, required this.investmentId});

  @override
  ConsumerState<InvestmentDetailsScreen> createState() => _InvestmentDetailsScreenState();
}

class _InvestmentDetailsScreenState extends ConsumerState<InvestmentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(investmentDetailsNotifierProvider.notifier).fetchInvestmentDetails(widget.investmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(investmentDetailsNotifierProvider);
    final investment = state.data?.firstOrNull;

    if (state.isInitialLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Investment Details', style: Theme.of(context).appBarTheme.titleTextStyle),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const SizedBox.shrink(),
      );
    }

    if (!state.isDataAvailable || investment == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Investment Details', style: Theme.of(context).appBarTheme.titleTextStyle),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: isDark ? Colors.white54 : Colors.black54),
              const SizedBox(height: 16),
              Text('Investment not found', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final daysLeft = investment.maturityDate.difference(DateTime.now()).inDays;
    final progress = investment.startDate.difference(DateTime.now()).inDays.abs() / 
                     investment.maturityDate.difference(investment.startDate).inDays;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
      appBar: AppBar(
        title: Text('Investment Details', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(investment.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                investment.status,
                style: TextStyle(
                  color: _getStatusColor(investment.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Investment Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
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
              child: Column(
                children: [
                  const Text('Expected Return', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    '₦${NumberFormat('#,###.##').format(investment.expectedReturn)}',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
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
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('ROI', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '${(investment.roiRate * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Investment Progress', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('${(progress * 100).clamp(0, 100).toInt()}%', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    daysLeft > 0 ? '$daysLeft days until maturity' : 'Investment has matured',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Investment Details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  buildDetailRow('Tenure', '${investment.tenureMonths} Months', isDark),
                  buildDetailRow('Start Date', DateFormat('dd MMMM, yyyy').format(investment.startDate), isDark),
                  buildDetailRow('Maturity Date', DateFormat('dd MMMM, yyyy').format(investment.maturityDate), isDark),
                  buildDetailRow('Interest Rate', '${(investment.roiRate * 100).toInt()}%', isDark),
                  buildDetailRow('Interest Earned', '₦${NumberFormat('#,###.##').format(investment.expectedReturn - investment.amount)}', isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transaction Details (if available)
            if (investment.transaction != null) ...[
              Text('Transaction Details', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark ? null : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    buildDetailRow('Transaction ID', investment.transaction!.id, isDark),
                    buildDetailRow('Type', investment.transaction!.type, isDark),
                    buildDetailRow('Amount', '₦${NumberFormat('#,###.##').format(investment.transaction!.amount)}', isDark),
                    buildDetailRow('Status', investment.transaction!.status, isDark),
                    buildDetailRow('Date', DateFormat('dd MMM yyyy, HH:mm').format(investment.transaction!.createdAt), isDark),
                  ],
                ),
              ),
            ],
          ],
        ),
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
}
