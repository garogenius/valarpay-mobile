import 'package:flutter/material.dart';
import '../../../widgets/services_widgets/swap_currency_widgets/payment_method_modal.dart';

class SwapCurrencyTransactionDetailsScreen extends StatelessWidget {
  final Map<String, String> transactionData;

  const SwapCurrencyTransactionDetailsScreen({
    super.key,
    required this.transactionData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transaction Details',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Transaction details container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('From Currency',
                      transactionData['fromCurrency'] ?? 'NGN', isDark),
                  _buildDetailRow('To Currency',
                      transactionData['toCurrency'] ?? 'USD', isDark),
                  _buildDetailRow(
                      'From Amount',
                      '${_getCurrencySymbol(transactionData['fromCurrency'] ?? 'NGN')}${transactionData['fromAmount'] ?? '0'}',
                      isDark),
                  _buildDetailRow(
                      'To Amount',
                      '${_getCurrencySymbol(transactionData['toCurrency'] ?? 'USD')}${transactionData['toAmount'] ?? '0'}',
                      isDark),
                  _buildDetailRow(
                      'Exchange Rate',
                      '1 ${transactionData['toCurrency']} = ${_getCurrencySymbol(transactionData['fromCurrency'] ?? 'NGN')}${transactionData['exchangeRate'] ?? '1650'}',
                      isDark),
                  const Divider(),
                  _buildDetailRow(
                      'Service Fee',
                      '${_getCurrencySymbol(transactionData['fromCurrency'] ?? 'NGN')}50',
                      isDark),
                  _buildDetailRow(
                      'Total Amount',
                      '${_getCurrencySymbol(transactionData['fromCurrency'] ?? 'NGN')}${_calculateTotal()}',
                      isDark,
                      isTotal: true),
                ],
              ),
            ),

            const Spacer(),

            // Pay Via section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pay Via',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment methods
                  _buildPaymentMethod(
                    'ValarPay Account',
                    Icons.account_balance,
                    Colors.orange,
                    isDark,
                  ),
                  // const SizedBox(height: 12),
                  // _buildPaymentMethod(
                  //   'First Bank of Nigeria',
                  //   Icons.account_balance,
                  //   Colors.blue,
                  //   isDark,
                  // ),
                  // const SizedBox(height: 12),
                  // _buildPaymentMethod(
                  //   'Wema Bank',
                  //   Icons.account_balance,
                  //   Colors.purple,
                  //   isDark,
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showPaymentMethodModal(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF76301),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm Swap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark,
      {bool isTotal = false}) {
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
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(
    String name,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        const Icon(
          Icons.star,
          color: Color(0xFFF76301),
          size: 20,
        ),
      ],
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
      case 'XAF':
        return 'FCFA';
      case 'TZS':
        return 'TSh';
      case 'KES':
        return 'KSh';
      case 'GHS':
        return 'GH₵';
      case 'UGX':
        return 'USh';
      case 'ZAR':
        return 'R';
      case 'XOF':
        return 'CFA';
      default:
        return '';
    }
  }

  String _calculateTotal() {
    double fromAmount =
        double.tryParse(transactionData['fromAmount'] ?? '0') ?? 0;
    double serviceFee = 50;
    return (fromAmount + serviceFee).toStringAsFixed(2);
  }

  void _showPaymentMethodModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SwapCurrencyPaymentMethodModal(
        transactionData: transactionData,
        onPaymentMethodSelected: (method) {
          // Handle payment method selection
        },
      ),
    );
  }
}
