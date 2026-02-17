import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/features/notifiers/vcard_notifier.dart';

class VCardTransactionsScreen extends ConsumerWidget {
  final String cardId;
  const VCardTransactionsScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(cardTransactionsProvider(cardId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Card Statement', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: transactionsAsync.when(
        data: (txs) => txs.isEmpty 
          ? _buildEmptyState(isDark)
          : RefreshIndicator(
              onRefresh: () => ref.refresh(cardTransactionsProvider(cardId).future),
              color: appTheme.primaryColor,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: txs.length,
                separatorBuilder: (_, __) => Divider(color: isDark ? Colors.white10 : Colors.grey.shade200, height: 32),
                itemBuilder: (context, index) {
                  final tx = txs[index];
                  final isDebit = tx.transactionType.toUpperCase() == 'DEBIT';
                  
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isDebit ? Colors.red : Colors.green).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDebit ? Icons.arrow_outward : Icons.arrow_downward,
                          color: isDebit ? Colors.red : Colors.green,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.merchantName.isNotEmpty ? tx.merchantName : tx.description,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tx.description,
                              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade600, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isDebit ? '-' : '+'}${tx.currency} ${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isDebit ? (isDark ? Colors.white : Colors.black) : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(tx.timestamp),
                            style: TextStyle(color: isDark ? Colors.white24 : Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
        loading: () => Center(child: CircularProgressIndicator(color: appTheme.primaryColor)),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_toggle_off, color: isDark ? Colors.white10 : Colors.grey.shade300, size: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'No transactions yet',
            style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Your card activity will appear here',
            style: TextStyle(color: isDark ? Colors.white10 : Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
