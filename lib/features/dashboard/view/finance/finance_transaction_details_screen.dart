import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:valarpay/features/models/transaction_model.dart';

class FinanceTransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;

  const FinanceTransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = (transaction.description.isNotEmpty ? transaction.description : transaction.category).toUpperCase();
    final isCredit = transaction.isCredit;
    final amount = transaction.amount;

    String type = isCredit ? 'Credit' : 'Debit';
    String status = transaction.status.toUpperCase();
    Color statusColor = transaction.isSuccessful ? const Color(0xFF4CAF50) : (transaction.isFailed ? Colors.red : Colors.orange);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
      appBar: AppBar(
        title: Text('Transaction Details', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? null : [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F0F0F) : Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF76301).withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.wallet, color: Color(0xFFF76301), size: 24),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    '${isCredit ? '+' : '-'}₦${NumberFormat('#,###.00').format(amount)}',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Transaction $status',
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
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
                  _buildDetailRow('Transaction Type', type, isDark),
                  _buildDetailRow('Category', transaction.category, isDark),
                  if (transaction.transactionRef != null)
                    _buildDetailRow('Transaction REF', transaction.transactionRef!, isDark, hasCopy: true),
                  _buildDetailRow('Wallet ID', transaction.walletId, isDark, hasCopy: true),
                  _buildDetailRow('Current Balance', '₦${NumberFormat('#,###.00').format(transaction.currentBalance)}', isDark),
                  _buildDetailRow('Date & Time', DateFormat('dd MMM, yyyy | h:mm a').format(transaction.createdAt), isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {bool hasCopy = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value, 
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasCopy) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                    },
                    child: const Icon(Icons.copy_outlined, color: Color(0xFFF76301), size: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

