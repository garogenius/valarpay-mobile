import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/features/models/transaction_model.dart';
import 'package:valarpay/features/notifiers/transaction_notifier.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';

class FinanceTransactionDetailsScreen extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const FinanceTransactionDetailsScreen({super.key, required this.transaction});

  @override
  ConsumerState<FinanceTransactionDetailsScreen> createState() =>
      _FinanceTransactionDetailsScreenState();
}

class _FinanceTransactionDetailsScreenState
    extends ConsumerState<FinanceTransactionDetailsScreen> {
  late TransactionModel _transaction;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _checkStatus(String billRef, bool isGiftCard) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ref
          .read(transactionNotifierProvider.notifier)
          .checkTransactionStatus(
            transactionId: _transaction.id,
            billRef: billRef,
            isGiftCard: isGiftCard,
          );

      if (result != null) {
        setState(() {
          _transaction = TransactionModel(
            id: _transaction.id,
            walletId: _transaction.walletId,
            transactionRef: _transaction.transactionRef,
            type: _transaction.type,
            category: _transaction.category,
            currency: _transaction.currency,
            status: result.toLowerCase(),
            description: _transaction.description,
            previousBalance: _transaction.previousBalance,
            currentBalance: _transaction.currentBalance,
            reference: _transaction.reference,
            billDetails: _transaction.billDetails,
            transferDetails: _transaction.transferDetails,
            depositDetails: _transaction.depositDetails,
            createdAt: _transaction.createdAt,
            updatedAt: DateTime.now(),
          );
        });

        if (mounted) {
          AppMessenger.show(
            context,
            type: MessageType.success,
            message: 'Transaction status updated to $result',
          );
        }
      } else {
        if (mounted) {
          AppMessenger.show(
            context,
            type: MessageType.error,
            message: 'No status information returned',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppMessenger.show(
          context,
          type: MessageType.error,
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = (_transaction.description.isNotEmpty ? _transaction.description : _transaction.category).toUpperCase();
    final isCredit = _transaction.isCredit;
    final amount = _transaction.amount;

    String type = isCredit ? 'Credit' : 'Debit';
    String status = _transaction.status.toUpperCase();
    Color statusColor = _transaction.isSuccessful ? const Color(0xFF4CAF50) : (_transaction.isFailed ? Colors.red : Colors.orange);

    String _getCurrencySymbol(String code) {
      switch (code.toUpperCase()) {
        case 'NGN': return '₦';
        case 'USD': return '\$';
        case 'EUR': return '€';
        case 'GBP': return '£';
        case 'XAF': return 'FCFA ';
        case 'XOF': return 'CFA ';
        case 'KES': return 'KSh ';
        case 'GHS': return 'GH₵ ';
        case 'UGX': return 'USh ';
        case 'ZAR': return 'R ';
        case 'RWF': return 'FRw ';
        default: return '$code ';
      }
    }
    
    final currencySymbol = _getCurrencySymbol(_transaction.currency);

    final category = _transaction.category.toUpperCase();
    final billType = (_transaction.billDetails?.billType ?? '').toUpperCase();
    final desc = _transaction.description.toUpperCase();

    final bool isGiftCard = category == 'GIFTCARD' || 
                            billType.contains('GIFT') || 
                            desc.contains('GIFT CARD') || 
                            desc.contains('GIFTCARD');

    final bool isBill = category == 'BILL' || 
                         category == 'BILL_PAYMENT' || 
                         isGiftCard || 
                         billType.isNotEmpty || 
                         desc.contains('AIRTIME') || 
                         desc.contains('DATA') || 
                         desc.contains('CABLE') || 
                         desc.contains('ELECTRICITY');

    final String? billRef = _transaction.transactionRef ?? 
                            _transaction.reference ?? 
                            _transaction.billDetails?.reference;

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
                    '${isCredit ? '+' : '-'}$currencySymbol${NumberFormat('#,###.00').format(amount)}',
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
                  _buildDetailRow('Category', _transaction.category, isDark),
                  if (_transaction.transactionRef != null)
                    _buildDetailRow('Transaction REF', _transaction.transactionRef!, isDark, hasCopy: true),
                  _buildDetailRow('Wallet ID', _transaction.walletId, isDark, hasCopy: true),
                  _buildDetailRow('Current Balance', '$currencySymbol${NumberFormat('#,###.00').format(_transaction.currentBalance)}', isDark),
                  _buildDetailRow('Date & Time', DateFormat('dd MMM, yyyy | h:mm a').format(_transaction.createdAt), isDark),
                ],
              ),
            ),
            if (isBill && billRef != null && billRef.isNotEmpty && _transaction.isPending) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This transaction is pending. You can manually request a status check from the provider.',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isBill && billRef != null && billRef.isNotEmpty) ...[
              const SizedBox(height: 24),
              FullWidthButton(
                text: 'Check Status',
                isLoading: _isLoading,
                isEnabled: !_isLoading,
                onPressed: () => _checkStatus(billRef, isGiftCard),
              ),
            ],
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
