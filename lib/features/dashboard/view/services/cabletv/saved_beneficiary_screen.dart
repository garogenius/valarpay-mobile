import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/features/models/cable_models.dart';
import 'package:valarpay/features/notifiers/cable_notifier.dart';

class CableTvSavedBeneficiaryScreen extends ConsumerStatefulWidget {
  final ValueChanged<CableBeneficiary>? onSelectBeneficiary;

  const CableTvSavedBeneficiaryScreen({super.key, this.onSelectBeneficiary});

  @override
  ConsumerState<CableTvSavedBeneficiaryScreen> createState() =>
      _CableTvSavedBeneficiaryScreenState();
}

class _CableTvSavedBeneficiaryScreenState
    extends ConsumerState<CableTvSavedBeneficiaryScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset and fetch fresh data
      ref.read(cableBeneficiaryNotifierProvider.notifier).reset();
      Future.delayed(const Duration(milliseconds: 100), () {
        ref
            .read(cableBeneficiaryNotifierProvider.notifier)
            .getCableBeneficiaries();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(cableBeneficiaryNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Beneficiaries',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body:
          state.isInitialLoading
              ? const Center(child: CircularProgressIndicator())
              : state.message != null && !state.isDataAvailable
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: isDark ? Colors.red[400] : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        state.message ?? 'Failed to load beneficiaries',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(cableBeneficiaryNotifierProvider.notifier)
                            .reset();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          ref
                              .read(cableBeneficiaryNotifierProvider.notifier)
                              .getCableBeneficiaries();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : state.data?.isEmpty ?? true
              ? _buildEmptyState(isDark)
              : Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by smart card number',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF2B2725) : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  // Beneficiaries List
                  Expanded(child: _buildBeneficiariesList(isDark)),
                ],
              ),
    );
  }

  Widget _buildBeneficiariesList(bool isDark) {
    final state = ref.watch(cableBeneficiaryNotifierProvider);

    // Filter beneficiaries by search query
    final filtered =
        state.data!
            .where(
              (b) =>
                  b.smartCardNumber.contains(_searchQuery) ||
                  (b.providerName?.toLowerCase() ?? '').contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  (b.customerName?.toLowerCase() ?? '').contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No matching beneficiaries found',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final beneficiary = filtered[index];
        return _buildBeneficiaryTile(context, beneficiary, isDark);
      },
    );
  }

  Widget _buildBeneficiaryTile(
    BuildContext context,
    CableBeneficiary beneficiary,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        // Call the callback with the entire beneficiary object
        widget.onSelectBeneficiary?.call(beneficiary);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: _buildProviderIcon(beneficiary.providerName)),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beneficiary.smartCardNumber,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (beneficiary.providerName != null)
                    Text(
                      beneficiary.providerName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  if (beneficiary.customerName != null)
                    Text(
                      beneficiary.customerName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: appTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tv, size: 60, color: Color(0xFFF76301)),
          ),
          const SizedBox(height: 24),
          Text(
            'No saved beneficiaries yet',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save smart card numbers to make cable TV payments faster',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderIcon(String? providerName) {
    if (providerName == null) {
      return const Icon(Icons.tv, color: Color(0xFFF76301), size: 20);
    }

    final normalizedName = providerName.toLowerCase().trim();
    String assetName = '';

    if (normalizedName.contains('dstv')) {
      assetName = 'dstv.png';
    } else if (normalizedName.contains('gotv')) {
      assetName = 'gotv.png';
    } else if (normalizedName.contains('startimes')) {
      assetName = 'startimes.png';
    }

    if (assetName.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          'assets/images/$assetName',
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.tv, color: Color(0xFFF76301), size: 20),
        ),
      );
    }
    return const Icon(Icons.tv, color: Color(0xFFF76301), size: 20);
  }
}
