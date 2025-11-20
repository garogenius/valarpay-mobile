import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/features/dashboard/view/transfer/transfer_to_bank/beneficiary_transfer_amount_screen.dart';
import 'package:valarpay/features/notifiers/beneficiary_notifier.dart';
import 'package:valarpay/features/notifiers/transaction_notifier.dart';

class TransferToBankRecentAndSavedBeneficiaries extends ConsumerStatefulWidget {
  final ValueChanged<String>? onSelectAccount;

  const TransferToBankRecentAndSavedBeneficiaries({
    super.key,
    this.onSelectAccount,
  });

  @override
  ConsumerState<TransferToBankRecentAndSavedBeneficiaries> createState() =>
      _TransferToBankRecentAndSavedBeneficiariesState();
}

class _TransferToBankRecentAndSavedBeneficiariesState
    extends ConsumerState<TransferToBankRecentAndSavedBeneficiaries> {
  bool isRecentTab = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(beneficiaryNotifierProvider.notifier)
          .getBeneficiaries(category: 'TRANSFER', transferType: 'inter');
      ref
          .read(transactionNotifierProvider.notifier)
          .fetchTransactions(type: 'DEBIT', category: 'TRANSFER', limit: 50);
    });
  }

  Widget _buildRecentBeneficiaries() {
    final state = ref.watch(beneficiaryNotifierProvider);

    if (state.isInitialLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.data!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'No recent transfers',
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    if (state.data!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text("No recent transfers found"),
        ),
      );
    }
    final mergedList = state.data!;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mergedList.length,
      itemBuilder: (context, index) {
        final beneficiary = mergedList[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BeneficiaryTransferAmountScreen(
                      beneficiaryDetails: beneficiary,
                    ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: Text(
                    beneficiary.accountName.toString().toUpperCase().substring(
                      0,
                      2,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beneficiary.accountName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        beneficiary.accountNumber,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedBeneficiaries() {
    final state = ref.watch(beneficiaryNotifierProvider);

    if (state.isInitialLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.data!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text('No saved beneficiaries'),
        ),
      );
    }

    // ✅ Filter by search
    final beneficiaries =
        state.data!
            .where(
              (b) =>
                  b.accountName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  b.accountNumber.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  b.bankName.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    if (beneficiaries.isEmpty) {
      return const Center(child: Text("No matching saved beneficiaries found"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: beneficiaries.length,
      itemBuilder: (context, index) {
        final beneficiary = beneficiaries[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BeneficiaryTransferAmountScreen(
                      beneficiaryDetails: beneficiary,
                    ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: Text(
                    beneficiary.accountName.toString().toUpperCase().substring(
                      0,
                      2,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beneficiary.accountName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${beneficiary.accountNumber}   ${beneficiary.bankName}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => isRecentTab = true),
              child: Column(
                children: [
                  Text(
                    "Recent",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isRecentTab ? appTheme.primaryColor : null,
                    ),
                  ),
                  if (isRecentTab)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 3,
                      width: 40,
                      color: appTheme.primaryColor,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => setState(() => isRecentTab = false),
              child: Column(
                children: [
                  Text(
                    "Saved Beneficiary",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: !isRecentTab ? appTheme.primaryColor : null,
                    ),
                  ),
                  if (!isRecentTab)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 3,
                      width: 40,
                      color: appTheme.primaryColor,
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ✅ Search Field (filters both)
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            hintText: "Search by name, account, or bank",
            filled: true,
            fillColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim();
            });
          },
        ),
        const SizedBox(height: 16),
        isRecentTab ? _buildRecentBeneficiaries() : _buildSavedBeneficiaries(),
      ],
    );
  }
}
