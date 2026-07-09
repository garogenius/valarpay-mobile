import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/receipt_share_screen.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class TransactionDetail {
  final String label;
  final String value;
  final bool showCopyIcon;

  TransactionDetail({
    required this.label,
    required this.value,
    this.showCopyIcon = false,
  });
}

class TransactionReceiptWidget extends ConsumerStatefulWidget {
  final String amount;
  final List<TransactionDetail> topDetails;
  final List<TransactionDetail>? bottomDetails;
  final String headerText;
  final List<ShareableTransactionReceiptDetail>? shareableDetails;
  final String? receiptDate;
  final String symbol;

  const TransactionReceiptWidget({
    Key? key,
    required this.amount,
    required this.topDetails,
    this.bottomDetails,
    required this.headerText,
    this.shareableDetails,
    this.receiptDate,
    this.symbol = '₦',
  }) : super(key: key);

  @override
  ConsumerState<TransactionReceiptWidget> createState() =>
      _TransactionReceiptWidgetState();
}

class _TransactionReceiptWidgetState
    extends ConsumerState<TransactionReceiptWidget> {
  bool _isLoading = false;

  void _navigateToReceiptShare() {
    if (widget.shareableDetails != null && widget.receiptDate != null) {
      debugPrint(
        '🟢 Navigating to ReceiptShareScreen from TransactionReceiptWidget',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ReceiptShareScreen(
                transactionDetailList: widget.shareableDetails!,
                date: widget.receiptDate!,
              ),
        ),
      );
    } else {
      debugPrint('🔴 Receipt data is missing!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt data is not available')),
      );
    }
  }

  Future<void> _handleDoneButton() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final freshedUser =
          await ref.read(userNotifierProvider.notifier).refreshUserProfile();

      if (freshedUser != null) {
        ref.read(userProvider.notifier).setUser(freshedUser);
      }
    } catch (e) {
      debugPrint('Error refreshing user profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Success Icon
                    SvgPicture.asset(
                      'assets/icons/tick-circle.svg',
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(height: 16),
                    // Transaction Successful Text
                    Text(
                      '${widget.headerText} Successful',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontFamily: 'SF Pro',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Amount
                    Text(
                      currencyFormatter(widget.amount, symbol: widget.symbol),
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Top Details Card
                    _buildDetailsCard(context, widget.topDetails),
                    const SizedBox(height: 16),
                    // Bottom Details Card
                    if (widget.bottomDetails != null)
                      _buildDetailsCard(context, widget.bottomDetails ?? []),
                    const SizedBox(height: 32),
                    // Share and View Receipt Buttons Row
                    _buildActionButtons(),
                    const SizedBox(height: 30),
                    // Done Button
                    _buildDoneButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // View Receipt Button
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFBFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: TextButton(
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        debugPrint('🔵 View Receipt button pressed');
                        _navigateToReceiptShare();
                      },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long, size: 16, color: Color(0xFF111827)),
                  SizedBox(width: 8),
                  Text(
                    'View Receipt',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontFamily: 'SF Pro',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 25),
        SizedBox(height: 15),
        // Share Button
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF76301),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextButton(
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        debugPrint('🟠 Share Receipt button pressed');
                        _navigateToReceiptShare();
                      },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.share, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SF Pro',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: FullWidthButton(
        text: 'Done',
        onPressed: _isLoading ? null : _handleDoneButton,
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    List<TransactionDetail> details,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children:
            details.asMap().entries.map((entry) {
              final index = entry.key;
              final detail = entry.value;
              final isLast = index == details.length - 1;

              return Column(
                children: [
                  _buildDetailRow(context, detail),
                  if (!isLast) const SizedBox(height: 20),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, TransactionDetail detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Expanded(
          child: Text(
            detail.label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontFamily: 'SF Pro',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.33,
              letterSpacing: 0.06,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Value with optional copy icon
        Expanded(
          child: Text(
            detail.value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: detail.label == 'Transaction ID' ? 12 : 14,
              fontWeight: FontWeight.w400,
              height: 1.33,
              letterSpacing: 0.06,
            ),
          ),
        ),
      ],
    );
  }
}
