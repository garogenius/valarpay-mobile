import 'package:flutter/material.dart';
import 'package:valarpay/features/models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionItemWidget extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionItemWidget({Key? key, required this.transaction, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Transaction icon
            _buildTransactionIcon(isDarkMode),
            const SizedBox(width: 12),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTransactionTitle(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Amount and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        transaction.isCredit
                            ? const Color(0xFF00A651)
                            : const Color(0xFFE53935),
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatusChip(isDarkMode),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionIcon(bool isDarkMode) {
    Color bgColor;
    IconData icon;

    switch (transaction.category.toUpperCase()) {
      case 'DEPOSIT':
        bgColor =
            isDarkMode
                ? const Color(0xFF1B5E20).withOpacity(0.3)
                : const Color(0xFFE8F5E9);
        icon = Icons.arrow_downward;
        break;
      case 'TRANSFER':
        bgColor =
            isDarkMode
                ? const Color(0xFF0D47A1).withOpacity(0.3)
                : const Color(0xFFE3F2FD);
        icon = Icons.arrow_upward;
        break;
      case 'BILL_PAYMENT':
      case 'BILL':
        bgColor =
            isDarkMode
                ? const Color(0xFFE65100).withOpacity(0.3)
                : const Color(0xFFFFF3E0);
        icon = Icons.receipt;
        break;
      case 'WITHDRAWAL':
        bgColor =
            isDarkMode
                ? const Color(0xFFB71C1C).withOpacity(0.3)
                : const Color(0xFFFFEBEE);
        icon = Icons.account_balance;
        break;
      default:
        bgColor = isDarkMode ? Colors.grey.shade800 : const Color(0xFFF5F5F5);
        icon = Icons.sync_alt;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color:
            transaction.isCredit
                ? const Color(0xFF00A651)
                : (isDarkMode ? Colors.white70 : const Color(0xFF1A1A1A)),
        size: 20,
      ),
    );
  }

  Widget _buildStatusChip(bool isDarkMode) {
    Color bgColor;
    Color textColor;
    String statusText;

    if (transaction.isSuccessful) {
      bgColor =
          isDarkMode
              ? const Color(0xFF1B5E20).withOpacity(0.3)
              : const Color(0xFFE8F5E9);
      textColor = const Color(0xFF00A651);
      statusText = 'Successful';
    } else if (transaction.isPending) {
      bgColor =
          isDarkMode
              ? const Color(0xFFE65100).withOpacity(0.3)
              : const Color(0xFFFFF3E0);
      textColor = const Color(0xFFF57C00);
      statusText = 'Pending';
    } else {
      bgColor =
          isDarkMode
              ? const Color(0xFFB71C1C).withOpacity(0.3)
              : const Color(0xFFFFEBEE);
      textColor = const Color(0xFFE53935);
      statusText = 'Failed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  String _getTransactionTitle() {
    switch (transaction.category.toUpperCase()) {
      case 'DEPOSIT':
        return transaction.depositDetails?.senderName ?? 'Deposit';
      case 'TRANSFER':
        return transaction.transferDetails?.beneficiaryName ?? 'Bank Transfer';
      case 'BILL_PAYMENT':
      case 'BILL':
        // Use network if available (e.g. Airtel), otherwise provider (e.g. PalmPay)
        // This gives better context like "Airtel Airtime" instead of "PalmPay Airtime"
        final rawProvider = transaction.billDetails?.network ??
            transaction.billDetails?.provider ??
            '';
        
        // Capitalize first letter
        final provider = rawProvider.isNotEmpty
            ? rawProvider[0].toUpperCase() +
                (rawProvider.length > 1
                    ? rawProvider.substring(1).toLowerCase()
                    : '')
            : '';

        final rawType = (transaction.billDetails?.billType ?? '').trim().toUpperCase();

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
          final desc = transaction.description.toUpperCase();
          if (desc.contains('AIRTIME')) {
            displayType = 'Airtime';
          } else if (desc.contains('DATA') || desc.contains('BUNDLE')) {
            displayType = 'Mobile Data';
          } else if (desc.contains('CABLE') || desc.contains('TV')) {
            displayType = 'Cable TV';
          } else if (desc.contains('ELECTRICITY') || desc.contains('POWER')) {
            displayType = 'Electricity';
          } else {
            displayType = transaction.billDetails?.billType ?? 'Bill Payment';
          }
        }

        return provider.isEmpty ? displayType : '$provider $displayType';
      case 'WITHDRAWAL':
        return 'Withdrawal';
      default:
        return transaction.description.isNotEmpty
            ? transaction.description
            : transaction.category;
    }
  }

  String _formatDate(DateTime date) {
    // Convert to local time if it's UTC
    final localDate = date.toLocal();
    final now = DateTime.now();

    // Compare only the date parts (year, month, day)
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );

    if (transactionDate == today) {
      return 'Today ${DateFormat('hh:mm a').format(localDate)}';
    } else if (transactionDate == yesterday) {
      return 'Yesterday ${DateFormat('hh:mm a').format(localDate)}';
    } else {
      return DateFormat('MMM dd, yyyy hh:mm a').format(localDate);
    }
  }
}
