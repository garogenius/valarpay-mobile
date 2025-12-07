import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final List<TextInputFormatter>? inputFormatters;

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
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ResponsiveUtils.bodyMedium.copyWith(color: Colors.black),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: inputFormatters,
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
// Basic text field
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

// Password field with visibility toggle
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

// Multi-line text field
ResponsiveTextField(
  controller: _addressController,
  label: 'Address',
  hint: 'Enter your address',
  maxLines: 3,
)

// Numbers only with max length
ResponsiveTextField(
  controller: _phoneController,
  label: 'Phone Number',
  hint: 'Enter phone number',
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(11),
  ],
)

// Uppercase text only
ResponsiveTextField(
  controller: _codeController,
  label: 'Promo Code',
  hint: 'Enter code',
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
    TextInputFormatter.withFunction((oldValue, newValue) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    }),
  ],
)

// Amount field (numbers and decimal point only)
ResponsiveTextField(
  controller: _amountController,
  label: 'Amount',
  hint: '0.00',
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
  ],
)
*/
