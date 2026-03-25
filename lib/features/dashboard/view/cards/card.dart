import 'package:flutter/material.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/dashboard/view/cards/get_physical_card.dart';
import 'package:valarpay/features/dashboard/view/cards/virtual_card_tab.dart';
import 'package:valarpay/features/dashboard/view/cards/linked_card_tab.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int _currentTabIndex = 1; // Defaulting to Virtual Card tab index as requested previously

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Cards",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 42,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F1F1F) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildCardToggle("Physical", 0),
                    _buildCardToggle("Virtual", 1),
                    _buildCardToggle("Linked", 2),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_currentTabIndex == 0)
                _buildPhysicalCardIntro(context, isDark)
              else if (_currentTabIndex == 1)
                const VirtualCardTab()
              else
                const LinkedCardTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhysicalCardIntro(BuildContext context, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/card_image.jpg',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[200], borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.credit_card, color: isDark ? Colors.white24 : Colors.black12, size: 64),
            ),
          ),
        ),
        const SizedBox(height: 40),
        _buildFeatureRow(Icons.card_giftcard, "Free Application and Usage", "Free application, Zero maintenance"),
        const SizedBox(height: 16),
        _buildFeatureRow(Icons.attach_money, "Accepted Globally", "Flexible spending with 10% annual interest"),
        const SizedBox(height: 16),
        _buildFeatureRow(Icons.verified_user, "Secure & Licensed", "Manage your card effortlessly in ValarPay App"),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/ndic.jpeg',
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),
        const SizedBox(height: 48),
        FullWidthButton(
          text: "Get Card Now",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const GetPhysicalCardScreen()));
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF76301).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFF76301), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Expanded _buildCardToggle(String label, int index) {
    final bool isActive = _currentTabIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? appTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

