import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/reset_pin_model.dart';
import 'package:valarpay/features/notifiers/reset_pin_notifier.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class ForgotPinScreen extends ConsumerStatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  ConsumerState<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends ConsumerState<ForgotPinScreen>
    with CodeAutoFill {
  final _formKey = GlobalKey<FormState>();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;
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

  Future<void> _initiateResetPin() async {
    if (_otp.length != 4) {
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Please enter the complete verification code',
      );
      return;
    }
    try {
      await ref
          .read(resetPinNotifierProvider.notifier)
          .resetPin(
            ResetPinRequest(
              otpCode: _otp,
              pin: _newPinController.text,
              confirmPin: _confirmPinController.text,
            ),
          );
      final resetPinState = ref.read(resetPinNotifierProvider);

      if (resetPinState.isDataAvailable && mounted) {
        AppMessenger.show(
          context,
          type: MessageType.success,
          message: resetPinState.message ?? 'Pin reset successfully',
        );
        Navigator.pop(context);
      } else if (mounted) {
        AppMessenger.show(
          context,
          type: MessageType.error,
          message: resetPinState.message ?? 'Invalid or expired OTP',
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

  Future<void> _sendForgotPinOtp() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(resetPinNotifierProvider.notifier).forgotPin();
      AppMessenger.show(
        context,
        type: MessageType.success,
        message: ref.read(resetPinNotifierProvider).message ?? 'Verification code sent to your phone number/email.',
      );
      _startResendTimer();
    } catch (e) {
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Failed to send code: ${e.toString()}',
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
  }

  @override
  void initState() {
    super.initState();
    _sendForgotPinOtp();
    listenForCode(); // starts listening for SMS autofill
  }

  @override
  void dispose() {
    _timer?.cancel();
    cancel(); // stop listening
    _confirmPinController.dispose();
    _newPinController.dispose();
    _otp = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetPinState = ref.watch(userNotifierProvider);
    final user = ref.watch(userProvider);
    final email = user?.email ?? 'email@valarpay.com';
    final phoneNumber = user?.phoneNumber ?? '0123456789';

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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Verify Phone Number/Email address',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _isLoading
                      ? 'Sending reset pin OTP code to $email and $phoneNumber to reset your pin'
                      : 'Enter the code we sent to $email and $phoneNumber to reset your pin',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // ✅ OTP Input Fields - Rounded Bordered Boxes (No Hint)
                PinFieldAutoFill(
                  codeLength: 4,
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    GestureDetector(
                      onTap: _resendTimer == 0 ? _sendForgotPinOtp : null,
                      child: Text(
                        _resendTimer == 0
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

                const SizedBox(height: 24),

                // New Pin Field
                const Text(
                  "New Pin",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _newPinController,
                  obscureText: _obscureNewPin,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter your new pin',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPin
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPin = !_obscureNewPin;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).cardColor.withValues(alpha: 0.5),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: appTheme.primaryColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: 20.h),
                const Text(
                  "Confirm New Pin",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _confirmPinController,
                  obscureText: _obscureConfirmPin,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Confirm your new pin',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPin
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPin = !_obscureConfirmPin;
                        });
                      },
                    ),

                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).cardColor.withValues(alpha: 0.5),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: appTheme.primaryColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),

                Spacer(),

                FullWidthButton(
                  text: 'Continue',
                  isEnabled:
                      _otp.length == 4 &&
                      _confirmPinController.text.isNotEmpty &&
                      _newPinController.text.isNotEmpty,
                  isLoading: resetPinState.isInitialLoading && !_isLoading,
                  onPressed: _initiateResetPin,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
