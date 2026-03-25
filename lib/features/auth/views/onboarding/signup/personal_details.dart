import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/terms_and_conditions_widget.dart';
import 'package:valarpay/features/auth/widgets/need_help_modal.dart';
import 'package:valarpay/features/models/signup_request.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/core/utils/input_sanitizer.dart';

import 'package:valarpay/core/services/session_service.dart';
import '../../../../models/user_availablity_request.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  final SignUpRequest request;
  const PersonalDetailsScreen({required this.request, super.key});

  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();
  final _referralController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill if resuming from a draft
    if (widget.request.fullname != null &&
        widget.request.fullname!.contains(' ')) {
      final names = widget.request.fullname!.split(' ');
      _firstNameController.text = names[0];
      _lastNameController.text = names.sublist(1).join(' ');
    }
    _usernameController.text = widget.request.username ?? '';
    _dobController.text = widget.request.dateOfBirth ?? '';
    _referralController.text = widget.request.referralCode ?? '';
  }

  Future<void> _checkUserAvailablity() async {
    try {
      if (_formKey.currentState!.validate()) {
        await ref
            .read(userNotifierProvider.notifier)
            .checkUserExistance(
              UserAvailabilityRequest(username: _usernameController.text),
            );
        final userState = ref.read(userNotifierProvider);
        if (!userState.isDataAvailable && mounted) {
          AppMessenger.show(
            context,
            type: MessageType.error,
            message: userState.message ?? ' User already exist',
          );
        } else {
          final updatedRequest = widget.request.copyWith(
            fullname:
                '${InputSanitizer.sanitize(_firstNameController.text)} ${InputSanitizer.sanitize(_lastNameController.text)}',
            username: InputSanitizer.sanitize(_usernameController.text),
            dateOfBirth: _dobController.text,
            referralCode: InputSanitizer.sanitize(_referralController.text),
          );
          
          // Save draft locally
          await SessionService.saveSignUpDraft(updatedRequest);
          
          if (mounted) {
            context.push('/security-details', extra: updatedRequest);
          }
        }
      }
    } catch (e) {
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Failed to check username availablity: ${e.toString()}',
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
            onPressed: () {
              NeedHelpModal.show(context);
            },
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
                // Title
                Text(
                  'Personal Details',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Provide your personal information to create your account',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // First Name
                _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Enter your first name',
                ),
                const SizedBox(height: 16),

                // Last Name
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Enter your last name',
                ),
                const SizedBox(height: 16),

                // Username
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Enter your username',
                ),
                const SizedBox(height: 16),

                // Date of Birth
                _buildTextField(
                  controller: _dobController,
                  label: 'Date of Birth',
                  hint: 'DD/MM/YYYY',
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  suffixIcon: Icons.calendar_today,
                ),
                const SizedBox(height: 16),

                // Referral Code
                _buildTextField(
                  controller: _referralController,
                  label: 'Referral Code (Optional)',
                  hint: 'Enter referral code',
                  isRequired: false,
                ),
                const SizedBox(height: 24),

                // Terms & Conditions + Privacy Policy
                TermsAndConditionsWidget(),
                const SizedBox(height: 50),

                FullWidthButton(
                  text: 'Continue',
                  isLoading: userState.isInitialLoading,
                  onPressed: _checkUserAvailablity,
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
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: _inputDecoration(hint, suffixIcon),
          validator:
              (value) =>
                  (isRequired && (value == null || value.isEmpty))
                      ? 'This field is required'
                      : null,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, [IconData? suffixIcon]) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      suffixIcon:
          suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 yrs ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _referralController.dispose();
    super.dispose();
  }
}
