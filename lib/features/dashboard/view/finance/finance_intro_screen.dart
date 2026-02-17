import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/local_storage_service.dart';

class FinanceIntroScreen extends StatefulWidget {
  const FinanceIntroScreen({super.key});

  @override
  State<FinanceIntroScreen> createState() => _FinanceIntroScreenState();
}

class _FinanceIntroScreenState extends State<FinanceIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Lock & Earn',
      'description': 'Instantly lock a lump sum, earn higher interest, and grow your money securely',
      'image': 'assets/images/finance_intro_1.png',
    },
    {
      'title': 'Save with Discipline',
      'description': 'Automate daily, weekly, or monthly savings at your own pace',
      'image': 'assets/images/finance_intro_2.png',
    },
    {
      'title': 'Save for Goals',
      'description': 'Set a goal and date, we calculate the amount you need to save',
      'image': 'assets/images/finance_intro_3.png',
    },
    {
      'title': 'Flexible Smart Saving',
      'description': 'Save effortlessly with rules like round-ups, random saves, or auto-top ups',
      'image': 'assets/images/finance_intro_4.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF76301), // Orange from screenshots
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () async {
                    await LocalStorageService.saveBool('has_seen_finance_intro', true);
                    if (mounted) context.pop();
                  },
                ),
              ),
            ),
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: List.generate(
                  _slides.length,
                  (index) => Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image/Illustration placeholder
                        Image.asset(
                          _slides[index]['image']!,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _slides[index]['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _slides[index]['description']!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Lead to the actual finance main screen
                          await LocalStorageService.saveBool('has_seen_finance_intro', true);
                          if (mounted) context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFF76301),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1 ? 'Start Saving' : 'Review Terms',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
