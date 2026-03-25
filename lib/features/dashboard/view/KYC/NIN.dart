import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/dashboard/view/KYC/BVN.dart';
import 'package:valarpay/features/dashboard/view/KYC/nin_camera_permission.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/services/smileid_socket_service.dart';

final ninProvider = StateProvider<String>((ref) => '');

class NINPage extends ConsumerStatefulWidget {
  const NINPage({Key? key}) : super(key: key);

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
    
    try {
      // Step 1: Basic KYC — verify NIN details
      final res = await ref
          .read(userNotifierProvider.notifier)
          .submitBasicKyc(
            idType: 'NIN_V2',
            idNumber: nin,
            idDob: dob,
            idPhoneNumber: phone,
          );

      if (!mounted) return;

      if (res != null && (res.statusCode == 200 || res.statusCode == 201)) {
        final lowerMsg = (res.message ?? '').toLowerCase();
        
        // If Basic KYC is already done, just proceed to liveness check
        if (lowerMsg.contains('exist') || lowerMsg.contains('already')) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NinCameraPermissionPage(nin: nin),
            ),
          );
          return;
        }

        if (res.isSuccess == false || 
            lowerMsg.contains('invalid') || 
            lowerMsg.contains('fail')) {
          AppMessenger.show(
            context,
            message: res.message.isNotEmpty ? res.message : 'NIN verification failed. Please try again.',
            type: MessageType.error,
          );
          return;
        }

        if (!mounted) return;

        // Success: Proceed directly to liveness check without waiting for socket
        AppMessenger.show(context, message: 'ID details submitted. Proceeding to liveness check...', type: MessageType.success);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NinCameraPermissionPage(nin: nin),
          ),
        );
      } else {
        AppMessenger.show(
          context,
          message: res?.message ?? 'NIN verification failed. Please try again.',
          type: MessageType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        AppMessenger.show(
          context,
          message: 'Verification error: ${e.toString()}',
          type: MessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nin = ref.watch(ninProvider);
    final isFormValid = nin.length == 11;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              const Text(
                'Your NIN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Enter your 11-digit NIN to verify your identity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 32),

              // NIN Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your NIN',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      letterSpacing: 0.06,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.5),
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
                        hintText: 'Enter your NIN',
                        hintStyle: TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontFamily: 'SF Pro',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Info Section
              Column(
                children: [
                  const Text(
                    'Why we need your NIN?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We need your NIN to verify your identity and upgrade your account. This allows you to enjoy higher transaction limits and more features.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontFamily: 'SF Pro',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your NIN is securely encrypted and never shared with third parties.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF76301),
                      fontFamily: 'SF Pro',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Continue Button
              FullWidthButton(
                text: 'Continue',
                isEnabled: isFormValid,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : () => _proceedWithNIN(nin),
              ),
              const SizedBox(height: 16),

              // Switch to BVN option
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const BVNPage()),
                  );
                },
                child: const Text(
                  'Prefer to use BVN instead?',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


