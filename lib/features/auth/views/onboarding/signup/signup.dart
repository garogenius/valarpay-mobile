import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/models/signup_request.dart';
import '../../../../../features/auth/widgets/need_help_modal.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  String selectedAccountType = 'Personal';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define colors according to the reference design
    final Color primaryColor = const Color(0xFFF76301);
    final Color tertiaryColor = const Color(0xFFE9C349);
    
    final Color backgroundColor = isDark ? const Color(0xFF041521) : const Color(0xFFF9FAFB);
    final Color cardBackgroundColor = isDark ? const Color(0xFF11212E).withOpacity(0.8) : Colors.white;
    final Color unselectedBorderColor = isDark ? Colors.white.withOpacity(0.12) : Colors.grey.shade200;
    
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
        actions: [
          TextButton(
            onPressed: () => NeedHelpModal.show(context),
            child: Text(
              'Need Help?',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Premium Soft Glows for Background Depth
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(isDark ? 0.08 : 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tertiaryColor.withOpacity(isDark ? 0.05 : 0.03),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Personal Account Card
                  _buildAccountCard(
                    title: 'Personal Account',
                    description: 'Perfect for everyday payments, international transfers, and managing digital assets with absolute security.',
                    icon: Icons.person,
                    iconBgColor: isDark ? const Color(0xFFF76301).withOpacity(0.2) : const Color(0xFFF76301).withOpacity(0.1),
                    iconColor: primaryColor,
                    bullets: [
                      _BulletItem(icon: Icons.bolt, text: 'Instant global transfers'),
                      _BulletItem(icon: Icons.security, text: 'Biometric vault security'),
                    ],
                    isSelected: selectedAccountType == 'Personal',
                    onTap: () => setState(() => selectedAccountType = 'Personal'),
                    primaryColor: primaryColor,
                    tertiaryColor: tertiaryColor,
                    cardBg: cardBackgroundColor,
                    unselectedBorder: unselectedBorderColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),

                  const SizedBox(height: 24),

                  // Business Account Card
                  _buildAccountCard(
                    title: 'Business Account',
                    description: 'Advanced multi-user management, high-volume transactions, and integrated enterprise-grade liquidity.',
                    icon: Icons.business,
                    iconBgColor: isDark ? const Color(0xFF3A486B).withOpacity(0.3) : const Color(0xFF3A486B).withOpacity(0.1),
                    iconColor: isDark ? const Color(0xFFB7C6EF) : const Color(0xFF2E3B5E),
                    bullets: [
                      _BulletItem(icon: Icons.corporate_fare, text: 'Multi-signatory approvals'),
                      _BulletItem(icon: Icons.api, text: 'Full API access & integration'),
                    ],
                    isSelected: selectedAccountType == 'Business',
                    onTap: () => setState(() => selectedAccountType = 'Business'),
                    primaryColor: primaryColor,
                    tertiaryColor: tertiaryColor,
                    cardBg: cardBackgroundColor,
                    unselectedBorder: unselectedBorderColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),

                  const SizedBox(height: 48),

                  // Action Button
                  GestureDetector(
                    onTap: () {
                      SignUpRequest request = SignUpRequest(
                        accountType: selectedAccountType.toUpperCase(),
                      );
                      context.push('/signup-currency', extra: request);
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
                        'Continue with Selection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Secured Caption
                  Text(
                    'SECURED BY VALAR-SHIELD PROTOCOL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: subtitleColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required List<_BulletItem> bullets,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color tertiaryColor,
    required Color cardBg,
    required Color unselectedBorder,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : unselectedBorder,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: primaryColor, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ...bullets.map((bullet) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(bullet.icon, color: tertiaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      bullet.text,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _BulletItem {
  final IconData icon;
  final String text;

  _BulletItem({required this.icon, required this.text});
}
