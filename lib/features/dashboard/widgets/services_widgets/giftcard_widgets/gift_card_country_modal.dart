import 'package:flutter/material.dart';
import 'package:valarpay/features/models/giftcard.dart';
import '/core/themes/color_utils.dart';

class GiftCardCountryModal extends StatelessWidget {
  final String selectedCountry;
  final List<GiftCardProduct> brandProducts;
  final Function(GiftCardProduct) onProductSelected;

  const GiftCardCountryModal({
    super.key,
    required this.selectedCountry,
    required this.brandProducts,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<String, GiftCardProduct> uniqueCountries = {};
    for (final p in brandProducts) {
      final countryName = p.country.name;
      if (countryName.isNotEmpty && !uniqueCountries.containsKey(countryName)) {
        uniqueCountries[countryName] = p;
      }
    }
    final countriesList = uniqueCountries.values.toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
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
                  'Select Country',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Country List
          Expanded(
            child: countriesList.isEmpty
                ? Center(
                    child: Text(
                      'No countries available',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: countriesList.length,
                    itemBuilder: (context, index) {
                      final prod = countriesList[index];
                      final countryName = prod.country.name;
                      final flagUrl = prod.country.flagUrl;
                      final isSelected = countryName == selectedCountry;

                      return GestureDetector(
                        onTap: () => onProductSelected(prod),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2B2725)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.primaryColor, width: 2)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: flagUrl.startsWith('http')
                                    ? Image.network(
                                        flagUrl,
                                        width: 32,
                                        height: 24,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.flag, size: 18),
                                      )
                                    : Center(
                                        child: Text(
                                          flagUrl.isNotEmpty ? flagUrl : '🏳️',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  countryName,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
