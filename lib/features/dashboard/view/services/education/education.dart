import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/education_notifier.dart';
import 'package:valarpay/features/models/education_models.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'institution_payment_screen.dart';
import 'saved_beneficiary_screen.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(schoolBillersProvider.notifier).fetchBillers(useRemita: true);
      ref.read(vendingProvidersProvider.notifier).fetchProviders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final schoolState = ref.watch(schoolBillersProvider);
    final examState = ref.watch(vendingProvidersProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Education Payment',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: isBvnVerified ? [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EducationSavedBeneficiaryScreen()),
            ),
            child: const Text('Saved Beneficiary', style: TextStyle(color: Color(0xFFF76301))),
          ),
        ] : null,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF76301),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF76301),
          tabs: const [
            Tab(text: 'School Fees'),
            Tab(text: 'Exam Pins'),
          ],
        ),
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC verification to make education payments',
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search institution or exam',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBillerList(schoolState, isDark, isSchool: true),
                      _buildBillerList(examState, isDark, isSchool: false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBillerList(DataState<EducationBiller> state, bool isDark, {required bool isSchool}) {
    if (state.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.message != null && (state.data == null || state.data!.isEmpty)) {
      return Center(child: Text(state.message!));
    }
    
    final billers = state.data?.where((b) => 
      b.billerName.toLowerCase().contains(_searchQuery) || 
      (b.billerShortName?.toLowerCase().contains(_searchQuery) ?? false)
    ).toList() ?? [];

    if (billers.isEmpty) {
      return const Center(child: Text('No institutions found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: billers.length,
      itemBuilder: (context, index) {
        final biller = billers[index];
        return _buildBillerTile(biller, isDark);
      },
    );
  }

  Widget _buildBillerTile(EducationBiller biller, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF76301).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: biller.billerLogoUrl != null 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(biller.billerLogoUrl!, fit: BoxFit.cover),
                )
              : const Icon(Icons.school, color: Color(0xFFF76301)),
        ),
        title: Text(
          biller.billerName,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: biller.billerShortName != null ? Text(biller.billerShortName!) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InstitutionPaymentScreen(biller: biller),
            ),
          );
        },
      ),
    );
  }
}
