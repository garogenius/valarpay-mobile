import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/user.dart';
import 'package:valarpay/features/models/username_request.dart';
import 'package:valarpay/features/models/verify_otp_request.dart';
import 'package:valarpay/features/notifiers/auth_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class Verify2faScreen extends ConsumerStatefulWidget {
  final UserModel request;

  const Verify2faScreen({required this.request, super.key});

  @override
  ConsumerState<Verify2faScreen> createState() => _Verify2faScreenState();
}

class _Verify2faScreenState extends ConsumerState<Verify2faScreen>
    with CodeAutoFill {
  bool _isLoading = false;
  int _resendTimer = 30;
  Timer? _timer;
  String _otp = '';

  void _startResendTimer() {
    _timer?.cancel();
    _resendTimer = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendTimer == 0) {
        timer.cancel();
        if (mounted) setState(() {});
      } else {
        if (mounted)
          setState(() {
            _resendTimer--;
          });
      }
    });
  }

  Future<void> _verify2fa() async {
    if (_otp.length != 6) {
      if (!mounted) return;
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Please enter the complete verification code',
      );
      return;
    }
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .verify2fa(
            VerifyOtpRequest(
              username:
                  widget.request.username.isNotEmpty
                      ? widget.request.username
                      : widget.request.phoneNumber ??
                          widget.request.email,
              otpCode: _otp,
            ),
          );
      final userState = ref.read(authNotifierProvider);

      if (!mounted) return;
      if (userState.isDataAvailable) {
        // Save the session including access token after 2FA verification
        final loginResponse = userState.data?.first;
        if (loginResponse != null) {
          await SessionService.saveSession(loginResponse);
          ref.read(userProvider.notifier).setUser(loginResponse.user);
        }
        context.go('/');
        return;
      } else {
        if (!mounted) return;
        AppMessenger.show(
          context,
          type: MessageType.error,
          message: userState.message ?? 'Invalid or expired OTP',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .resend2fa(UsernameRequest(username: widget.request.phoneNumber));
      AppMessenger.show(
        context,
        type: MessageType.success,
        message: ref.read(authNotifierProvider).message ?? 'Verification code sent to your phone number and email.',
      );
      _startResendTimer();
    } catch (e) {
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Failed to resend code: ${e.toString()}',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void codeUpdated() {
    if (!mounted) return;
    setState(() {
      _otp = code ?? '';
    });
    if (_otp.length == 6) {
      _verify2fa();
    }
  }

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    listenForCode(); // starts listening for SMS autofill
  }

  @override
  void dispose() {
    _timer?.cancel();
    cancel(); // stop listening
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authNotifierProvider);

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
              const SizedBox(height: 40),
              const Text(
                'Two Factor Authentication',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'We have sent an otp to your email and phone number ${widget.request.phoneNumber ?? ''}, enter the otp below to continue',
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

              // Resend section
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
                        color:
                            _resendTimer == 0
                                ? appTheme.primaryColor
                                : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              FullWidthButton(
                text: 'Continue',
                isLoading: userState.isInitialLoading && !_isLoading,
                onPressed: _verify2fa,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
