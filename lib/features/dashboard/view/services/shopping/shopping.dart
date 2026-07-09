import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'saved_beneficiary_screen.dart';
import 'provider_payment_screen.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false) || (user?.wallets.isNotEmpty ?? false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shoppingProviders = [
      'Jumia.com.ng',
      'Amazon.com',
      'Aliexpress.com',
      'Shein.com',
      'Ebay.com',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shopping',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: isBvnVerified
            ? [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ShoppingSavedBeneficiaryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Saved Beneficiary',
                    style: TextStyle(
                      color: Color(0xFFF76301),
                      fontSize: 14,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC verification to shop online',
            )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Shopping Providers List
            Expanded(
              child: ListView.builder(
                itemCount: shoppingProviders.length,
                itemBuilder: (context, index) {
                  final provider = shoppingProviders[index];
                  return _buildProviderTile(provider, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderTile(String provider, bool isDark) {
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
            color: const Color(0xFFF76301).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.shopping_bag,
            color: Color(0xFFF76301),
            size: 20,
          ),
        ),
        title: Text(
          provider,
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
              builder: (context) => ShoppingProviderPaymentScreen(
                providerName: provider,
              ),
            ),
          );
        },
      ),
    );
  }
}
