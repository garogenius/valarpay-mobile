import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/dashboard/view/KYC/nin_camera_permission.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/services/smileid_socket_service.dart';
import 'package:valarpay/features/models/phone_number_request.dart';
import 'package:valarpay/features/models/verify_phone_number.dart';
import '../../widgets/Kyc/kyc_progress_bar.dart';
import 'kyc_step_provider.dart';

final bvnProvider = StateProvider<String>((ref) => '');

class BVNPage extends ConsumerStatefulWidget {
  const BVNPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BVNPage> createState() => _BVNPageState();
}

class _BVNPageState extends ConsumerState<BVNPage> {
  late TextEditingController _bvnController;
  bool _isSubmitting = false;
  bool _phoneVerifiedLocally = false;

  @override
  void initState() {
    super.initState();
    _bvnController = TextEditingController(text: ref.read(bvnProvider));
    // Connect to SmileID socket
    SmileIdSocketService().connect();
  }

  @override
  void dispose() {
    _bvnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bvn = ref.watch(bvnProvider);
    final isFormValid = bvn.length == 11;
    final currentStep = ref.watch(kycStepProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(kycStepProvider.notifier).state = 2;
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Step Progress Bar
              StepProgressBar(currentStep: currentStep),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Your BVN',
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
                'Enter your BVN to verify your identity',
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

              // BVN Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your BVN',
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
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _bvnController,
                      onChanged: (value) {
                        ref.read(bvnProvider.notifier).state = value;
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
                        hintText: 'Enter your BVN',
                        hintStyle: TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontFamily: 'SF Pro',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        counterText: '', // Hide counter
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
                    'Why we need your BVN?',
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
                    'We need your BVN to confirm your identity and ensure your account is secure. Sharing your BVN does not give us access to your bank account or funds.',
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
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'To get your BVN, dial ',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                        TextSpan(
                          text: '*565#',
                          style: TextStyle(color: Color(0xFFF76301)),
                        ),
                      ],
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
                onPressed: _isSubmitting ? null : () async {
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

                  if (!user.isPhoneVerified && !_phoneVerifiedLocally) {
                    _showPhoneVerificationModal(context, phone, onVerified: () {
                      if (mounted) {
                        setState(() {
                          _phoneVerifiedLocally = true;
                        });
                      }
                      // Trigger BVN verification automatically after phone is verified
                      _submitBvn(bvn, dob, phone);
                    });
                    return;
                  }

                  _submitBvn(bvn, dob, phone);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitBvn(String bvn, String dob, String? phone) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    
    // Ensure socket is connected before proceeding
    await SmileIdSocketService().connect();
    
    try {
      // Step 1: Basic KYC — verify BVN details
      final res = await ref.read(userNotifierProvider.notifier).submitBasicKyc(
            idType: 'BVN',
            idNumber: bvn,
            idDob: dob,
            idPhoneNumber: phone,
          );

      if (!mounted) return;

      if (res != null && (res.statusCode == 200 || res.statusCode == 201)) {
        // Step 2: Check if there's a synchronous error wrapped in a 200 OK
        final lowerMsg = (res.message ?? '').toLowerCase();
        
        // If Basic KYC is already done, just proceed to liveness check
        if (lowerMsg.contains('exist') || lowerMsg.contains('already')) {
          if (!mounted) return;
          ref.read(kycStepProvider.notifier).state = 4;
          context.push('/nin-camera-permission/$bvn');
          return;
        }

        if (res.isSuccess == false || 
            lowerMsg.contains('invalid') || 
            lowerMsg.contains('fail')) {
          AppMessenger.show(
            context,
            message: res.message.isNotEmpty ? res.message : 'BVN verification failed. Please try again.',
            type: MessageType.error,
          );
          return;
        }

        if (!mounted) return;

        // Success: Proceed directly to liveness check without waiting for socket
        ref.read(kycStepProvider.notifier).state = 4;
        context.push('/nin-camera-permission/$bvn');
      } else {
        AppMessenger.show(
          context,
          message: res?.message ?? 'BVN verification failed. Please try again.',
          type: MessageType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        AppMessenger.show(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          type: MessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showPhoneVerificationModal(BuildContext context, String? initialPhone,
      {VoidCallback? onVerified}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PhoneVerificationModal(onVerified: onVerified);
      },
    );
  }
}

class PhoneVerificationModal extends ConsumerStatefulWidget {
  final VoidCallback? onVerified;
  const PhoneVerificationModal({Key? key, this.onVerified}) : super(key: key);

  @override
  ConsumerState<PhoneVerificationModal> createState() =>
      _PhoneVerificationModalState();
}

class _PhoneVerificationModalState extends ConsumerState<PhoneVerificationModal> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    if (user != null && user.phoneNumber != null) {
      _phoneController.text = user.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppMessenger.show(context, message: 'Please enter a valid phone number', type: MessageType.warning);
      return;
    }
    
    setState(() => _isLoading = true);
    
    final res = await ref.read(userNotifierProvider.notifier).validatePhone(
      PhoneNumberRequest(phoneNumber: phone),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (res != null && res.statusCode == 200) {
        setState(() => _otpSent = true);
        AppMessenger.show(context, message: 'OTP sent to $phone', type: MessageType.success);
      } else {
        // Use message from state if res is null (which happens on error in our notifier)
        final errorMsg = res?.message ?? ref.read(userNotifierProvider).message ?? 'Failed to send OTP';
        AppMessenger.show(context, message: errorMsg, type: MessageType.error);
      }
    }
  }

  Future<void> verifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    
    if (otp.isEmpty) {
      AppMessenger.show(context, message: 'Please enter the OTP', type: MessageType.warning);
      return;
    }
    
    setState(() => _isLoading = true);
    
    final res = await ref.read(userNotifierProvider.notifier).verifyPhone(
      VerifyPhoneOtpRequest(
        phoneNumber: phone,
        otpCode: otp,
        userId: ref.read(userProvider)?.id,
      ),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (res != null && (res.statusCode == 200 || res.statusCode == 201 || res.message.toLowerCase().contains("success"))) {
        AppMessenger.show(context, message: 'Phone number verified successfully', type: MessageType.success);
        // Refresh User Profile so the app knows phone is verified
        await ref.read(userNotifierProvider.notifier).refreshUserProfile();
        if (mounted) {
          Navigator.pop(context);
          if (widget.onVerified != null) {
            widget.onVerified!();
          }
        }
      } else {
        // Use message from state if res is null (which happens on error in our notifier)
        final errorMsg = res?.message ?? ref.read(userNotifierProvider).message ?? 'Invalid or expired OTP';
        AppMessenger.show(context, message: errorMsg, type: MessageType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _otpSent ? 'Verify Phone Number' : 'Add Phone Number',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _otpSent 
                ? 'Enter the OTP sent to ${_phoneController.text}'
                : 'Please verify your phone number before continuing.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            if (!_otpSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. 08012345678',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              FullWidthButton(
                text: 'Send OTP',
                isLoading: _isLoading,
                onPressed: sendOtp,
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter 6-digit OTP',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              FullWidthButton(
                text: 'Verify',
                isLoading: _isLoading,
                onPressed: verifyOtp,
              ),
              TextButton(
                onPressed: _isLoading ? null : () => setState(() => _otpSent = false),
                child: const Text('Change Phone Number'),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
