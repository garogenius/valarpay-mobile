import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/models/savings_models.dart';
import 'package:valarpay/features/notifiers/savings_notifier.dart';

class SavingsDetailsScreen extends ConsumerStatefulWidget {
  final String planId;

  const SavingsDetailsScreen({super.key, required this.planId});

  @override
  ConsumerState<SavingsDetailsScreen> createState() => _SavingsDetailsScreenState();
}

class _SavingsDetailsScreenState extends ConsumerState<SavingsDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savingsPlanNotifierProvider.notifier).getPlanDetails(widget.planId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savingsState = ref.watch(savingsPlanNotifierProvider);
    
    if (savingsState.isInitialLoading && (savingsState.data == null || !savingsState.data!.any((p) => p.id == widget.planId))) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFF76301))),
      );
    }

    final plan = (savingsState.data ?? []).firstWhere(
      (p) => p.id == widget.planId, 
      orElse: () => savingsState.data?.firstOrNull ?? (throw 'Plan not found')
    );
    
    final progress = plan.goalAmount > 0 ? (plan.currentAmount / plan.goalAmount).clamp(0.0, 1.0) : 0.0;
    final daysLeft = (plan.endDate ?? plan.createdAt.add(Duration(days: plan.durationMonths * 30))).difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
      appBar: AppBar(
        title: Text('Plan Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/finance/transaction-history'), 
            icon: Icon(Icons.history, size: 20, color: isDark ? Colors.white : Colors.black)
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Unified Card as per design image
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark ? null : [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    plan.name.toUpperCase(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF76301)),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress Percentage
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Detailed Information Rows
                  _buildDetailedRow('Amount Saved', '₦${NumberFormat('#,###').format(plan.currentAmount)}', isDark),
                  _buildDetailedRow('Interest Rate', '${(plan.interestRate * 100).toInt()}%', isDark),
                  _buildDetailedRow('Interest Earned So Far', '₦${NumberFormat('#,###').format(plan.currentAmount * plan.interestRate / 12)}', isDark),
                  _buildDetailedRow('Start Date', DateFormat('dd MMMM, yyyy').format(plan.createdAt), isDark),
                  _buildDetailedRow('Due Date', DateFormat('dd MMMM, yyyy').format(plan.endDate ?? plan.createdAt.add(Duration(days: plan.durationMonths * 30))), isDark), 
                  _buildDetailedRow('Day Left', '$daysLeft Days', isDark),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Navigation/Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showWithdrawDialog(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF333333) : Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showFundDialog(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF76301),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text('Fund Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.4) : Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showFundDialog(SavingsPlan plan) {
    final amountController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fund Savings Plan', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Top up your savings manually.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
            const SizedBox(height: 24),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18),
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18),
                filled: true,
                fillColor: isDark ? Colors.black26 : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0) {
                    final success = await ref.read(savingsActionNotifierProvider.notifier).fundPlan(
                      FundSavingsPlanRequest(planId: plan.id, amount: amount),
                    );
                    
                    if (mounted) {
                      if (success) {
                        ref.read(savingsPlanNotifierProvider.notifier).fetchUserPlans();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan funded successfully'), backgroundColor: Colors.green));
                      } else {
                         Navigator.pop(context);
                         final errorState = ref.read(savingsActionNotifierProvider);
                         String errorMessage = 'Funding failed';
                         if (errorState.hasError) {
                            errorMessage = errorState.error.toString().replaceAll('Exception: ', '');
                         }
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF76301),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Fund Plan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(SavingsPlan plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Withdraw Funds', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to withdraw all funds? Early withdrawal may attract a 10% penalty on interest.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              // Show loading state could be added here, but for now we block interaction
              final notifier = ref.read(savingsActionNotifierProvider.notifier);
              final success = await notifier.withdrawPlan(plan.id);
              
              if (mounted) {
                if (success) {
                  ref.read(savingsPlanNotifierProvider.notifier).fetchUserPlans();
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back from details
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Withdrawal successful'),
                      backgroundColor: Colors.green,
                    )
                  );
                } else {
                  // Handle error
                  Navigator.pop(context); // Close dialog to show error clearly
                  final errorState = ref.read(savingsActionNotifierProvider);
                  String errorMessage = 'Withdrawal failed';
                  
                  if (errorState.hasError) {
                    errorMessage = errorState.error.toString();
                    // Clean up "Exception: " prefix if present
                    errorMessage = errorMessage.replaceAll('Exception: ', '');
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    )
                  );
                }
              }
            },
            child: const Text('Withdraw All', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
