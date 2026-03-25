import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/terms_and_conditions_widget.dart';
import 'package:valarpay/features/models/phone_number_request.dart';
import 'package:valarpay/features/models/signup_request.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/core/services/session_service.dart';

class ValidatePhoneScreen extends ConsumerStatefulWidget {
  final SignUpRequest request;
  const ValidatePhoneScreen({
    required this.request,
    super.key,
  });

  @override
  ConsumerState<ValidatePhoneScreen> createState() =>
      _ValidatePhoneScreenState();
}

class _ValidatePhoneScreenState extends ConsumerState<ValidatePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final String _selectedCountryCode = '+234';

  @override
  void initState() {
    super.initState();
    String storedPhone = widget.request.phoneNumber ?? '';
    if (storedPhone.startsWith(_selectedCountryCode)) {
      storedPhone = storedPhone.substring(_selectedCountryCode.length);
    }
    _phoneController.text = storedPhone;
  }

  Future<void> _validatePhone() async {
    if (_formKey.currentState!.validate()) {
      try {
        String inputPhone = _phoneController.text.trim();
        // Remove leading zero if user typed it
        if (inputPhone.startsWith('0')) {
          inputPhone = inputPhone.substring(1);
        }
        final formattedPhone = '$_selectedCountryCode$inputPhone';

        await ref.read(userNotifierProvider.notifier).validatePhone(
            PhoneNumberRequest(phoneNumber: formattedPhone));

        final userState = ref.read(userNotifierProvider);

        if (userState.isDataAvailable && mounted) {
          final updatedRequest =
              widget.request.copyWith(phoneNumber: formattedPhone);
          
          // Save draft locally
          await SessionService.saveSignUpDraft(updatedRequest);
          
          if (mounted) {
            context.push('/verify-phone', extra: updatedRequest);
          }
        } else if (mounted) {
          AppMessenger.show(
            context,
            type: MessageType.error,
            message:
                userState.message ?? 'Unable to validate your phone number',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter Your Phone Number',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your active phone number to verify and authenticate your account',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 48),

                // Phone Number Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phone Number',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Country Code Selector
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇳🇬',
                                  style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                _selectedCountryCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Phone Number Field
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: '0000000000',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: appTheme.primaryColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (value.length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Terms and Conditions
                const TermsAndConditionsWidget(),
                const SizedBox(height: 50),

                // Continue Button
                FullWidthButton(
                    text: 'Continue',
                    isLoading: userState.isInitialLoading,
                    onPressed: _validatePhone),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
