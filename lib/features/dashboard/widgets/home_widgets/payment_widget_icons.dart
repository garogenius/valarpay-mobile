import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/providers/wallet_providers.dart';
import 'package:valarpay/features/dashboard/widgets/home_widgets/multi_currency_receive_modal.dart';

class PaymentWidget extends ConsumerWidget {
  const PaymentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWallet = ref.watch(activeWalletProvider);
    final currency = activeWallet?.currency ?? 'NGN';
    final isNgn = currency == 'NGN';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(
            context,
            svgAssetPath: isNgn ? 'assets/images/payment_wid/valarpay.svg' : 'assets/images/payment_wid/valarpay.svg',
            label: isNgn ? 'To ValarPay' : 'Payout',
            onTap: () {
              if (isNgn) {
                context.push("/transfer-to-valarpay");
              } else {
                context.push("/payout/$currency");
              }
            },
            iconData: isNgn ? null : Icons.send,
          ),
          _buildActionItem(
            context,
            svgAssetPath: isNgn ? 'assets/images/payment_wid/Bank.svg' : 'assets/images/payment_wid/Bank.svg',
            label: isNgn ? 'To Bank' : 'Receive',
            onTap: () {
              if (isNgn) {
                context.push("/transfer-to-bank");
              } else if (activeWallet != null) {
                MultiCurrencyReceiveModal.show(context, activeWallet);
              }
            },
            iconData: isNgn ? null : Icons.call_received,
          ),
          _buildActionItem(
            context,
            svgAssetPath: isNgn ? 'assets/images/payment_wid/withdraw.svg' : 'assets/images/payment_wid/withdraw.svg',
            label: isNgn ? 'Withdraw' : 'Swap',
            onTap: () {
              if (isNgn) {
                context.push("/withdraw");
              } else {
                context.push("/swap-currency");
              }
            },
            iconData: isNgn ? null : Icons.currency_exchange,
          ),
          _buildActionItem(
            context,
            svgAssetPath: 'assets/images/payment_wid/Account.svg',
            label: 'Account',
            onTap: () {
               context.push("/account");
            },
            iconData: null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String svgAssetPath,
    required String label,
    required VoidCallback onTap,
    IconData? iconData,
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
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF76301), // Primary orange
                shape: BoxShape.circle,
              ),
              child: Center(
                child: iconData != null
                  ? Icon(iconData, color: Colors.white, size: 20)
                  : SvgPicture.asset(
                      svgAssetPath,
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 6),
            // Label
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
