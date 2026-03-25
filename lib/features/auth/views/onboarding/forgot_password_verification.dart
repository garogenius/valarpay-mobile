import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:valarpay/core/constants/storage_keys.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/terms_and_conditions_widget.dart';
import 'package:valarpay/features/models/forgot_password.dart';
import 'package:valarpay/features/models/username_request.dart';
import 'package:valarpay/features/models/verify_otp_request.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class ForgotPasswordVerificationScreen extends ConsumerStatefulWidget {
  final UsernameRequest request;
  const ForgotPasswordVerificationScreen({super.key, required this.request});

  @override
  ConsumerState<ForgotPasswordVerificationScreen> createState() =>
      _ForgotPasswordVerificationScreenState();
}

class _ForgotPasswordVerificationScreenState
    extends ConsumerState<ForgotPasswordVerificationScreen> with CodeAutoFill {
  bool _isLoading = false;
  int _resendTimer = 30;
  Timer? _timer;
  String _otp = '';

  void _startResendTimer() {
    _timer?.cancel();
    _resendTimer = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() {
          _resendTimer--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Please enter the complete verification code',
      );
      return;
    }
    try {
      await ref.read(userNotifierProvider.notifier).verifyForgotPassword(
          VerifyOtpRequest(
              username: widget.request.username, otpCode: _otp));
      final userState = ref.read(userNotifierProvider);

      if (userState.isDataAvailable && mounted) {
        context.push('/reset-password', extra: widget.request);
      } else if (mounted) {
        AppMessenger.show(
          context,
          type: MessageType.error,
          message: userState.message ?? 'Invalid or expired OTP',
        );
      }
    } catch (e) {
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> _resendOtp() async {
    String? username = await LocalStorageService.get(StorageKeys.username);
    if (username == null) {
      Navigator.pop(context);
    }
    setState(() => _isLoading = true);
    try {
      await ref
          .read(userNotifierProvider.notifier)
          .forgotPassword(ForgotPasswordRequest(username: username));
      AppMessenger.show(
        context,
        message: ref.read(userNotifierProvider).message ?? 'Verification code sent to your email.',
        type: MessageType.success,
      );
      _startResendTimer();
    } catch (e) {
      AppMessenger.show(
        context,
        message: 'Failed to resend code: ${e.toString()}',
        type: MessageType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void codeUpdated() {
    setState(() {
      _otp = code ?? '';
    });
    if (_otp.length == 6) {
      _verifyOtp();
    }
  }

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    listenForCode(); // listens for autofill/paste
  }

  @override
  void dispose() {
    _timer?.cancel();
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Verify Your Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the code we sent to your email.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              PinFieldAutoFill(
                codeLength: 6,
                decoration: BoxLooseDecoration(
                  gapSpace: 12,
                  strokeColorBuilder: FixedColorBuilder(Colors.grey.shade400),
                  bgColorBuilder: FixedColorBuilder(
                    Colors.grey.shade50.withOpacity(0.8),
                  ),
                  radius: const Radius.circular(8),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  strokeWidth: 1.4,
                ),
                currentCode: _otp,
                onCodeChanged: (code) {
                  setState(() => _otp = code ?? '');
                },
              ),

              const SizedBox(height: 40),

              // Didn't receive the code
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  GestureDetector(
                    onTap: _resendTimer == 0 ? _resendOtp : null,
                    child: Text(
                      _isLoading
                          ? 'Sending...'
                          : _resendTimer == 0
                              ? 'Resend'
                              : 'Resend in $_resendTimer seconds',
                      style: TextStyle(
                        fontSize: 14,
                        color: _resendTimer == 0
                            ? appTheme.primaryColor
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              const TermsAndConditionsWidget(),
              const SizedBox(height: 50),

              FullWidthButton(
                text: 'Continue',
                isLoading: userState.isInitialLoading && !_isLoading,
                onPressed: _verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
