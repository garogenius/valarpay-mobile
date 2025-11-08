import 'package:flutter/material.dart';
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
  // final ScreenshotController _screenshotController = ScreenshotController();

  // Future<void> _captureAndShare() async {
  //   try {
  //     final image = await _screenshotController.capture();
  //     if (image == null) return;

  //     final directory = await getTemporaryDirectory();
  //     final imagePath = await File('${directory.path}/receipt.png').create();
  //     await imagePath.writeAsBytes(image);

  //     await Share.shareXFiles([
  //       XFile(imagePath.path),
  //     ], text: 'My ValarPay Transaction Receipt');
  //   } catch (e) {
  //     debugPrint("Error sharing receipt: $e");
  //   }
  // }

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
          // child: Screenshot(
          //   controller: _screenshotController,
            child: ShareableTransactionReceipt(
              date: widget.date,
              transactionDetailList: widget.transactionDetailList,
            ),
          // ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null,
        // onPressed: _captureAndShare,
        label: const Text("Share Receipt"),
        icon: const Icon(Icons.share),
      ),
    );
  }
}
