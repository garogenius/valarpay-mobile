import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/utils/ngn_account_checker.dart';

class InvestmentPromoWidget extends ConsumerWidget {
  const InvestmentPromoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionItem(
              context,
              label: 'Investment',
              iconData: Icons.trending_up,
              onTap: () => NgnAccountChecker.checkAndExecute(context, ref, () => context.push('/invest')),
            ),
            const SizedBox(width: 24),
            _buildActionItem(
              context,
              label: 'Fixed Deposit',
              iconData: Icons.lock_clock,
              onTap: () => NgnAccountChecker.checkAndExecute(context, ref, () => context.push('/fixed-deposit')),
            ),
            const SizedBox(width: 24),
            _buildActionItem(
              context,
              label: 'Easylife Saving',
              iconData: Icons.savings,
              onTap: () => NgnAccountChecker.checkAndExecute(context, ref, () => context.push('/easylife')),
            ),
            const SizedBox(width: 24),
            _buildActionItem(
              context,
              label: 'Target Saving',
              iconData: Icons.track_changes,
              onTap: () => NgnAccountChecker.checkAndExecute(context, ref, () => context.push('/target-saving')),
            ),
            const SizedBox(width: 24),
            _buildActionItem(
              context,
              label: 'Cards',
              iconData: Icons.credit_card,
              onTap: () => context.push('/cards'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String label,
    required IconData iconData,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF76301),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(iconData, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
