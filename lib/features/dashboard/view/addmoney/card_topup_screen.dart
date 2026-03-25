import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/features/models/linked_card_models.dart';
import 'package:valarpay/features/notifiers/linked_card_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class CardTopupScreen extends ConsumerStatefulWidget {
  const CardTopupScreen({super.key});

  @override
  ConsumerState<CardTopupScreen> createState() => _CardTopupScreenState();
}

class _CardTopupScreenState extends ConsumerState<CardTopupScreen> {
  final TextEditingController _amountController = TextEditingController();
  LinkedCard? _selectedCard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(linkedCardsProvider.notifier).fetchLinkedCards();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processTopup() async {
    if (_selectedCard == null) {
      AppMessenger.show(context, message: 'Please select a card', type: MessageType.error);
      return;
    }

    final amountStr = _amountController.text.replaceAll(',', '');
    if (amountStr.isEmpty) {
      AppMessenger.show(context, message: 'Please enter amount', type: MessageType.error);
      return;
    }

    final amount = double.parse(amountStr);
    if (amount <= 0) {
      AppMessenger.show(context, message: 'Invalid amount', type: MessageType.error);
      return;
    }

    // Amount minor (assuming 100 for NGN kobo)
    final amountMinor = (amount * 100).toInt();

    final pin = await TransactionPinModal.show(context);
    if (pin != null && pin.length == 4) {
      _performCharge(_selectedCard!.id, amountMinor);
    }
  }

  Future<void> _performCharge(String cardId, int amountMinor) async {
    final request = ChargeCardRequest(
      amountMinor: amountMinor,
      currency: 'NGN',
    );

    final response = await ref.read(cardChargeProvider.notifier).charge(cardId, request);

    if (response != null) {
      if (response.status.toLowerCase() == 'successful') {
        _showSuccessDialog(amountMinor);
      } else {
        AppMessenger.show(context, message: 'Charge status: ${response.status}', type: MessageType.warning);
      }
    } else {
      final state = ref.read(cardChargeProvider);
      AppMessenger.show(context, message: state.message ?? 'Failed to charge card', type: MessageType.error);
    }
  }

  void _showSuccessDialog(int amountMinor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Top-up Successful'),
        content: Text('You have successfully funded your wallet with ${currencyFormatter((amountMinor / 100).toString())} from your card.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from topup screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardsState = ref.watch(linkedCardsProvider);
    final chargeState = ref.watch(cardChargeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up with Card'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a linked card', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            if (cardsState.isInitialLoading)
              const Center(child: CircularProgressIndicator())
            else if (cardsState.data == null || cardsState.data!.isEmpty)
              _buildNoCardsWidget()
            else
              _buildCardsList(cardsState.data!),
            
            SizedBox(height: 32.h),
            Text('Amount to fund', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            ReuseableAmountTextfield(
              amountController: _amountController,
              prefixText: '₦',
              hintText: '0.00',
            ),
            
            SizedBox(height: 48.h),
            FullWidthButton(
              text: 'Confirm Top Up',
              isLoading: chargeState.isInitialLoading,
              onPressed: _processTopup,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsList(List<LinkedCard> cards) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: cards.map((card) {
        final isSelected = _selectedCard?.id == card.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedCard = card),
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : (isDark ? Colors.white10 : Colors.grey.shade200),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${card.cardBrand.toUpperCase()} •••• ${card.cardLast4}', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                      Text('Expires ${card.cardExpMonth}/${card.cardExpYear}', 
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20.sp),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoCardsWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(height: 8.h),
          const Text('You have no linked cards yet.', textAlign: TextAlign.center),
          TextButton(
            onPressed: () {
              // Navigate to cards screen linked tab
              // Since I can't easily deep link to a specific tab here without complex logic,
              // I'll just suggest they go to the Cards tab.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please go to the Cards tab to link a card.'))
              );
            },
            child: const Text('Link a card now'),
          ),
        ],
      ),
    );
  }
}
