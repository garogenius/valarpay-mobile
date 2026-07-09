import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/dashboard/view/cards/get_physical_card.dart';
import 'package:valarpay/features/dashboard/view/cards/virtual_card_tab.dart';
import 'package:valarpay/features/dashboard/view/cards/linked_card_tab.dart';
import 'package:valarpay/features/dashboard/view/cards/widgets/virtual_card_widget.dart';

// Riverpod Provider to manage physical card creation simulation reactively
final physicalCardCreatedProvider = StateProvider<bool>((ref) => false);

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  int _currentTabIndex = 1; // Defaulting to Virtual Card tab index
  bool _showPhysicalDetails = false;
  bool _isPhysicalFrozen = false;
  double _physicalLimit = 20000.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPhysicalCreated = ref.watch(physicalCardCreatedProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF041521) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "ValarPay Cards",
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: isDark ? const Color(0xFFD4E4F6) : const Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              
              // Custom Toggle Bar
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF11212E) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    _buildCardToggle("Physical", 0),
                    _buildCardToggle("Virtual", 1),
                    _buildCardToggle("Link Card", 2),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Content Switcher
              if (_currentTabIndex == 0)
                isPhysicalCreated 
                    ? _buildPhysicalCardDashboard(isDark)
                    : _buildPhysicalCardIntro(context, isDark)
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

  // Beautiful Physical Card Dashboard (matching the reference HTML bento grid and controls)
  Widget _buildPhysicalCardDashboard(bool isDark) {
    final Color primaryColor = const Color(0xFFF76301);
    final Color tertiaryColor = const Color(0xFFE9C349);
    final Color textColor = isDark ? const Color(0xFFD4E4F6) : const Color(0xFF1F2937);
    final Color subtitleColor = isDark ? const Color(0xFFE2BFB1) : const Color(0xFF4B5563);
    final Color cardBackground = isDark ? const Color(0xFF11212E).withOpacity(0.4) : Colors.white;
    final Color unselectedBorder = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        
        // 1. Physical ATM Card (Midnight Executive Theme)
        VirtualCardWidget(
          showDetails: _showPhysicalDetails,
          designTheme: 'Midnight Executive',
        ),

        const SizedBox(height: 24),

        // 2. Stats Bento Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              label: 'BALANCE',
              value: '\$12,450.00',
              isDark: isDark,
              cardBg: cardBackground,
              borderCol: unselectedBorder,
              labelColor: subtitleColor,
              valueColor: primaryColor,
            ),
            _buildStatCard(
              label: 'SPENT TODAY',
              value: '\$248.12',
              isDark: isDark,
              cardBg: cardBackground,
              borderCol: unselectedBorder,
              labelColor: subtitleColor,
              valueColor: textColor,
            ),
            _buildStatCard(
              label: 'LIMIT',
              value: '\$${_physicalLimit.toStringAsFixed(0)}',
              isDark: isDark,
              cardBg: cardBackground,
              borderCol: unselectedBorder,
              labelColor: subtitleColor,
              valueColor: textColor,
            ),
            _buildStatCard(
              label: 'STATUS',
              value: _isPhysicalFrozen ? 'Frozen' : 'Active',
              isDark: isDark,
              cardBg: cardBackground,
              borderCol: unselectedBorder,
              labelColor: subtitleColor,
              valueColor: _isPhysicalFrozen ? primaryColor : tertiaryColor,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 3. Card Controls Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: unselectedBorder, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Card Controls',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  _buildControlCard(
                    icon: _isPhysicalFrozen ? Icons.lock_open : Icons.lock,
                    title: _isPhysicalFrozen ? 'Unfreeze Card' : 'Freeze Card',
                    subtitle: _isPhysicalFrozen ? 'Instantly enable' : 'Instantly disable',
                    isDark: isDark,
                    iconColor: primaryColor,
                    iconBgColor: primaryColor.withOpacity(0.2),
                    textColor: textColor,
                    subColor: subtitleColor,
                    onTap: () => setState(() => _isPhysicalFrozen = !_isPhysicalFrozen),
                  ),
                  _buildControlCard(
                    icon: _showPhysicalDetails ? Icons.visibility_off : Icons.visibility,
                    title: _showPhysicalDetails ? 'Hide Details' : 'Show Details',
                    subtitle: 'Reveal info',
                    isDark: isDark,
                    iconColor: const Color(0xFFB7C6EF),
                    iconBgColor: const Color(0xFFB7C6EF).withOpacity(0.2),
                    textColor: textColor,
                    subColor: subtitleColor,
                    onTap: () => setState(() => _showPhysicalDetails = !_showPhysicalDetails),
                  ),
                  _buildControlCard(
                    icon: Icons.settings,
                    title: 'Spending Limits',
                    subtitle: 'Adjust caps',
                    isDark: isDark,
                    iconColor: tertiaryColor,
                    iconBgColor: tertiaryColor.withOpacity(0.2),
                    textColor: textColor,
                    subColor: subtitleColor,
                    onTap: () => _showLimitsDialog(context),
                  ),
                  _buildControlCard(
                    icon: Icons.add_card,
                    title: 'Fund Card',
                    subtitle: 'Add balance',
                    isDark: isDark,
                    iconColor: const Color(0xFFB7C6EF),
                    iconBgColor: const Color(0xFFB7C6EF).withOpacity(0.2),
                    textColor: textColor,
                    subColor: subtitleColor,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Funding Physical Card is active')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 4. Recent Transactions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        _buildTransactionRow(
          title: 'Luxury Retail Store',
          time: 'Yesterday, 11:20 AM',
          amount: '-\$1,240.50',
          category: 'Shopping',
          isDark: isDark,
          cardBg: cardBackground,
          borderCol: unselectedBorder,
          textColor: textColor,
          subColor: subtitleColor,
          initials: 'LR',
          iconColor: const Color(0xFFB7C6EF),
        ),
        _buildTransactionRow(
          title: 'Cloudflare Inc.',
          time: '2 days ago',
          amount: '-\$20.00',
          category: 'Subscription',
          isDark: isDark,
          cardBg: cardBackground,
          borderCol: unselectedBorder,
          textColor: textColor,
          subColor: subtitleColor,
          initials: 'CF',
          iconColor: primaryColor,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: labelColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color iconColor,
    required Color iconBgColor,
    required Color textColor,
    required Color subColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2B39).withOpacity(0.6) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: subColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow({
    required String title,
    required String time,
    required String amount,
    required String category,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color textColor,
    required Color subColor,
    required String initials,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category,
                style: TextStyle(
                  fontSize: 11,
                  color: subColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLimitsDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: _physicalLimit.toStringAsFixed(0));
    
    final double? newLimit = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(
          'Set Spending Limit',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the maximum amount (USD) allowed for daily transactions.',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                hintText: '20000',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.white30 : Colors.black26),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              Navigator.pop(ctx, val);
            },
            child: Text(
              'Apply',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );

    if (newLimit != null) {
      setState(() {
        _physicalLimit = newLimit;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Spending limit set to \$${newLimit.toStringAsFixed(0)}')),
        );
      }
    }
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
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF11212E) : Colors.grey[200], 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
                ),
              ),
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
            color: isActive ? const Color(0xFFF76301) : Colors.transparent,
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
