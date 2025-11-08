import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
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
  final GlobalKey _receiptKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareReceipt() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // Capture the receipt widget as an image
      final RenderRepaintBoundary boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save the image to a temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'receipt_${DateTime.now().millisecondsSinceEpoch}.png';
      final File imageFile = File('${tempDir.path}/$fileName');
      await imageFile.writeAsBytes(pngBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        subject: 'ValarPay Transaction Receipt',
        text: 'Check out my ValarPay transaction receipt!',
      );
    } catch (e) {
      debugPrint('Error sharing receipt image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share receipt: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
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
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: RepaintBoundary(
              key: _receiptKey,
              child: ShareableTransactionReceipt(
                date: widget.date,
                transactionDetailList: widget.transactionDetailList,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSharing ? null : _shareReceipt,
        label: Text(_isSharing ? "Sharing..." : "Share Receipt"),
        icon:
            _isSharing
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.share),
      ),
    );
  }
}
