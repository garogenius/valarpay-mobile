import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/models/signup_request.dart';

class CurrencySelectionScreen extends ConsumerStatefulWidget {
  final SignUpRequest request;

  const CurrencySelectionScreen({
    super.key,
    required this.request,
  });

  @override
  ConsumerState<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends ConsumerState<CurrencySelectionScreen> {
  String selectedCurrency = 'NGN';

  final List<_CountryItem> countries = [
    _CountryItem(name: 'Nigeria', currency: 'NGN', flag: '🇳🇬'),
    _CountryItem(name: 'US Dollar', currency: 'USD', flag: '🇺🇸'),
    _CountryItem(name: 'Eurozone', currency: 'EUR', flag: '🇪🇺'),
    _CountryItem(name: 'United Kingdom', currency: 'GBP', flag: '🇬🇧'),
    _CountryItem(name: 'Uganda', currency: 'UGX', flag: '🇺🇬', isComingSoon: true),
    _CountryItem(name: 'Cameroon', currency: 'XAF', flag: '🇨🇲', isComingSoon: true),
    _CountryItem(name: 'Rwanda', currency: 'RWF', flag: '🇷🇼', isComingSoon: true),
    _CountryItem(name: 'Kenya', currency: 'KES', flag: '🇰🇪', isComingSoon: true),
    _CountryItem(name: 'Ghana', currency: 'GHS', flag: '🇬🇭', isComingSoon: true),
    _CountryItem(name: 'Senegal', currency: 'XOF', flag: '🇸🇳', isComingSoon: true),
    _CountryItem(name: 'Tanzania', currency: 'TZS', flag: '🇹🇿', isComingSoon: true),
    _CountryItem(name: 'Zambia', currency: 'ZMW', flag: '🇿🇲', isComingSoon: true),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = const Color(0xFFF76301);
    final Color backgroundColor = isDark ? const Color(0xFF041521) : const Color(0xFFF9FAFB);
    final Color cardBg = isDark ? const Color(0xFF11212E).withOpacity(0.6) : Colors.white;
    final Color unselectedBorder = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200;
    
    final Color textColor = isDark ? const Color(0xFFD4E4F6) : const Color(0xFF1F2937);
    final Color subtitleColor = isDark ? const Color(0xFFE2BFB1) : const Color(0xFF4B5563);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: null,
      ),
      body: Stack(
        children: [
          // Background Decorative Gradients/Glows
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(isDark ? 0.08 : 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE9C349).withOpacity(isDark ? 0.04 : 0.02),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // Grid of countries
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: countries.length,
                        itemBuilder: (context, index) {
                          final item = countries[index];
                          final isSelected = selectedCurrency == item.currency;

                          return GestureDetector(
                            onTap: item.isComingSoon
                                ? null
                                : () => setState(() => selectedCurrency = item.currency),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: item.isComingSoon ? 0.5 : 1.0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryColor.withOpacity(0.1) : cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? primaryColor : unselectedBorder,
                                    width: isSelected ? 2.0 : 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(0.12),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.01),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Flag Container
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? primaryColor.withOpacity(0.3) : unselectedBorder,
                                          width: 1,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        item.flag,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item.currency,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.isComingSoon ? 'Coming Soon' : item.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: item.isComingSoon ? 9 : 11,
                                        fontWeight: item.isComingSoon ? FontWeight.bold : FontWeight.normal,
                                        color: item.isComingSoon ? primaryColor : subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Sticky Continue Button Area (with background blur equivalent padding)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: unselectedBorder,
                      width: 1.0,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: GestureDetector(
                    onTap: () {
                      final updatedRequest = widget.request.copyWith(
                        countryCode: selectedCurrency,
                      );

                      if (updatedRequest.accountType == 'PERSONAL') {
                        context.push('/personal-details', extra: updatedRequest);
                      } else {
                        context.push('/business-details', extra: updatedRequest);
                      }
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountryItem {
  final String name;
  final String currency;
  final String flag;
  final bool isComingSoon;

  _CountryItem({
    required this.name,
    required this.currency,
    required this.flag,
    this.isComingSoon = false,
  });
}
