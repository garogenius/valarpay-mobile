import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/transfer_models.dart';
import 'package:valarpay/features/notifiers/transfer_notifier.dart';

class SelectBankScreen extends ConsumerStatefulWidget {
  const SelectBankScreen({super.key});

  @override
  ConsumerState<SelectBankScreen> createState() => _SelectBankScreenState();
}

class _SelectBankScreenState extends ConsumerState<SelectBankScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Bank> filteredBanks = [];
  List<Bank> allBanks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfBanksAvailable();
    });
    searchController.addListener(_filterBanks);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  _checkIfBanksAvailable() {
    final allBanksState = ref.read(banksNotifierProvider);
    if (!allBanksState.isDataAvailable) {
      ref.read(banksNotifierProvider.notifier).fetchBanks(currency: 'NGN');
    } else {
      setState(() {
        allBanks = allBanksState.singleData!.banks;
        filteredBanks = allBanks;
      });
    }
  }

  void _filterBanks() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredBanks =
          allBanks
              .where((bank) => bank.name.toLowerCase().contains(query))
              .toList();
    });
  }

  void _retry() {
    ref.read(banksNotifierProvider.notifier).fetchBanks(currency: 'NGN');
  }

  @override
  Widget build(BuildContext context) {
    final banksState = ref.watch(banksNotifierProvider);

    ref.listen(banksNotifierProvider, (previous, next) {
      if (next.isDataAvailable && next.data != null) {
        setState(() {
          allBanks = next.singleData!.banks;
          filteredBanks = allBanks;
        });
      }
    });

    final sortedBanks = List.from(filteredBanks)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Select Bank",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search for bank",
                filled: true,
                fillColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Banks List
            Expanded(
              child:
                  banksState.isInitialLoading
                      ? const Center(child: CircularProgressIndicator())
                      : banksState.message != null &&
                          !banksState.isDataAvailable
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              banksState.message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FullWidthButton(text: 'Retry', onPressed: _retry),
                          ],
                        ),
                      )
                      : filteredBanks.isEmpty
                      ? const Center(
                        child: Text(
                          'No banks found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: sortedBanks.length,
                        itemBuilder: (context, index) {
                          final bank = sortedBanks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8, top: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: appTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                child: Text(
                                  bank.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: appTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                bank.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context, bank);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // tileColor: Theme.of(context)
                              //     .cardColor
                              //     .withValues(alpha: 0.5),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
