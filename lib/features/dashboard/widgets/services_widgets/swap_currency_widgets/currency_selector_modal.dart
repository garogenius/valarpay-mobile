import 'package:flutter/material.dart';

class CurrencyModel {
  final String code;
  final String name;
  final String flagAsset;
  final String symbol; // ✅ new field
  final String? emoji; // ✅ optional emoji flag

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.flagAsset,
    required this.symbol, // ✅ include in constructor
    this.emoji,
  });
}

const List<CurrencyModel> supportedCurrencies = [
  CurrencyModel(
    code: 'NGN',
    name: 'Nigerian Naira',
    flagAsset: 'assets/images/nigerian.png',
    symbol: '₦',
    emoji: '🇳🇬',
  ),
  CurrencyModel(
    code: 'USD',
    name: 'US Dollar',
    flagAsset: 'assets/images/USA.png',
    symbol: '\$',
    emoji: '🇺🇸',
  ),
  CurrencyModel(
    code: 'EUR',
    name: 'Euro',
    flagAsset: 'assets/images/euflag.png',
    symbol: '€',
    emoji: '🇪🇺',
  ),
  CurrencyModel(
    code: 'GBP',
    name: 'British Pound',
    flagAsset: 'assets/images/pounds2.png',
    symbol: '£',
    emoji: '🇬🇧',
  ),
  CurrencyModel(
    code: 'XAF',
    name: 'Cameroon Franc',
    flagAsset: 'assets/images/flag.png',
    symbol: 'FCFA',
    emoji: '🇨🇲',
  ),
  CurrencyModel(
    code: 'TZS',
    name: 'Tanzanian Shilling',
    flagAsset: 'assets/images/flag.png',
    symbol: 'TSh',
    emoji: '🇹🇿',
  ),
  CurrencyModel(
    code: 'KES',
    name: 'Kenyan Shilling',
    flagAsset: 'assets/images/flag.png',
    symbol: 'KSh',
    emoji: '🇰🇪',
  ),
  CurrencyModel(
    code: 'GHS',
    name: 'Ghanaian Cedi',
    flagAsset: 'assets/images/ghflag.png',
    symbol: 'GH₵',
    emoji: '🇬🇭',
  ),
  CurrencyModel(
    code: 'UGX',
    name: 'Ugandan Shilling',
    flagAsset: 'assets/images/flag.png',
    symbol: 'USh',
    emoji: '🇺🇬',
  ),
  CurrencyModel(
    code: 'ZAR',
    name: 'South African Rand',
    flagAsset: 'assets/images/flag.png',
    symbol: 'R',
    emoji: '🇿🇦',
  ),
  CurrencyModel(
    code: 'XOF',
    name: 'West African CFA Franc',
    flagAsset: 'assets/images/flag.png',
    symbol: 'CFA',
    emoji: '🇧🇯',
  ),
];

class CurrencySelectorModal extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<CurrencyModel> onCurrencySelected;
  final List<String>? allowedCurrencies; // Added filter list

  const CurrencySelectorModal({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
    this.allowedCurrencies,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Filter statically supported list against permitted user currencies if provided
    final List<CurrencyModel> currencies = allowedCurrencies == null
        ? supportedCurrencies
        : supportedCurrencies
            .where((c) => allowedCurrencies!.contains(c.code.toUpperCase()))
            .toList();

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
                      if (currency.emoji != null)
                        Text(
                          currency.emoji!,
                          style: const TextStyle(fontSize: 24),
                        )
                      else
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
