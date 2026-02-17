import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/features/models/vcard_models.dart';
import 'package:valarpay/features/notifiers/vcard_notifier.dart';
import 'package:valarpay/features/dashboard/view/cards/widgets/virtual_card_widget.dart';

class VCardDetailsScreen extends ConsumerStatefulWidget {
  final String cardId;
  const VCardDetailsScreen({super.key, required this.cardId});

  @override
  ConsumerState<VCardDetailsScreen> createState() => _VCardDetailsScreenState();
}

class _VCardDetailsScreenState extends ConsumerState<VCardDetailsScreen> {
  bool _showNumbers = false;

  @override
  Widget build(BuildContext context) {
    final cardState = ref.watch(cardNotifierProvider);
    final card = cardState.cards?.firstWhere((c) => c.id == widget.cardId, orElse: () => throw 'Card not found');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('View Card Details', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            VirtualCardWidget(card: card, showDetails: _showNumbers),
            const SizedBox(height: 48),
            _buildDetailField('Card Number', card!.cardNumber, isObscure: !_showNumbers, isDark: isDark),
            _buildDetailField('Account Number', card.walletId, isObscure: false, isDark: isDark),
            Row(
              children: [
                Expanded(child: _buildDetailField('Expiration Date', '${card.expiryMonth}/${card.expiryYear.substring(card.expiryYear.length - 2)}', isObscure: false, isDark: isDark)),
                const SizedBox(width: 16),
                Expanded(child: _buildDetailField('CVV', card.cvv, isObscure: !_showNumbers, isDark: isDark)),
              ],
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => setState(() => _showNumbers = !_showNumbers),
              child: Text(
                _showNumbers ? 'HIDE DETAILS' : 'SHOW DETAILS', 
                style: TextStyle(color: appTheme.primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value, {required bool isObscure, required bool isDark}) {
    String displayValue = isObscure ? (label == 'CVV' ? '***' : '**** **** **** ${value.substring(value.length - 4)}') : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 13)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(displayValue, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.copy_outlined, color: Theme.of(context).primaryColor, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied to clipboard'), duration: const Duration(seconds: 1)));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
