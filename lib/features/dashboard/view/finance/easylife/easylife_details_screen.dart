import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/features/models/easylife_models.dart';
import 'package:valarpay/features/notifiers/easylife_notifier.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';

class EasyLifeDetailsScreen extends ConsumerStatefulWidget {
  final String planId;

  const EasyLifeDetailsScreen({super.key, required this.planId});

  @override
  ConsumerState<EasyLifeDetailsScreen> createState() => _EasyLifeDetailsScreenState();
}

class _EasyLifeDetailsScreenState extends ConsumerState<EasyLifeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Need a getPlanDetails in notifier if we want fresh data, for now using fetchUserPlans
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(easyLifePlanNotifierProvider);
    final plan = (state.data ?? []).firstWhere((p) => p.id == widget.planId, orElse: () => throw 'Plan not found');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
      appBar: AppBar(
        title: Text(plan.name.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
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
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF76301), Color(0xFF1F1F1F)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Total EasyLife Saved', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    '₦${NumberFormat('#,###.##').format(plan.totalSaved)}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? null : [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                   buildDetailRow('Saving Target', '₦${NumberFormat('#,###.##').format(plan.goalAmount)}', isDark),
                  buildDetailRow('Frequency', plan.contributionFrequency, isDark),
                   buildDetailRow('Auto-Debit', plan.autoDebitEnabled ? 'Enabled' : 'Disabled', isDark),
                  buildDetailRow('Days Left', '${plan.durationDays} Days', isDark),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleWithdraw(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF333333) : Colors.grey[200],
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                    child: const Text('Withdraw'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleFund(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF76301),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Add Money'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBalanceDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTransactionItem(EasyLifeFunding funding, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F1F) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(DateFormat('MMM dd, yyyy').format(funding.createdAt), style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text(
            '+ ₦${NumberFormat('#,###.##').format(funding.amount)}',
            style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(EasyLifePlan plan) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _handleWithdraw(plan),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF76301)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Withdraw', style: TextStyle(color: Color(0xFFF76301), fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleFund(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF76301),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Money', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFund(EasyLifePlan plan) {
    final amountController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Money to EasyLife', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Boost your automated savings manually. Min: ₦50,000', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
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
                  if (amount != null && amount >= 50000) {
                    final success = await ref.read(easyLifeActionNotifierProvider.notifier).fundPlan(
                      FundEasyLifePlanRequest(planId: plan.id, amount: amount),
                    );
                    if (success) {
                      ref.read(easyLifePlanNotifierProvider.notifier).fetchUserPlans();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan funded successfully'), backgroundColor: Colors.green));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum deposit is ₦50,000'), backgroundColor: Colors.red));
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

  void _handleWithdraw(EasyLifePlan plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Withdraw from EasyLife', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text(
          'Do you want to withdraw your savings? Early withdrawal attracts a 1.5% penalty. Your automated rules will remain active.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final notifier = ref.read(easyLifeActionNotifierProvider.notifier);
              final success = await notifier.withdrawPlan(plan.id);
              
              if (mounted) {
                if (success) {
                  ref.read(easyLifePlanNotifierProvider.notifier).fetchUserPlans();
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
                  Navigator.pop(context); // Close dialog
                  final errorState = ref.read(easyLifeActionNotifierProvider);
                  String errorMessage = 'Withdrawal failed';
                  
                  if (errorState.hasError) {
                    errorMessage = errorState.error.toString();
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
            child: const Text('Withdraw All', style: TextStyle(color: Color(0xFFF76301))),
          ),
        ],
      ),
    );
  }
}
