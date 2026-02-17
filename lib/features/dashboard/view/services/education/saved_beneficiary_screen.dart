import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/beneficiary_models.dart';
import 'package:valarpay/features/notifiers/beneficiary_notifier.dart';

class EducationSavedBeneficiaryScreen extends ConsumerStatefulWidget {
  const EducationSavedBeneficiaryScreen({super.key});

  @override
  ConsumerState<EducationSavedBeneficiaryScreen> createState() => _EducationSavedBeneficiaryScreenState();
}

class _EducationSavedBeneficiaryScreenState extends ConsumerState<EducationSavedBeneficiaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(beneficiaryNotifierProvider.notifier).getBeneficiaries(
        category: 'BILL',
        billType: 'SCHOOLFEE',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final beneficiaryState = ref.watch(beneficiaryNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
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
      body: beneficiaryState.isInitialLoading 
          ? const Center(child: CircularProgressIndicator())
          : beneficiaryState.data == null || beneficiaryState.data!.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: beneficiaryState.data!.length,
                  itemBuilder: (context, index) {
                    final beneficiary = beneficiaryState.data![index];
                    return _buildBeneficiaryTile(context, beneficiary, isDark);
                  },
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
              color: const Color(0xFFF76301).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, size: 60, color: Color(0xFFF76301)),
          ),
          const SizedBox(height: 24),
          Text(
            'No beneficiaries added yet',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add beneficiaries to make education payments faster',
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

  Widget _buildBeneficiaryTile(BuildContext context, Beneficiary beneficiary, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF76301).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: Color(0xFFF76301), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beneficiary.accountNumber,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  beneficiary.accountName,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }
}
