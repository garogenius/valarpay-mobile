import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/phone_number_request.dart';
import 'package:valarpay/features/models/signup_request.dart';
import 'package:valarpay/features/models/verify_phone_number.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  final SignUpRequest request;

  const VerifyPhoneScreen({
    required this.request,
    super.key,
  });

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen>
    with CodeAutoFill {
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

  Future<void> _verifyPhone() async {
    final phone = widget.request.phoneNumber;

    if (_otp.length != 6) {
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Please enter the complete verification code',
      );
      return;
    }
    try {
      await ref.read(userNotifierProvider.notifier).verifyPhone(
            VerifyPhoneOtpRequest(
              phoneNumber: phone,
              otpCode: _otp,
              userId: ref.read(userProvider)?.id,
            ),
          );
      final userState = ref.read(userNotifierProvider);

      if (userState.isDataAvailable && mounted) {
        _register();
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
    setState(() => _isLoading = true);
    try {
      await ref.read(userNotifierProvider.notifier).validatePhone(
          PhoneNumberRequest(phoneNumber: widget.request.phoneNumber));
      AppMessenger.show(
        context,
        type: MessageType.success,
        message: ref.read(userNotifierProvider).message ?? 'Verification code sent to your phone number.',
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

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(userNotifierProvider.notifier);

    widget.request.accountType == "BUSINESS"
        ? await notifier.registerBusiness(widget.request)
        : await notifier.register(widget.request);

    final state = ref.read(userNotifierProvider);
    if (state.isDataAvailable) {
      context.pushReplacement('/signup-success', extra: widget.request);
    } else {
      AppMessenger.show(
        context,
        message: state.message ?? 'Registration failed',
        type: MessageType.error,
      );
    }
  }

  @override
  void codeUpdated() {
    setState(() {
      _otp = code ?? '';
    });
    if (_otp.length == 6) {
      _verifyPhone();
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
              const SizedBox(height: 40),
              const Text(
                'Verify Phone Number',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the code we sent to ${widget.request.phoneNumber ?? '+234 0000000000'}',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // ✅ OTP Input Fields - Rounded Bordered Boxes (No Hint)
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
                        color: _resendTimer == 0
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
                onPressed: _verifyPhone,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
