import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/features/models/vcard_models.dart';
import 'package:valarpay/features/notifiers/vcard_notifier.dart';

class VCardManagementScreen extends ConsumerWidget {
  final String cardId;
  const VCardManagementScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardState = ref.watch(cardNotifierProvider);
    final card = cardState.cards?.firstWhere((c) => c.id == cardId, orElse: () => throw 'Card not found');

    if (card == null) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appTheme = Theme.of(context);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manage Your Card', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildManageCard(context, Icons.security_outlined, 'Change Pin', 'Update your card\'s security code', isDark, onTap: () {}),
            _buildManageCard(context, Icons.refresh_outlined, 'Reset Pin', 'Set a new PIN to replace the old one', isDark, onTap: () {}),
            _buildManageCard(context, Icons.block_flipped, 'Block Card', 'Permanently disable your card', isDark, onTap: () => _handleBlock(context, ref, card), iconColor: Colors.orange.shade800),
            _buildManageCard(
              context, 
              Icons.lock_outline, 
              card.isFrozen ? 'Unfreeze Card' : 'Freeze Card', 
              'Temporarily lock your card', 
              isDark,
              onTap: () => _handleFreeze(context, ref, card),
            ),
            _buildManageCard(context, Icons.speed_outlined, 'Set Limit', 'Control your daily card spending', isDark, onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildManageCard(BuildContext context, IconData icon, String title, String subtitle, bool isDark, {required VoidCallback onTap, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor ?? Theme.of(context).primaryColor, size: 24),
            const Spacer(),
            Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: isDark ? Colors.white24 : Colors.grey, fontSize: 9), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  void _handleFreeze(BuildContext context, WidgetRef ref, VirtualCardModel card) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(card.isFrozen ? 'Unfreeze Card' : 'Freeze Card', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text('Are you sure you want to ${card.isFrozen ? 'unfreeze' : 'freeze'} this card?', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(card.isFrozen ? 'Unfreeze' : 'Freeze', style: TextStyle(color: Theme.of(context).primaryColor))),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(cardNotifierProvider.notifier);
      final success = card.isFrozen 
          ? await notifier.unfreezeCard(card.id) 
          : await notifier.freezeCard(card.id);
          
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Card ${card.isFrozen ? 'unfrozen' : 'frozen'} successfully')));
      }
    }
  }

  void _handleBlock(BuildContext context, WidgetRef ref, VirtualCardModel card) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        title: const Text('Terminate Card', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to permanently terminate this card? This action cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Terminate', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(cardNotifierProvider.notifier).terminateCard(card.id);
      if (success && context.mounted) {
        Navigator.pop(context); // Close management screen
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card terminated successfully')));
      }
    }
  }
}
