import 'package:flutter/material.dart';

class InvestmentsComingSoonScreen extends StatelessWidget {
  const InvestmentsComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const accentColor = Color(0xFFFF5722);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Illustration Icon
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.trending_up,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                const SizedBox(height: 48),

                // Title
                Text(
                  'Investments Coming Soon',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'We\'re building powerful investment tools to help you grow your wealth and achieve your financial goals.',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(color: Theme.of(context).primaryColor, width: 24),
                    const SizedBox(width: 8),
                    _buildDot(color: isDark ? Colors.white24 : Colors.black12, width: 8),
                    const SizedBox(width: 8),
                    _buildDot(color: isDark ? Colors.white24 : Colors.black12, width: 8),
                  ],
                ),

                const SizedBox(height: 64),

                // Future Features Header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'WHAT TO EXPECT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Feature Cards
                _buildFeatureCard(
                  context,
                  icon: Icons.pie_chart_outline,
                  title: 'Smart Portfolio Management',
                  subtitle: 'Track and manage all your assets in one place',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.analytics_outlined,
                  title: 'Real-time Market Analysis',
                  subtitle: 'Get insights and data to make better decisions',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.security_outlined,
                  title: 'Secure & Verified Assets',
                  subtitle: 'Invest in vetted, high-yield opportunities',
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required Color color, double width = 8}) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color,
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
