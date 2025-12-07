import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../../widgets/me_widgets/delete_confirmation_dialog.dart';

// Linked accounts model
class LinkedAccount {
  final String name;
  final String number;
  final String iconPath;
  final bool isAccount;

  LinkedAccount({
    required this.name,
    required this.number,
    required this.iconPath,
    this.isAccount = false,
  });
}

final linkedAccountsProvider = StateProvider<List<LinkedAccount>>((ref) => []);

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedAccounts = ref.watch(linkedAccountsProvider);
    final user = ref.watch(userProvider);
    final hasWallet = user?.wallets.isNotEmpty ?? false;
    final wallet = hasWallet ? user!.wallets.first : null;

    // Get user data
    final accountName = user?.fullname ?? 'N/A';
    final accountNumber =
        (wallet?.accountNumber != null && wallet!.accountNumber.isNotEmpty)
            ? wallet.accountNumber
            : 'Not Available';
    final dailyLimit =
        user?.dailyCummulativeTransactionLimit != null
            ? currencyFormatter(
              user!.dailyCummulativeTransactionLimit.toString(),
            )
            : '₦0';
    final maxBalance =
        user?.cummulativeBalanceLimit != null
            ? currencyFormatter(user!.cummulativeBalanceLimit.toString())
            : '₦0';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.43,
            letterSpacing: 0.035,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier Card
              Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tier 1',
                      style: TextStyle(
                        color: Color(0xFFF76301),
                        fontFamily: 'SF Pro',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                        letterSpacing: 0.06,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      ref,
                      'Account Name',
                      accountName,
                      showCopy: true,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      ref,
                      'Account Number',
                      accountNumber,
                      showCopy: true,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      ref,
                      'Daily Transaction Limit',
                      dailyLimit,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(context, ref, 'Maximum Balance', maxBalance),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF76301),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Linked Card/Account Section
              const Text(
                'Linked Card/Account',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Show empty state or linked accounts
              linkedAccounts.isEmpty
                  ? _buildEmptyLinkedAccounts(context)
                  : Container(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // All linked accounts in same card
                        ...linkedAccounts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final account = entry.value;
                          final isLast = index == linkedAccounts.length - 1;

                          return Column(
                            children: [
                              _buildLinkedAccountRow(
                                context,
                                ref,
                                account,
                                index,
                              ),
                              if (!isLast)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Container(
                                    height: 2,
                                    color: Theme.of(
                                      context,
                                    ).cardColor.withOpacity(0.2),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLinkedAccounts(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 48,
            color: isDark ? Colors.grey.shade600 : const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            'No Linked Accounts',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Link your bank accounts or cards for easier transactions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : const Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value, {
    bool showCopy = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFF9CA3AF) : Colors.black,
            fontFamily: 'SF Pro',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.43,
            letterSpacing: 0.035,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    letterSpacing: 0.035,
                  ),
                ),
              ),
              if (showCopy) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    AppMessenger.show(
                      context,
                      type: MessageType.success,
                      message: 'Copied to clipboard',
                    );
                  },
                  child: const Icon(
                    Icons.copy,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedAccountRow(
    BuildContext context,
    WidgetRef ref,
    LinkedAccount account,
    int index,
  ) {
    return Row(
      children: [
        // Bank Icon
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            account.iconPath,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        // Bank Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                  letterSpacing: 0.06,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    account.number,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontFamily: 'SF Pro',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      letterSpacing: 0.06,
                    ),
                  ),
                  if (account.isAccount) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF216EB2).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Account',
                        style: TextStyle(
                          color: Color(0xFF216EB2),
                          fontFamily: 'SF Pro',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        // Delete Button
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return DeleteConfirmationDialog(
                  onConfirm: () {
                    final accounts = ref.read(linkedAccountsProvider);
                    ref.read(linkedAccountsProvider.notifier).state = [
                      ...accounts.sublist(0, index),
                      ...accounts.sublist(index + 1),
                    ];
                  },
                );
              },
            );
          },
          child: SvgPicture.asset(
            'assets/icons/Delete.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Color(0xFF9CA3AF),
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
