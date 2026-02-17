import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/features/notifiers/transaction_notifier.dart';
import 'package:valarpay/features/models/transaction_model.dart';

class FinanceTransactionHistoryScreen extends ConsumerStatefulWidget {
  const FinanceTransactionHistoryScreen({super.key});

  @override
  ConsumerState<FinanceTransactionHistoryScreen> createState() => _FinanceTransactionHistoryScreenState();
}

class _FinanceTransactionHistoryScreenState extends ConsumerState<FinanceTransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionNotifierProvider.notifier).fetchTransactions(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionState = ref.watch(transactionNotifierProvider);
    final transactions = transactionState.data ?? [];

    // Filter by search query
    final filteredTransactions = transactions.where((tx) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return tx.description.toLowerCase().contains(query) ||
             tx.category.toLowerCase().contains(query) ||
             (tx.transactionRef?.toLowerCase().contains(query) ?? false);
    }).toList();

    // Group by month
    final groupedTransactions = <String, List<TransactionModel>>{};
    for (var tx in filteredTransactions) {
      final month = DateFormat('MMM yyyy').format(tx.createdAt).toUpperCase();
      if (!groupedTransactions.containsKey(month)) {
        groupedTransactions[month] = [];
      }
      groupedTransactions[month]!.add(tx);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
      appBar: AppBar(
        title: Text('Transaction History', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search transactions',
                hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black38, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.white24 : Colors.black38, size: 20),
                filled: true,
                fillColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24), 
                  borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: transactionState.isInitialLoading
                ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
                : RefreshIndicator(
                    onRefresh: () => ref.read(transactionNotifierProvider.notifier).refresh(),
                    color: Theme.of(context).primaryColor,
                    child: filteredTransactions.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: groupedTransactions.length,
                            itemBuilder: (context, index) {
                              final month = groupedTransactions.keys.elementAt(index);
                              final monthTxs = groupedTransactions[month]!;
                              
                              double totalIn = 0;
                              double totalOut = 0;
                              for (var tx in monthTxs) {
                                if (tx.isSuccessful) {
                                  if (tx.isCredit) totalIn += tx.amount;
                                  else totalOut += tx.amount;
                                }
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildMonthHeader(month, totalIn, totalOut, isDark),
                                  ...monthTxs.map((tx) => _buildTransactionItem(context, tx, isDark)),
                                ],
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            'No transactions found', 
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14)
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(String month, double totalIn, double totalOut, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                month, 
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.bold)
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white : Colors.black, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('In ', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
              Text(
                '₦${NumberFormat('#,###').format(totalIn)}', 
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11, fontWeight: FontWeight.bold)
              ),
              const SizedBox(width: 12),
              Text('Out ', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
              Text(
                '₦${NumberFormat('#,###').format(totalOut)}', 
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel tx, bool isDark) {
    String title = tx.description.isNotEmpty ? tx.description : tx.category;

    if (tx.category.toUpperCase() == 'BILL_PAYMENT' ||
        tx.category.toUpperCase() == 'BILL') {
        // Use network if available (e.g. Airtel), otherwise provider (e.g. PalmPay)
        // This gives better context like "Airtel Airtime" instead of "PalmPay Airtime"
        final rawProvider = tx.billDetails?.network ??
            tx.billDetails?.provider ??
            '';
        
        // Capitalize first letter
        final provider = rawProvider.isNotEmpty
            ? rawProvider[0].toUpperCase() +
                (rawProvider.length > 1
                    ? rawProvider.substring(1).toLowerCase()
                    : '')
            : '';
      
      final rawType = (tx.billDetails?.billType ?? '').trim().toUpperCase();

      String displayType;
      if (rawType == 'AIRTIME') {
        displayType = 'Airtime';
      } else if (rawType == 'DATA' || rawType == 'MOBILE_DATA') {
        displayType = 'Mobile Data';
      } else if (rawType == 'CABLE' ||
          rawType == 'TV' ||
          rawType == 'CABLE_TV') {
        displayType = 'Cable TV';
      } else if (rawType == 'ELECTRICITY') {
        displayType = 'Electricity';
      } else if (rawType == 'GIFTCARD' || rawType == 'GIFT_CARD') {
        displayType = 'Gift Card';
      } else if (rawType == 'INTERNATIONAL_AIRTIME') {
        displayType = 'Intl. Airtime';
      } else {
        // Fallback: Check description for keywords if billType is generic
        final desc = tx.description.toUpperCase();
        if (desc.contains('AIRTIME')) {
          displayType = 'Airtime';
        } else if (desc.contains('DATA') || desc.contains('BUNDLE')) {
          displayType = 'Mobile Data';
        } else if (desc.contains('CABLE') || desc.contains('TV')) {
          displayType = 'Cable TV';
        } else if (desc.contains('ELECTRICITY') || desc.contains('POWER')) {
          displayType = 'Electricity';
        } else {
          displayType = tx.billDetails?.billType ?? 'Bill Payment';
        }
      }

      title = provider.isEmpty ? displayType : '$provider $displayType';
    }
    final subtitle = DateFormat('MMMM dd, yyyy h:mm a').format(tx.createdAt);
    final amount = tx.amount;
    final isCredit = tx.isCredit;

    return InkWell(
      onTap: () => context.push('/transaction-details', extra: tx),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : Colors.grey[100], 
                borderRadius: BorderRadius.circular(12)
              ),
              child: Icon(_getIconForCategory(tx.category), color: Theme.of(context).primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w600), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: isDark ? Colors.white24 : Colors.black38, fontSize: 11)),
                ],
              ),
            ),
            Text(
              '${isCredit ? '+' : '-'}₦${NumberFormat('#,###.##').format(amount)}',
              style: TextStyle(
                color: isCredit ? const Color(0xFF4CAF50) : const Color(0xFFF44336), 
                fontSize: 14, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'DEPOSIT': return Icons.add_circle_outline;
      case 'TRANSFER': return Icons.send_outlined;
      case 'BILL_PAYMENT':
      case 'BILL': return Icons.receipt_long_outlined;
      case 'WITHDRAWAL': return Icons.account_balance_wallet_outlined;
      case 'INVESTMENT': return Icons.trending_up_outlined;
      default: return Icons.sync_alt;
    }
  }
}

