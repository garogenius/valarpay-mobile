import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/features/models/wallet.dart';
import 'package:valarpay/features/notifiers/wallet_notifier.dart';

class MultiCurrencyReceiveModal extends ConsumerStatefulWidget {
  final WalletModel wallet;

  const MultiCurrencyReceiveModal({Key? key, required this.wallet}) : super(key: key);

  static void show(BuildContext context, WalletModel wallet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiCurrencyReceiveModal(wallet: wallet),
    );
  }

  @override
  ConsumerState<MultiCurrencyReceiveModal> createState() => _MultiCurrencyReceiveModalState();
}

class _MultiCurrencyReceiveModalState extends ConsumerState<MultiCurrencyReceiveModal> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _accountDetails;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final repo = ref.read(walletRepositoryProvider);
      
      String? virtualAccountNumber = widget.wallet.accountNumber;
      
      // If we don't have the account number, fetch the wallet details first
      if (virtualAccountNumber == null || virtualAccountNumber.isEmpty) {
        final walletRes = await repo.getPayazaWallet(widget.wallet.id);
        if (walletRes['data'] != null) {
          // The API payload format for virtual account number might vary, check common keys
          virtualAccountNumber = walletRes['data']['virtualAccountNumber']?.toString() ?? 
                                 walletRes['data']['virtual_account_number']?.toString() ??
                                 walletRes['data']['accountNumber']?.toString() ??
                                 walletRes['data']['account_number']?.toString();
        }
      }

      if (virtualAccountNumber == null || virtualAccountNumber.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No virtual account found for this wallet.';
        });
        return;
      }

      final response = await repo.getPayazaVirtualAccountDetails(virtualAccountNumber);
      setState(() {
        _isLoading = false;
        _accountDetails = response['data'];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppMessenger.show(context, message: '$label copied to clipboard!', type: MessageType.success);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Text(
            'Receive ${widget.wallet.currency}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use these details to receive money directly to your ${widget.wallet.currency} wallet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: Color(0xFFF76301)),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            )
          else if (_accountDetails != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow('Bank Name', _accountDetails!['bank_name']?.toString() ?? 'N/A', isDark),
                  const Divider(height: 24),
                  _buildDetailRow('Account Name', _accountDetails!['account_name']?.toString() ?? 'N/A', isDark),
                  const Divider(height: 24),
                  _buildDetailRow('Account Number', _accountDetails!['account_number']?.toString() ?? 'N/A', isDark, isNumber: true),
                  if (_accountDetails!['routing_number'] != null) ...[
                    const Divider(height: 24),
                    _buildDetailRow('Routing Number', _accountDetails!['routing_number'].toString(), isDark, isNumber: true),
                  ],
                ],
              ),
            ),
            
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF76301),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Done',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {bool isNumber = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: MediaQuery.of(context).size.width - 140,
              child: Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: isNumber ? 18 : 14,
                  fontWeight: isNumber ? FontWeight.bold : FontWeight.w600,
                  letterSpacing: isNumber ? 1.0 : 0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => _copyToClipboard(value, label),
          icon: const Icon(Icons.copy, color: Color(0xFFF76301), size: 20),
          splashRadius: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
