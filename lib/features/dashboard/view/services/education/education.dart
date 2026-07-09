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
class _EducationScreenState extends ConsumerState<EducationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(schoolBillersProvider.notifier).fetchBillers(useRemita: true);
      ref.read(vendingProvidersProvider.notifier).fetchProviders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false) || (user?.wallets.isNotEmpty ?? false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final vendingState = ref.watch(vendingProvidersProvider);

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
          'Education Services',
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
                      hintText: 'Search exam pins',
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
                  child: vendingState.isInitialLoading && (vendingState.data == null || vendingState.data!.isEmpty)
                      ? const Center(child: CircularProgressIndicator())
                      : vendingState.message != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  vendingState.message!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            )
                          : _buildExamPinsList(vendingState.data ?? [], isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildExamPinsList(List<EducationBiller> apiBillers, bool isDark) {
    // Combine hardcoded defaults with API data if needed, or just use API data
    // The user specifically mentioned WAEC and JAMB icon logos.
    
    final filteredBillers = apiBillers.where((b) => 
      b.billerName.toLowerCase().contains(_searchQuery)
    ).toList();

    if (filteredBillers.isEmpty && !ref.watch(vendingProvidersProvider).isInitialLoading) {
       return const Center(child: Text('No exam pins found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredBillers.length,
      itemBuilder: (context, index) {
        return _buildBillerTile(filteredBillers[index], isDark);
      },
    );
  }


  Widget _buildBillerTile(EducationBiller biller, bool isDark) {
    String? logoUrl = biller.billerLogoUrl;
    
    // Add known logos for WAEC and JAMB if they are missing or if we want to ensure they look good
    if (biller.billerName.toLowerCase().contains('waec')) {
      logoUrl = 'https://vgg.ng/wp-content/uploads/2018/11/waec.png';
    } else if (biller.billerName.toLowerCase().contains('jamb')) {
      logoUrl = 'https://vgg.ng/wp-content/uploads/2018/11/jamb.png';
    }

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
          child: logoUrl != null 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    logoUrl, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, color: Color(0xFFF76301)),
                  ),
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
