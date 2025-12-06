import 'package:flutter/material.dart';

import '../utils/responsive_utils.dart';
import 'package:valarpay/core/utils/color_utils.dart';

class ResponsiveTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final VoidCallback? onToggleVisibility;
  final bool hasError;
  final String? errorText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  const ResponsiveTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onToggleVisibility,
    this.hasError = false,
    this.errorText,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ResponsiveUtils.bodyMedium.copyWith()),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ResponsiveUtils.bodyMedium.copyWith(
              color: Colors.grey.shade400,
            ),
            suffixIcon: _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: ResponsiveUtils.borderRadius8,
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: ResponsiveUtils.borderRadius8,
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ResponsiveUtils.borderRadius8,
              borderSide: BorderSide(
                color: hasError ? Colors.red : appTheme.primaryColor,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: ResponsiveUtils.borderRadius8,
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: ResponsiveUtils.borderRadius8,
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: ResponsiveUtils.paddingSymmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: maxLines > 1,
            fillColor: maxLines > 1 ? Colors.grey.shade50 : null,
          ),
        ),
        if (hasError && errorText != null) ...[
          SizedBox(height: ResponsiveUtils.spacing4),
          Text(
            errorText!,
            style: ResponsiveUtils.bodySmall.copyWith(color: Colors.red),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (onToggleVisibility != null) {
      return IconButton(
        onPressed: onToggleVisibility,
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
          size: ResponsiveUtils.iconSize20,
        ),
      );
    }
    return suffixIcon;
  }
}

// Usage examples:
/*
ResponsiveTextField(
  controller: _emailController,
  label: 'Email Address',
  hint: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    return null;
  },
)

ResponsiveTextField(
  controller: _passwordController,
  label: 'Password',
  hint: 'Enter your password',
  obscureText: _obscurePassword,
  onToggleVisibility: () => setState(() {
    _obscurePassword = !_obscurePassword;
  }),
  hasError: _hasPasswordError,
  errorText: 'Password is incorrect',
)

ResponsiveTextField(
  controller: _addressController,
  label: 'Address',
  hint: 'Enter your address',
  maxLines: 3,
)
*/
