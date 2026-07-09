import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/dashboard/view/KYC/BVN.dart';
import 'package:valarpay/features/dashboard/view/KYC/nin_camera_permission.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/services/smileid_socket_service.dart';

final ninProvider = StateProvider<String>((ref) => '');

class NINPage extends ConsumerStatefulWidget {
  final bool isTierUpgrade;
  const NINPage({Key? key, this.isTierUpgrade = false}) : super(key: key);

  @override
  ConsumerState<NINPage> createState() => _NINPageState();
}

class _NINPageState extends ConsumerState<NINPage> {
  late TextEditingController _ninController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _ninController = TextEditingController(
      text: ref.read(ninProvider),
    );
    // Connect to SmileID socket
    SmileIdSocketService().connect();
  }

  @override
  void dispose() {
    _ninController.dispose();
    super.dispose();
  }

  Future<void> _proceedWithNIN(String nin) async {
    if (_isSubmitting) return;

    final user = ref.read(userProvider);
    if (user == null) return;

    // Auto-fetch DOB from profile (required)
    final dob = user.dateOfBirth ?? '';
    // Phone is optional
    final phone = user.phoneNumber;

    if (dob.isEmpty) {
      AppMessenger.show(
        context,
        message: 'Your Date of Birth is required. Please update your profile first.',
        type: MessageType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    // Ensure socket is connected before proceeding
    await SmileIdSocketService().connect();
    
    if (mounted) {
      context.push('/nin-camera-permission/NIN/$nin?isTierUpgrade=${widget.isTierUpgrade}');
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nin = ref.watch(ninProvider);
    final isFormValid = nin.length == 11;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Title
              Text(
                'Your NIN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'SF Pro',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Enter your 11-digit NIN to verify your identity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF9CA3AF),
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, // Dark background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'National Identification Number',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontFamily: 'SF Pro',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _ninController,
                        onChanged: (value) {
                          ref.read(ninProvider.notifier).state = value;
                        },
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '35614090000',
                          hintStyle: TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontFamily: 'SF Pro',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                          counterText: '',
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${nin.length}/11',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontFamily: 'SF Pro',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 46, 46, 46),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info,
                            color: Color(0xFFF76301), // Or use standard app primary color
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 12,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(text: 'Dial '),
                                  TextSpan(
                                    text: '*346# ',
                                    style: TextStyle(
                                      color: Color(0xFFF76301),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: 'on your registered phone number to get your NIN. Service costs '),
                                  TextSpan(
                                    text: '₦20 ',
                                    style: TextStyle(
                                      color: Color(0xFFF76301),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: 'Or visit '),
                                  TextSpan(
                                    text: 'nimc.gov.ng/sms-service',
                                    style: TextStyle(
                                      color: Color(0xFFF76301),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Continue Button
              FullWidthButton(
                text: 'Next',
                isEnabled: isFormValid,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : () => _proceedWithNIN(nin),
              ),
              const SizedBox(height: 16),

              // Switch to BVN option / Help
              TextButton(
                onPressed: () {
                  // Usually click here goes to support or help, but since we had a BVN toggle here before, we can leave it or switch to Need Help?
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const BVNPage()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                    children: [
                      TextSpan(text: 'Need Help? '),
                      TextSpan(
                        text: 'Click Here',
                        style: TextStyle(
                          color: Color(0xFFC7A24F), // A gold/yellow hue close to the screenshot or theme
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


