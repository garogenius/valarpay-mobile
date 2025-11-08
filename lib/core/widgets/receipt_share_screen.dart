import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';

class ReceiptShareScreen extends StatefulWidget {
  final List<ShareableTransactionReceiptDetail> transactionDetailList;
  final String date;
  const ReceiptShareScreen({
    required this.transactionDetailList,
    required this.date,
    super.key,
  });

  @override
  State<ReceiptShareScreen> createState() => _ReceiptShareScreenState();
}

class _ReceiptShareScreenState extends State<ReceiptShareScreen> {
  Future<void> _shareReceipt() async {
    try {
      // Build receipt text
      final buffer = StringBuffer();
      buffer.writeln('📱 ValarPay Transaction Receipt');
      buffer.writeln('════════════════════════════════');
      buffer.writeln('Date: ${widget.date}');
      buffer.writeln('');

      for (final detail in widget.transactionDetailList) {
        buffer.writeln('${detail.label}: ${detail.value}');
      }

      buffer.writeln('');
      buffer.writeln('════════════════════════════════');
      buffer.writeln('Shared from ValarPay App');

      // Use share_plus to share to WhatsApp, Email, etc.
      await Share.share(
        buffer.toString(),
        subject: 'ValarPay Transaction Receipt',
      );
    } catch (e) {
      debugPrint('Error sharing receipt: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share receipt: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transaction Receipt",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: ShareableTransactionReceipt(
            date: widget.date,
            transactionDetailList: widget.transactionDetailList,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareReceipt,
        label: const Text("Share Receipt"),
        icon: const Icon(Icons.share),
      ),
    );
  }
}
