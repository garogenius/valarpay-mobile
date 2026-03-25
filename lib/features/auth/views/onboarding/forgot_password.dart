import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/forgot_password.dart';
import 'package:valarpay/features/models/username_request.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool isUserLogedIn = false;

  _forgotPassword() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      try {
        await ref
            .read(userNotifierProvider.notifier)
            .forgotPassword(ForgotPasswordRequest(username: username));
        final userState = ref.read(userNotifierProvider);
        if (userState.isDataAvailable && mounted) {
          AppMessenger.show(context,
              type: MessageType.success, message: 'Otp sent to your email');
          context.push('/forgot-password-verification',
              extra: UsernameRequest(username: username));
        } else if (mounted) {
          AppMessenger.show(context,
              type: MessageType.error,
              message: userState.message ?? 'Invalid username');
        }
      } catch (e) {
        AppMessenger.show(context,
            type: MessageType.error,
            message: 'An unexpected error occurred: ${e.toString()}');
      }
    }
  }

  _isUserLoggedIn() async {
    final loggedIn = await SessionService.isLoggedIn();
    setState(() {
      isUserLogedIn = loggedIn;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email or phone number to reset your password',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email/Phone Number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Enter your email or phone number',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: appTheme.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid username';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Send Reset Link Button

              FullWidthButton(
                text: 'Continue',
                isLoading: userState.isInitialLoading,
                onPressed: _forgotPassword,
              ),

              const SizedBox(height: 16),

              // Back to Login
              if (!isUserLogedIn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Remember your password? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push('/signin');
                      },
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          fontSize: 14,
                          color: appTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
