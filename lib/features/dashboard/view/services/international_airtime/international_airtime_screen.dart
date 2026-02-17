import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/core/utils/responsive_utils.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/notifiers/international_airtime_notifier.dart';
import 'package:valarpay/features/models/international_airtime_models.dart';
import 'country_provider_screen.dart';

class InternationalAirtimeScreen extends ConsumerStatefulWidget {
  const InternationalAirtimeScreen({super.key});

  @override
  ConsumerState<InternationalAirtimeScreen> createState() =>
      _InternationalAirtimeScreenState();
}

class _InternationalAirtimeScreenState
    extends ConsumerState<InternationalAirtimeScreen> {
  final _searchController = TextEditingController();
  List<InternationalCountry> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(internationalCountriesProvider.notifier).fetchCountries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, List<InternationalCountry> countries) {
    setState(() {
      _filteredCountries = countries
          .where((c) =>
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.isoCode.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countriesState = ref.watch(internationalCountriesProvider);
    final allCountries = countriesState.data ?? [];
    
    final displayCountries = _searchController.text.isEmpty ? allCountries : _filteredCountries;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'International Airtime',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC verification to purchase international airtime',
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => _onSearchChanged(v, allCountries),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.grey : Colors.black54,
                      ),
                      hintText: "Search Country",
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: ResponsiveUtils.borderRadius12,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (countriesState.isInitialLoading)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (displayCountries.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No countries found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayCountries.length,
                        itemBuilder: (context, index) {
                          final country = displayCountries[index];
                          return _buildCountryTile(country, isDark);
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildCountryTile(InternationalCountry country, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: country.flag.isNotEmpty
                ? SvgPicture.network(
                    country.flag,
                    fit: BoxFit.cover,
                    placeholderBuilder: (context) => Center(
                      child: Text(
                        country.isoCode,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      country.isoCode,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
        title: Text(
          country.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDark ? Colors.white70 : Colors.grey[600],
          size: 16,
        ),
        onTap: () {
          ref.read(selectedCountryIsoProvider.notifier).state = country.isoCode;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CountryProviderScreen(
                countryName: country.name,
                countryIso: country.isoCode,
                countryFlag: country.flag,
              ),
            ),
          );
        },
      ),
    );
  }
}
