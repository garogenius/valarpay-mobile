import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/models/vcard_models.dart';
import 'package:valarpay/features/notifiers/vcard_notifier.dart';
import 'package:valarpay/features/dashboard/view/cards/widgets/virtual_card_widget.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';

class VirtualCardTab extends ConsumerStatefulWidget {
  const VirtualCardTab({super.key});

  @override
  ConsumerState<VirtualCardTab> createState() => _VirtualCardTabState();
}

class _VirtualCardTabState extends ConsumerState<VirtualCardTab> {
  bool _showDetails = false;
  double _spendingLimit = 50000.0;

  @override
  Widget build(BuildContext context) {
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

    final card = vcardState.cards!.first;
    final transactionsAsyncValue = ref.watch(cardTransactionsProvider(card.id));

    // Colors aligned with reference designs
    final Color primaryColor = const Color(0xFFF76301);
    final Color tertiaryColor = const Color(0xFFE9C349);
    final Color textColor = isDark ? const Color(0xFFD4E4F6) : const Color(0xFF1F2937);
    final Color subtitleColor = isDark ? const Color(0xFFE2BFB1) : const Color(0xFF4B5563);
    final Color cardBackground = isDark ? const Color(0xFF11212E).withOpacity(0.4) : Colors.white;
    final Color unselectedBorder = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          
          // 1. Solar Velocity Virtual Card
          VirtualCardWidget(
            card: card,
            showDetails: _showDetails,
            designTheme: 'Solar Velocity',
          ),
          
          const SizedBox(height: 24),

          // 2. Bento Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                label: 'BALANCE',
                value: '\$${card.balance}',
                isDark: isDark,
                cardBg: cardBackground,
                borderCol: unselectedBorder,
                labelColor: subtitleColor,
                valueColor: primaryColor,
              ),
              _buildStatCard(
                label: 'SPENT TODAY',
                value: '\$248.12',
                isDark: isDark,
                cardBg: cardBackground,
                borderCol: unselectedBorder,
                labelColor: subtitleColor,
                valueColor: textColor,
              ),
              _buildStatCard(
                label: 'LIMIT',
                value: '\$${_spendingLimit.toStringAsFixed(0)}',
                isDark: isDark,
                cardBg: cardBackground,
                borderCol: unselectedBorder,
                labelColor: subtitleColor,
                valueColor: textColor,
              ),
              _buildStatCard(
                label: 'STATUS',
                value: card.isFrozen ? 'Frozen' : 'Active',
                isDark: isDark,
                cardBg: cardBackground,
                borderCol: unselectedBorder,
                labelColor: subtitleColor,
                valueColor: card.isFrozen ? primaryColor : tertiaryColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Card Controls Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: unselectedBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Controls',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _buildControlCard(
                      icon: card.isFrozen ? Icons.lock_open : Icons.lock,
                      title: card.isFrozen ? 'Unfreeze Card' : 'Freeze Card',
                      subtitle: card.isFrozen ? 'Instantly enable' : 'Instantly disable',
                      isDark: isDark,
                      iconColor: primaryColor,
                      iconBgColor: primaryColor.withOpacity(0.2),
                      textColor: textColor,
                      subColor: subtitleColor,
                      onTap: () => _handleFreeze(context, ref, card),
                    ),
                    _buildControlCard(
                      icon: _showDetails ? Icons.visibility_off : Icons.visibility,
                      title: _showDetails ? 'Hide Details' : 'Show Details',
                      subtitle: 'Reveal info',
                      isDark: isDark,
                      iconColor: const Color(0xFFB7C6EF),
                      iconBgColor: const Color(0xFFB7C6EF).withOpacity(0.2),
                      textColor: textColor,
                      subColor: subtitleColor,
                      onTap: () => setState(() => _showDetails = !_showDetails),
                    ),
                    _buildControlCard(
                      icon: Icons.settings,
                      title: 'Spending Limits',
                      subtitle: 'Adjust caps',
                      isDark: isDark,
                      iconColor: tertiaryColor,
                      iconBgColor: tertiaryColor.withOpacity(0.2),
                      textColor: textColor,
                      subColor: subtitleColor,
                      onTap: () => _showLimitsDialog(context),
                    ),
                    _buildControlCard(
                      icon: Icons.add_card,
                      title: 'Fund Card',
                      subtitle: 'Add balance',
                      isDark: isDark,
                      iconColor: const Color(0xFFB7C6EF),
                      iconBgColor: const Color(0xFFB7C6EF).withOpacity(0.2),
                      textColor: textColor,
                      subColor: subtitleColor,
                      onTap: () => context.push('/vcard/fund/${card.id}'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Recent Transactions Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/vcard/transactions/${card.id}'),
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          transactionsAsyncValue.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return _buildMockTransactions(isDark, cardBackground, unselectedBorder, textColor, subtitleColor);
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.take(3).length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isNegative = tx.amount < 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: unselectedBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.payment, color: primaryColor, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tx.timestamp.toString().substring(0, 16),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isNegative ? "" : "+"}\$${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isNegative ? Colors.redAccent : Colors.greenAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tx.status,
                              style: TextStyle(
                                fontSize: 11,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator(color: primaryColor)),
            error: (_, __) => _buildMockTransactions(isDark, cardBackground, unselectedBorder, textColor, subtitleColor),
          ),
          const SizedBox(height: 40),
        ],
      ),
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

  Widget _buildStatCard({
    required String label,
    required String value,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: labelColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color iconColor,
    required Color iconBgColor,
    required Color textColor,
    required Color subColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2B39).withOpacity(0.6) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: subColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockTransactions(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color textColor,
    Color subColor,
  ) {
    return Column(
      children: [
        _buildTransactionRow(
          title: 'Cloudflare Inc.',
          time: 'Today, 2:45 PM',
          amount: '-\$20.00',
          category: 'Subscription',
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          textColor: textColor,
          subColor: subColor,
          initials: 'CF',
          iconColor: const Color(0xFFF76301),
        ),
        _buildTransactionRow(
          title: 'Luxury Retail Store',
          time: 'Yesterday, 11:20 AM',
          amount: '-\$1,240.50',
          category: 'Shopping',
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          textColor: textColor,
          subColor: subColor,
          initials: 'LR',
          iconColor: const Color(0xFFB7C6EF),
        ),
      ],
    );
  }

  Widget _buildTransactionRow({
    required String title,
    required String time,
    required String amount,
    required String category,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color textColor,
    required Color subColor,
    required String initials,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category,
                style: TextStyle(
                  fontSize: 11,
                  color: subColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleFreeze(BuildContext context, WidgetRef ref, VirtualCardModel card) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(
          card.isFrozen ? 'Unfreeze Card' : 'Freeze Card',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to ${card.isFrozen ? 'unfreeze' : 'freeze'} this card?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              card.isFrozen ? 'Unfreeze' : 'Freeze',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(cardNotifierProvider.notifier);
      final success = card.isFrozen 
          ? await notifier.unfreezeCard(card.id) 
          : await notifier.freezeCard(card.id);
          
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Card ${card.isFrozen ? 'unfrozen' : 'frozen'} successfully')),
        );
      }
    }
  }

  void _showLimitsDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: _spendingLimit.toStringAsFixed(0));
    
    final double? newLimit = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(
          'Set Spending Limit',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the maximum amount (USD) allowed for daily transactions.',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                hintText: '50000',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.white30 : Colors.black26),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              Navigator.pop(ctx, val);
            },
            child: Text(
              'Apply',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );

    if (newLimit != null) {
      setState(() {
        _spendingLimit = newLimit;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Spending limit set to \$${newLimit.toStringAsFixed(0)}')),
        );
      }
    }
  }
}
