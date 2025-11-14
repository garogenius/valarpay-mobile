import 'package:flutter/material.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/features/models/network_provider.dart';

class NetworkProviderSelector extends StatelessWidget {
  final String selectedNetwork;
  final Function(String) onNetworkSelected;
  final List<NetworkProvider>? providers;

  const NetworkProviderSelector({
    super.key,
    required this.selectedNetwork,
    required this.onNetworkSelected,
    this.providers,
  });

  String _assetForProvider(String network) {
    final n = network.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (n.contains('mtn')) return 'assets/images/mtn.png';
    if (n.contains('airtel')) return 'assets/images/airtel.png';
    if (n.contains('9mobile') || n.contains('etisalat') || n.contains('nine'))
      return 'assets/images/9mobile.png';
    if (n.contains('glo')) return 'assets/images/glo.png';
    // fallback
    return 'assets/images/default.png';
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    // If providers list passed and not empty, use it; otherwise fallback to defaults
    final list =
        (providers != null && providers!.isNotEmpty)
            ? providers!
            : [
              NetworkProvider(
                id: 'airtel',
                planName: '',
                network: 'Airtel',
                countryISOCode: '',
                operatorId: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              NetworkProvider(
                id: 'mtn',
                planName: '',
                network: 'MTN',
                countryISOCode: '',
                operatorId: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              NetworkProvider(
                id: '9mobile',
                planName: '',
                network: '9mobile',
                countryISOCode: '',
                operatorId: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              NetworkProvider(
                id: 'glo',
                planName: '',
                network: 'Glo',
                countryISOCode: '',
                operatorId: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ];

    for (var i = 0; i < list.length; i++) {
      final p = list[i];
      items.add(
        GestureDetector(
          onTap: () => onNetworkSelected(p.network),
          child: _NetworkProviderItem(
            name: p.network,
            image: Image.asset(_assetForProvider(p.network), fit: BoxFit.cover),
            isSelected: selectedNetwork == p.network,
            onTap: () => onNetworkSelected(p.network),
          ),
        ),
      );

      if (i != list.length - 1) {
        items.add(const SizedBox(width: 8));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items,
      ),
    );
  }
}

class _NetworkProviderItem extends StatelessWidget {
  final String name;
  final Widget image;
  final bool isSelected;
  final VoidCallback onTap;

  const _NetworkProviderItem({
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? appTheme.primaryColor.withOpacity(0.3)
                  : Theme.of(context).cardColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? appTheme.primaryColor.withOpacity(0.5)
                    : Colors.grey.shade700,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Center(child: image),
          ),
        ),
      ),
    );
  }
}
