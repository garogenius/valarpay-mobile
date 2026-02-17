import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/widgets/reuseable_appbar_text_button.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'saved_beneficiary_screen.dart';
import 'package:valarpay/features/notifiers/internet_notifier.dart';
import 'package:valarpay/features/models/internet_models.dart';
import 'provider_payment_screen.dart';

class InternetScreen extends ConsumerStatefulWidget {
  const InternetScreen({super.key});

  @override
  ConsumerState<InternetScreen> createState() => _InternetScreenState();
}

class _InternetScreenState extends ConsumerState<InternetScreen> {
  @override
  void initState() {
    super.initState();
    // load internet plans
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(internetPlansNotifierProvider.notifier)
          .getPlans(currency: 'NGN');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plansState = ref.watch(internetPlansNotifierProvider);
    final rawPlans = plansState.data ?? [];
    final uniqueProvidersMap = <String, InternetPlanInfo>{};
    for (var plan in rawPlans) {
      if (!uniqueProvidersMap.containsKey(plan.billerCode)) {
        uniqueProvidersMap[plan.billerCode] = plan;
      }
    }
    final internetProviders = uniqueProvidersMap.values.toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Internet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: isBvnVerified
            ? [
                ReuseableAppbarTextButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const InternetSavedBeneficiaryScreen(),
                      ),
                    );
                  },
                  text: '',
                )
              ]
            : null,
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC verification to pay internet bills',
            )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: internetProviders.isEmpty && !plansState.isInitialLoading
                  ? Center(
                      child: Text(
                        'No internet providers available',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: internetProviders.length,
                      itemBuilder: (context, index) {
                        final provider = internetProviders[index];
                        final cleanName = _getCleanProviderName(provider.planName);
                        return _buildProviderTile(provider, cleanName, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCleanProviderName(String planName) {
    final lower = planName.toLowerCase();
    if (lower.contains('smile')) return 'Smile';
    if (lower.contains('spectranet')) return 'Spectranet';
    if (lower.contains('ipnx')) return 'ipNX';
    if (lower.contains('swift')) return 'Swift';
    if (lower.contains('mtn')) return 'MTN Hynet';
    if (lower.contains('airtel')) return 'Airtel';
    if (lower.contains('glo')) return 'Glo';
    if (lower.contains('9mobile') || lower.contains('etisalat')) return '9mobile';
    if (lower.contains('tizeti')) return 'Tizeti';
    
    // If it contains "Unlimited", and we grouped by biller, 
    // maybe it's a generic plan name. Try to take the first two words if no matches.
    final parts = planName.split(' ');
    if (parts.length > 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return planName;
  }

  Widget _buildProviderTile(InternetPlanInfo provider, String cleanName, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _getProviderIcon(cleanName),
          ),
        ),
        title: Text(
          cleanName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDark ? Colors.white70 : Colors.grey[600],
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  InternetProviderPaymentScreen(
                    providerName: cleanName,
                    billerCode: provider.billerCode,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _getProviderIcon(String providerName) {
    final name = providerName.toLowerCase();

    if (name.contains('smile')) {
      return const Icon(Icons.wifi, color: Color(0xFFE91E63));
    } else if (name.contains('spectranet')) {
      return const Icon(Icons.wifi_tethering, color: Color(0xFF2196F3));
    } else if (name.contains('ipnx')) {
      return const Icon(Icons.router, color: Color(0xFF4CAF50));
    } else if (name.contains('swift')) {
      return const Icon(Icons.speed, color: Color(0xFFDD2C00));
    } else if (name.contains('mtn')) {
      return Image.asset(
        'assets/images/mtn.png',
        errorBuilder: (_, __, ___) => const Icon(Icons.wifi),
      );
    } else if (name.contains('airtel')) {
      return Image.asset(
        'assets/images/airtel.png',
        errorBuilder: (_, __, ___) => const Icon(Icons.wifi),
      );
    } else if (name.contains('glo')) {
      return Image.asset(
        'assets/images/glo.png',
        errorBuilder: (_, __, ___) => const Icon(Icons.wifi),
      );
    } else if (name.contains('9mobile') || name.contains('etisalat')) {
      return Image.asset(
        'assets/images/9mobile.png',
        errorBuilder: (_, __, ___) => const Icon(Icons.wifi),
      );
    } else if (name.contains('tizeti')) {
      return const Icon(Icons.wifi, color: Color(0xFF00ACC1));
    }

    return const Icon(Icons.wifi, color: Colors.grey);
  }
}
