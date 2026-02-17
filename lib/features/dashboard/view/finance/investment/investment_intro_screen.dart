import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/features/notifiers/investment_notifier.dart';

class InvestmentIntroScreen extends ConsumerStatefulWidget {
  const InvestmentIntroScreen({super.key});

  @override
  ConsumerState<InvestmentIntroScreen> createState() => _InvestmentIntroScreenState();
}

class _InvestmentIntroScreenState extends ConsumerState<InvestmentIntroScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(investmentProductNotifierProvider.notifier).fetchProductInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(investmentProductNotifierProvider);
    final product = state.data?.firstOrNull;

    if (state.isInitialLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
        body: const SizedBox.shrink(),
      );
    }

    if (!state.isDataAvailable || product == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Unable to load investment information', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(investmentProductNotifierProvider.notifier).fetchProductInfo(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF76301)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with Back Button
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/'),
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Invest',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),

              // Illustration
              Center(
                child: Image.asset(
                  'assets/images/investment/investment_intro.png',
                  height: 320,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Column(
                    children: [
                      const Icon(Icons.trending_up, size: 120, color: Color(0xFFF76301)),
                      const SizedBox(height: 16),
                      Text('[Illustration Here]', style: TextStyle(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1))),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),

              // Headline
              Text(
                'Invest Smart, Grow Steady',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Earn competitive returns when you invest from ₦1 million in secure, long-term opportunities designed to grow your wealth',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 4),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/finance/investment/create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF76301),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 0,
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showTermsModal(context, product, isDark),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF333333) : Colors.grey[200],
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 0,
                  ),
                  child: const Text('Review Terms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsModal(BuildContext context, dynamic product, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Investment Terms',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildTermItem('Minimum Investment', '₦${NumberFormat('#,###').format(product.minimumInvestmentAmount)}', isDark),
                    _buildTermItem('ROI Rate', '${(product.roiRate * 100).toInt()}%', isDark),
                    _buildTermItem('Tenure', '${product.tenureMonths} Months', isDark),
                    _buildTermItem('Capital Guaranteed', product.capitalGuaranteed ? 'Yes' : 'No', isDark),
                    _buildTermItem('Repayment Structure', product.repaymentStructure, isDark),
                    const SizedBox(height: 24),
                    Text('Features:', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...product.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(feature as String, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermItem(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
