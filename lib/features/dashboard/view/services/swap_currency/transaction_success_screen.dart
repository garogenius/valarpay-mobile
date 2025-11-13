import 'package:flutter/material.dart';

class SwapCurrencyTransactionSuccessScreen extends StatelessWidget {
  final Map<String, String> transactionData;

  const SwapCurrencyTransactionSuccessScreen({
    super.key,
    required this.transactionData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),

              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),

              const SizedBox(height: 24),

              // Success Text
              Text(
                'Swap Successful',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // Amount
              Text(
                '${_getCurrencySymbol(transactionData['toAmount'] ?? '0')}${transactionData['toAmount'] ?? '0'}',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Transaction Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Transaction ID',
                      'TXN${DateTime.now().millisecondsSinceEpoch}',
                      isDark,
                    ),
                    _buildDetailRow(
                      'From Currency',
                      transactionData['fromCurrency'] ?? 'NGN',
                      isDark,
                    ),
                    _buildDetailRow(
                      'To Currency',
                      transactionData['toCurrency'] ?? 'USD',
                      isDark,
                    ),
                    _buildDetailRow(
                      'From Amount',
                      '${_getCurrencySymbol(transactionData['fromCurrency'] ?? 'NGN')}${transactionData['fromAmount'] ?? '0'}',
                      isDark,
                    ),
                    _buildDetailRow(
                      'To Amount',
                      '${_getCurrencySymbol(transactionData['toCurrency'] ?? 'USD')}${transactionData['toAmount'] ?? '0'}',
                      isDark,
                    ),
                    _buildDetailRow(
                      'Exchange Rate',
                      '1 ${transactionData['toCurrency']} = ${_getCurrencySymbol(transactionData['fromCurrency'] ?? 'NGN')}${transactionData['exchangeRate'] ?? '1650'}',
                      isDark,
                    ),
                    _buildDetailRow(
                      'Date',
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      isDark,
                    ),
                  ],
                ),
              ),

              const Spacer(),
              SizedBox(height: 15),
              // Share Receipt Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle share receipt
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF76301),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    'Share Receipt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '';
    }
  }
}
