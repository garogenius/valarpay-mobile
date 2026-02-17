import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/features/notifiers/betting_notifier.dart';
import 'package:valarpay/features/models/beneficiary_models.dart';

class BettingSavedBeneficiaryScreen extends ConsumerStatefulWidget {
  const BettingSavedBeneficiaryScreen({super.key});

  @override
  ConsumerState<BettingSavedBeneficiaryScreen> createState() => _BettingSavedBeneficiaryScreenState();
}

class _BettingSavedBeneficiaryScreenState extends ConsumerState<BettingSavedBeneficiaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Beneficiary> _filteredBeneficiaries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bettingBeneficiaryNotifierProvider.notifier).fetchBeneficiaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final beneficiaryState = ref.watch(bettingBeneficiaryNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Beneficiary',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Searching',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  // Filter logic here
                },
              ),
            ),
          ),
          
          Expanded(
            child: beneficiaryState.isInitialLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF76301)))
                : beneficiaryState.data == null || beneficiaryState.data!.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: beneficiaryState.data!.length,
                        itemBuilder: (context, index) {
                          final beneficiary = beneficiaryState.data![index];
                          return _buildBeneficiaryTile(
                            context,
                            beneficiary,
                            isDark,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_soccer,
              size: 64,
              color: Colors.white12,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No beneficiaries added yet',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiaryTile(
    BuildContext context,
    Beneficiary beneficiary,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, beneficiary),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF76301).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: Color(0xFFF76301),
                size: 20,
              ),
            ),
  
            const SizedBox(width: 16),
  
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beneficiary.accountNumber ?? '',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    beneficiary.favouriteName ?? beneficiary.accountName ?? '',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
  
            // More options
            IconButton(
              onPressed: () {
                // _showOptionsBottomSheet(context, beneficiary, isDark);
              },
              icon: Icon(
                Icons.more_vert,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
