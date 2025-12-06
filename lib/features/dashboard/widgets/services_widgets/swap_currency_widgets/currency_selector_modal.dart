import 'package:flutter/material.dart';

class CurrencyModel {
  final String code;
  final String name;
  final String flagAsset;
  final String symbol; // ✅ new field

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.flagAsset,
    required this.symbol, // ✅ include in constructor
  });
}

const List<CurrencyModel> supportedCurrencies = [
  CurrencyModel(
    code: 'NGN',
    name: 'Nigerian Naira',
    flagAsset: 'assets/images/nigerian.png',
    symbol: '₦',
  ),
  CurrencyModel(
    code: 'USD',
    name: 'US Dollar',
    flagAsset: 'assets/images/USA.png',
    symbol: '\$',
  ),
  CurrencyModel(
    code: 'EUR',
    name: 'Euro',
    flagAsset: 'assets/images/POUNDS.png',
    symbol: '€',
  ),
  CurrencyModel(
    code: 'GBP',
    name: 'British Pound',
    flagAsset: 'assets/images/POUNDS.png',
    symbol: '£',
  ),
  CurrencyModel(
    code: 'CAD',
    name: 'Canadian Dollar',
    flagAsset: 'assets/images/POUNDS.png',
    symbol: 'C\$',
  ),
  CurrencyModel(
    code: 'AUD',
    name: 'Australian Dollar',
    flagAsset: 'assets/images/uk.png',
    symbol: 'A\$',
  ),
];

class CurrencySelectorModal extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<CurrencyModel> onCurrencySelected;

  const CurrencySelectorModal({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<CurrencyModel> currencies = supportedCurrencies;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2725) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                  'Select Currency',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Currency list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected = currency.code == selectedCurrency;

                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: AssetImage(currency.flagAsset),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFFF76301)
                                    : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child:
                            isSelected
                                ? const Center(
                                  child: Icon(
                                    Icons.circle,
                                    color: Color(0xFFF76301),
                                    size: 12,
                                  ),
                                )
                                : null,
                      ),
                    ],
                  ),
                  title: Text(
                    '${currency.code} - ${currency.name}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    onCurrencySelected(currency);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
