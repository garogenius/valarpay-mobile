import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/features/models/fixed_deposit_models.dart';
import 'package:valarpay/features/notifiers/fixed_deposit_notifier.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';

class FixedDepositDetailsScreen extends ConsumerStatefulWidget {
  final String depositId;

  const FixedDepositDetailsScreen({super.key, required this.depositId});

  @override
  ConsumerState<FixedDepositDetailsScreen> createState() => _FixedDepositDetailsScreenState();
}

class _FixedDepositDetailsScreenState extends ConsumerState<FixedDepositDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(fixedDepositNotifierProvider);
    final deposit = (state.data ?? []).firstWhere((d) => d.id == widget.depositId, orElse: () => throw 'Deposit not found');
    
    final now = DateTime.now();
    final totalDuration = deposit.maturityDate.difference(deposit.startDate).inDays;
    final elapsed = now.difference(deposit.startDate).inDays;
    final progress = totalDuration > 0 ? (elapsed / totalDuration).clamp(0.0, 1.0) : 1.0;
    final daysLeft = deposit.maturityDate.difference(now).inDays;
    final tenureMonths = (totalDuration / 30).round();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fixed Deposit'.toUpperCase(), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Progress Bar
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(3)),
                ),
                LayoutBuilder(
                  builder: (context, constraints) => Container(
                    height: 6,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(color: const Color(0xFFF76301), borderRadius: BorderRadius.circular(3)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).toInt()}%', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
            const SizedBox(height: 32),
            // Details Grid/List
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? null : [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  buildDetailRow('Deposit Amount', '₦${NumberFormat('#,###').format(deposit.amount)}', isDark),
                  buildDetailRow('Total Payout', '₦${NumberFormat('#,###').format(deposit.amount + deposit.expectedReturn)}', isDark),
                  buildDetailRow('Interest Rate', '${(deposit.interestRate * 100).toInt()}%', isDark),
                  buildDetailRow('Lock Duration', '$tenureMonths Months', isDark),
                  buildDetailRow('Due Date', DateFormat('dd MMMM, yyyy').format(deposit.maturityDate), isDark),
                  buildDetailRow('Days Left', daysLeft > 0 ? '$daysLeft Days' : 'Matured', isDark),
                  buildDetailRow('Rollover', deposit.rolloverType.replaceAll('_', ' '), isDark),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleWithdrawal(deposit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF76301),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomActions(FixedDeposit deposit) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleWithdrawal(deposit),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF76301),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Redeem Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleWithdrawal(FixedDeposit deposit) {
    final now = DateTime.now();
    final isMatured = now.isAfter(deposit.maturityDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isMatured ? 'Redeem Investment' : 'Early Withdrawal',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isMatured 
              ? 'Your investment has matured. You are about to receive ₦${NumberFormat('#,###.##').format(deposit.amount + deposit.expectedReturn)} into your wallet.'
              : 'Your investment has not matured yet. Withdrawing now will attract a penalty on your interest earnings. Do you want to proceed?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first? Or keep open?
              // The original logic closed it first. Let's stick to that but capture result.
              
              final notifier = ref.read(fixedDepositActionNotifierProvider.notifier);
              bool success;
              if (isMatured) {
                success = await notifier.maturityPayout(deposit.id);
              } else {
                success = await notifier.earlyWithdraw(deposit.id);
              }

              if (mounted) {
                if (success) {
                  ref.read(fixedDepositNotifierProvider.notifier).fetchUserDeposits();
                  Navigator.pop(context); // Go back from details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isMatured ? 'Funds redeemed to wallet' : 'Early withdrawal successful'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  // Handle error
                  // Dialog is already closed by Navigator.pop(context) above if kept there.
                  // Wait, original code had Navigator.pop(context) before async call?
                  // Yes: Navigator.pop(context); // Close dialog
                  // So we are back on details screen.
                  
                  final errorState = ref.read(fixedDepositActionNotifierProvider);
                  String errorMessage = 'Transaction failed';
                  
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
            child: Text(
              isMatured ? 'Redeem Now' : 'Withdraw Early',
              style: const TextStyle(color: Color(0xFFF76301), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
