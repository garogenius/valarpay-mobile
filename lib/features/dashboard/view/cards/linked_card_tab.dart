import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/linked_card_models.dart';
import 'package:valarpay/features/notifiers/linked_card_notifier.dart';

class LinkedCardTab extends ConsumerStatefulWidget {
  const LinkedCardTab({super.key});

  @override
  ConsumerState<LinkedCardTab> createState() => _LinkedCardTabState();
}

class _LinkedCardTabState extends ConsumerState<LinkedCardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(linkedCardsProvider.notifier).fetchLinkedCards();
    });
  }

  Future<void> _initiateLink() async {
    final request = CardLinkInitiateRequest(
      amountMinor: 10000, // Fixed amount for linking as per typical provider requirements
      currency: 'NGN',
    );

    final response = await ref.read(cardLinkProvider.notifier).initiate(request);
    
    if (response != null && response.redirectUrl.isNotEmpty) {
      final url = Uri.parse(response.redirectUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        
        // After returning, show a dialog to check status
        if (mounted) {
          _showStatusCheckDialog();
        }
      } else {
        AppMessenger.show(context, message: 'Could not launch payment URL', type: MessageType.error);
      }
    } else {
      final state = ref.read(cardLinkProvider);
      AppMessenger.show(context, message: state.message ?? 'Failed to initiate card link', type: MessageType.error);
    }
  }

  void _showStatusCheckDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Linking Card'),
        content: const Text('Please complete the authentication in your browser. Once done, click the button below to refresh your cards.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(linkedCardsProvider.notifier).fetchLinkedCards();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Future<void> _disableCard(LinkedCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Card'),
        content: Text('Are you sure you want to disable your ${card.cardBrand.toUpperCase()} card ending in ${card.cardLast4}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disable', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(cardDisableProvider.notifier).disable(card.id);
      if (success) {
        AppMessenger.show(context, message: 'Card disabled successfully', type: MessageType.success);
        ref.read(linkedCardsProvider.notifier).fetchLinkedCards();
      } else {
        final state = ref.read(cardDisableProvider);
        AppMessenger.show(context, message: state.message ?? 'Failed to disable card', type: MessageType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(linkedCardsProvider);
    final linkState = ref.watch(cardLinkProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isInitialLoading) {
      return const Column(
        children: [
          SizedBox(height: 100),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final cards = state.data ?? [];

    if (cards.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return _buildCardItem(card);
          },
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FullWidthButton(
            text: 'Link Another Card',
            isLoading: linkState.isInitialLoading,
            onPressed: _initiateLink,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCardItem(LinkedCard card) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F1F) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getCardIcon(card.cardBrand),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          '${card.cardBrand.toUpperCase()} •••• ${card.cardLast4}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          'Expires ${card.cardExpMonth}/${card.cardExpYear}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          onPressed: () => _disableCard(card),
        ),
      ),
    );
  }

  IconData _getCardIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkState = ref.watch(cardLinkProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add_card, color: isDark ? Colors.white24 : Colors.grey.shade400, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'No linked cards',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Link your ATM card to enjoy seamless funding and transactions on ValarPay.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FullWidthButton(
            text: 'Link Card Now',
            isLoading: linkState.isInitialLoading,
            onPressed: _initiateLink,
          ),
        ),
      ],
    );
  }
}
