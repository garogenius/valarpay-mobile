import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/features/notifiers/transaction_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/dashboard/view/KYC/BVN.dart';
import 'package:valarpay/features/dashboard/view/KYC/setup_pin.dart';
import 'package:valarpay/core/themes/color_utils.dart';

class DashboardRecentTransactionsWidget extends ConsumerWidget {
  const DashboardRecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionNotifierProvider);
    final transactions = transactionState.data ?? [];
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimary = Colors.white; // Typical for the app's primary orange

    if (transactionState.isInitialLoading) {
      return _buildLoading(context, primaryColor);
    }

    if (transactions.isEmpty) {
      return _buildEmpty(context, primaryColor, onPrimary);
    }

    final itemsToShow = transactions.take(2).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12), // Consistency with rest of app
      ),
      child: Column(
        children: List.generate(itemsToShow.length, (index) {
          final tx = itemsToShow[index];
          final isLast = index == itemsToShow.length - 1;
          final isReceived = tx.type.toLowerCase() == 'credit';

          return GestureDetector(
            onTap: () {
              context.push('/transaction-details', extra: tx);
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: '${isReceived ? 'Received' : 'Sent'}',
                                style: TextStyle(
                                  color: onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' · ${tx.category}',
                                    style: TextStyle(
                                      color: onPrimary.withOpacity(0.8),
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isReceived ? '+' : '-'}₦${currencyFormatter(tx.amount.toString()).replaceFirst('₦', '')}',
                        style: TextStyle(
                          color: onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: onPrimary.withOpacity(0.2),
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoading(BuildContext context, Color primaryColor) {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, Color primaryColor, Color onPrimary) {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'No recent transactions',
          style: TextStyle(
            color: onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class DashboardKYCProgressWidget extends ConsumerWidget {
  const DashboardKYCProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user == null) return const SizedBox();

    final isBvnVerified = user.isBvnVerified;
    final isWalletPinSet = user.isWalletPinSet;
    final isNinVerified = user.isNinVerified;

    int completedSteps = 0;
    if (isBvnVerified) completedSteps++;
    if (isWalletPinSet) completedSteps++;
    if (isNinVerified) completedSteps++;

    const int totalSteps = 3;
    final double progress = completedSteps / totalSteps;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Complete your KYC',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (completedSteps < totalSteps)
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isBvnVerified) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BVNPage()));
                      } else if (!isWalletPinSet) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupTransactionPinPage()));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Complete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$completedSteps/$totalSteps',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
