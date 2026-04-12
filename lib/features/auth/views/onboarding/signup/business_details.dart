import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/terms_and_conditions_widget.dart';
import 'package:valarpay/features/models/signup_request.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

import '../../../../models/user_availablity_request.dart';

class BusinessDetailsScreen extends ConsumerStatefulWidget {
  final SignUpRequest request;
  const BusinessDetailsScreen({required this.request, super.key});

  @override
  ConsumerState<BusinessDetailsScreen> createState() =>
      _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  // final _dobController = TextEditingController();
  final _referralController = TextEditingController();
  bool _isRegistered = true;
  String? _cacDocumentPath;
  final ImagePicker _picker = ImagePicker();

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
            type: MessageType.success,
            message: userState.message ?? ' User already exist',
          );
        } else {
          final updatedRequest = widget.request.copyWith(
            fullname: _businessNameController.text.toString().trim(),
            username: _usernameController.text,
            dateOfBirth: _dateOfBirthController.text,
            referralCode: _referralController.text,
            businessName: _businessNameController.text,
            companyRegistrationNumber:
                _isRegistered ? _registrationNumberController.text : "",
            cacDocumentPath: _cacDocumentPath,
          );
          context.push('/security-details', extra: updatedRequest);
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

    return Scaffold(
      // backgroundColor: appTheme.whiteColor,
      appBar: AppBar(
        // backgroundColor: appTheme.whiteColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => GoRouter.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your company information for account creation',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Business Name
                        _buildTextField(
                          controller: _businessNameController,
                          label: 'Business Name',
                          hint: 'Enter your business name',
                        ),
                        const SizedBox(height: 16),

                        // Username
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: 'Enter username',
                        ),
                        const SizedBox(height: 16),

                        // Date Of Birth
                        _buildDateField(
                          controller: _dateOfBirthController,
                          label: 'Establishment Date',
                          hint: 'DD-MM-YYYY',
                        ),
                        const SizedBox(height: 24),

                        // Is Your Business Registered?
                        const Text(
                          'Is your Business Registered?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _isRegistered,
                              onChanged: (value) {
                                setState(() {
                                  _isRegistered = value!;
                                });
                              },
                              activeColor: appTheme.primaryColor,
                            ),
                            const Text('Yes'),
                            const SizedBox(width: 24),
                            Radio<bool>(
                              value: false,
                              groupValue: _isRegistered,
                              onChanged: (value) {
                                setState(() {
                                  _isRegistered = value!;
                                });
                              },
                              activeColor: appTheme.primaryColor,
                            ),
                            const Text('No'),
                          ],
                        ),

                        if (_isRegistered) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _registrationNumberController,
                            label: 'Business Registration Number',
                            hint: 'Enter registration number',
                            obscureText: true,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Upload CAC Document',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildFileUploadSection(),
                        ],
                        const SizedBox(height: 16),
                        // Referral Code
                        _buildTextField(
                          controller: _referralController,
                          label: 'Referral Code (Optional)',
                          hint: 'Enter referral code',
                          isRequired: false,
                        ),

                        const SizedBox(height: 24),

                        // Bottom button and terms
                        const SizedBox(height: 24),
                        FullWidthButton(
                          text: 'Continue',
                          isLoading: userState.isInitialLoading,
                          onPressed: _checkUserAvailablity,
                        ),
                        const SizedBox(height: 16),
                        TermsAndConditionsWidget(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool obscureText = false,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appTheme.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty && isRequired == true) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appTheme.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.text =
                  '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _usernameController.dispose();
    _dateOfBirthController.dispose();
    _registrationNumberController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Widget _buildFileUploadSection() {
    return GestureDetector(
      onTap: _pickCacDocument,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: _cacDocumentPath == null
            ? Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to upload CAC document',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG or PDF (Max 5MB)',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.description, color: appTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _cacDocumentPath!.split('/').last,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => setState(() => _cacDocumentPath = null),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickCacDocument() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file != null) {
        setState(() {
          _cacDocumentPath = file.path;
        });
      }
    } catch (e) {
      AppMessenger.show(context, message: 'Failed to pick image: $e', type: MessageType.error);
    }
  }
}
