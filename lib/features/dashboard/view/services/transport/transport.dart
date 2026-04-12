import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/coralpay_notifier.dart';
import 'package:valarpay/features/models/coralpay_models.dart';
import 'package:go_router/go_router.dart';

class TransportScreen extends ConsumerStatefulWidget {
  const TransportScreen({super.key});

  @override
  ConsumerState<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends ConsumerState<TransportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(coralPayBillersProvider.notifier).fetchBillers('TRANSPORT_AND_TOLL_PAYMENT');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final billersState = ref.watch(coralPayBillersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Transport',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC verification to use transport services',
            )
          : Column(
              children: [
                if (billersState.isInitialLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (billersState.message != null)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          billersState.message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: billersState.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final biller = billersState.data![index];
                        return _buildProviderTile(biller, isDark);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildProviderTile(CoralPayBiller biller, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: biller.logoUrl != null && biller.logoUrl!.isNotEmpty
                ? Image.network(biller.logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.directions_bus_outlined))
                : const Icon(Icons.directions_bus_outlined),
          ),
        ),
        title: Text(
          biller.name,
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
          // Navigate to CoralPayBillingScreen for packages and verification
          context.push('/coralpay-billing/TRANSPORT_AND_TOLL_PAYMENT/Transport', extra: biller);
        },
      ),
    );
  }
}
