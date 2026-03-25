import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/terms_and_conditions_widget.dart';
import 'package:valarpay/features/auth/widgets/need_help_modal.dart';
import 'package:valarpay/features/models/email_request.dart';
import 'package:valarpay/features/models/signup_request.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/core/services/session_service.dart';

class SecurityDetailsScreen extends ConsumerStatefulWidget {
  final SignUpRequest request;
  const SecurityDetailsScreen({
    required this.request,
    super.key,
  });

  @override
  ConsumerState<SecurityDetailsScreen> createState() =>
      _SecurityDetailsScreenState();
}

class _SecurityDetailsScreenState extends ConsumerState<SecurityDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.request.email ?? '';
    _passwordController.text = widget.request.password ?? '';
    _confirmPasswordController.text = widget.request.password ?? '';
  }

  Future<void> _validateEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Passwords do not match',
      );
      return;
    }

    try {
      await ref
          .read(userNotifierProvider.notifier)
          .validateEmail(EmailRequest(email: _emailController.text));
      final userState = ref.read(userNotifierProvider);
      if (userState.isDataAvailable && mounted) {
        final updatedRequest = widget.request.copyWith(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        // Save draft locally
        await SessionService.saveSignUpDraft(updatedRequest);
        
        if (mounted) {
          context.push('/verify-email', extra: updatedRequest);
        }
      } else if (mounted) {
        AppMessenger.show(
          context,
          type: MessageType.error,
          message: userState.message ?? 'Unable to validate your email address',
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

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => GoRouter.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: () => NeedHelpModal.show(context),
            child: const Text(
              'Need Help?',
              style: TextStyle(color: appTheme.primaryColor, fontSize: 14),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Details',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address & password to secure your account',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // Email
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter new Password',
                  obscureText: _obscurePassword,
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 8 || value.length > 32) {
                      return 'Password must be between 8 and 32 characters';
                    }
                    
                    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
                    bool hasDigits = value.contains(RegExp(r'[0-9]'));
                    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
                    bool hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

                    if (!hasUppercase) {
                      return 'Password must contain at least one uppercase letter';
                    }
                    if (!hasLowercase) {
                      return 'Password must contain at least one lowercase letter';
                    }
                    if (!hasDigits) {
                      return 'Password must contain at least one number';
                    }
                    if (!hasSpecialCharacters) {
                      return 'Password must contain at least one special character';
                    }
                    
                    final pattern = RegExp(r'^[ -~]+$'); // printable ASCII
                    if (!pattern.hasMatch(value)) {
                      return 'Password contains invalid characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                const TermsAndConditionsWidget(),
                const SizedBox(height: 40),

                FullWidthButton(
                  text: 'Continue',
                  isLoading: userState.isInitialLoading,
                  onPressed: _validateEmail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: onToggleVisibility != null
                ? IconButton(
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appTheme.primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
