import 'package:flutter/material.dart';
import 'package:valarpay/features/models/cable_models.dart';

class CableTvProviderSelectorModal extends StatelessWidget {
  final String selectedProvider;
  final Function(CablePlanInfo) onProviderSelected;
  final List<CablePlanInfo>? providers;

  const CableTvProviderSelectorModal({
    super.key,
    required this.selectedProvider,
    required this.onProviderSelected,
    this.providers,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cableTvProviders = providers ?? [];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2725) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Provider',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Provider list
            if (cableTvProviders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No providers available'),
              )
            else
              ...cableTvProviders.map((provider) {
                final isSelected = selectedProvider == provider.planName;
                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: _buildProviderIcon(provider),
                    ),
                  ),
                  title: Text(
                    provider.planName,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    onProviderSelected(provider);
                    Navigator.pop(context);
                  },
                );
              }).toList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderIcon(CablePlanInfo provider) {
    if (provider.billerIcon != null && provider.billerIcon!.isNotEmpty) {
      return Image.network(
        provider.billerIcon!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildLocalAssetIcon(provider.planName),
      );
    }
    return _buildLocalAssetIcon(provider.planName);
  }

  Widget _buildLocalAssetIcon(String planName) {
    final normalizedName = planName.toLowerCase().trim();
    String assetName = '';

    if (normalizedName.contains('dstv')) {
      assetName = 'dstv.png';
    } else if (normalizedName.contains('gotv')) {
      assetName = 'gotv.png';
    } else if (normalizedName.contains('startimes')) {
      assetName = 'startimes.png';
    }

    if (assetName.isNotEmpty) {
      return Image.asset(
        'assets/images/$assetName',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.tv),
      );
    }

    return const Icon(Icons.tv);
  }
}
