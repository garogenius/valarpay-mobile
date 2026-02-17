import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/models/vcard_models.dart';
import 'package:valarpay/features/notifiers/vcard_notifier.dart';
import 'package:valarpay/features/dashboard/view/cards/widgets/virtual_card_widget.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';

class VirtualCardTab extends ConsumerWidget {
  const VirtualCardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vcardState = ref.watch(cardNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appTheme = Theme.of(context);

    if (vcardState.isInitialLoading) {
      return Column(
        children: [
          const SizedBox(height: 100),
          Center(child: CircularProgressIndicator(color: appTheme.primaryColor)),
        ],
      );
    }

    if (!vcardState.isDataAvailable) {
      return _buildEmptyState(context);
    }

    final cards = vcardState.cards!;

    return Column(
      children: [
        const SizedBox(height: 24),
        VirtualCardWidget(card: cards.first),
        const SizedBox(height: 32),
        
        // Quick Actions Row
        Row(
          children: [
            Expanded(
              child: _buildQuickAction(
                context,
                icon: Icons.add_circle_outline,
                label: 'Fund Card',
                onTap: () => context.push('/vcard/fund/${cards.first.id}'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickAction(
                context,
                icon: Icons.file_download_outlined,
                label: 'Withdraw',
                onTap: () => context.push('/vcard/withdraw/${cards.first.id}'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        _buildActionItem(
          context,
          icon: Icons.visibility_outlined,
          title: 'View Card Details',
          onTap: () => context.push('/vcard/details/${cards.first.id}'),
        ),
        _buildActionItem(
          context,
          icon: Icons.settings_outlined,
          title: 'Manage Your Card',
          onTap: () => context.push('/vcard/manage/${cards.first.id}'),
        ),
        _buildActionItem(
          context,
          icon: Icons.receipt_long_outlined,
          title: 'Check Card Statement',
          onTap: () => context.push('/vcard/transactions/${cards.first.id}'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
          ),
          child: Icon(Icons.credit_card, color: isDark ? Colors.white24 : Colors.grey.shade400, size: 40),
        ),
        const SizedBox(height: 24),
        Text(
          'No cards found',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'You currently do not have any virtual card linked to this account. Click on create card now to apply for a new card',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade600, fontSize: 12, height: 1.5),
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FullWidthButton(
            text: 'Create Card Now',
            onPressed: () => context.push('/vcard/create'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Theme.of(context).cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: const Text('View and manage details', style: TextStyle(color: Colors.grey, fontSize: 10)),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}
