import 'package:flutter/material.dart';

class CableTvProviderSelectorModal extends StatelessWidget {
  final String selectedProvider;
  final Function(String) onProviderSelected;
  final List<String>? providers;

  const CableTvProviderSelectorModal({
    super.key,
    this.providers,
    required this.selectedProvider,
    required this.onProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final providers = this.providers ?? ['DStv', 'GOtv', 'Startimes'];

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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Provider',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        
            // Providers list
            ...providers.map((provider) {
              final isSelected = provider == selectedProvider;

              return ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: _buildProviderIcon(provider),
                  ),
                ),
                title: Text(
                  provider,
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

  Widget _buildProviderIcon(String providerName) {
    final name = providerName.toLowerCase();

    // Cable TV
    if (name.contains('dstv')) {
      return Image.asset('assets/images/dstv.png', fit: BoxFit.cover);
    } else if (name.contains('gotv')) {
      return Image.asset('assets/images/gotv.png', fit: BoxFit.cover);
    } else if (name.contains('startimes')) {
      return Image.asset('assets/images/startimes.png', fit: BoxFit.cover);
    }

    // Internet
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
