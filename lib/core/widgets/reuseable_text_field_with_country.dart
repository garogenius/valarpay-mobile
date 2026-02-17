import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valarpay/core/themes/color_utils.dart';

class ReuseableTextFieldWithCountry extends StatelessWidget {
  String? flagImagePath;
  String? countryCode;
  TextEditingController controller;
  Widget? suffixWidget;
  Widget? prefixWidget;
  int? maxLength;
  void Function(String)? onChanged;
  VoidCallback? onArrowTap;
  bool isReadOnly;
  String hintText;
  bool showCountryLabel;
  bool showArrow;
  bool isExpanded;
  TextInputType textInputType;
  List<TextInputFormatter>? inputFormatters;

  ReuseableTextFieldWithCountry({
    this.countryCode,
    this.flagImagePath,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onArrowTap,
    required this.isReadOnly,
    required this.textInputType,
    this.suffixWidget,
    this.prefixWidget,
    required this.showCountryLabel,
    this.showArrow = false,
    this.isExpanded = false,
    this.maxLength,
    this.inputFormatters,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Country Code Selector
        if (showCountryLabel)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.grey.shade300),
              color: Theme.of(context).cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇳🇬', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                if (countryCode != null)
                  Text(countryCode ?? '', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        if (showCountryLabel) const SizedBox(width: 12),

        // Phone Number Field (takes the rest of the space)
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: textInputType,
            readOnly: isReadOnly,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              counterText: '',
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showArrow)
                    IconButton(
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: onArrowTap,
                    ),
                  if (suffixWidget != null) suffixWidget!,
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: appTheme.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 18,
              ),
              prefixIcon: prefixWidget,
              filled: true,
              fillColor: Theme.of(context).cardColor.withOpacity(0.5),
            ),
            validator: (value) {},
            onChanged: onChanged,
          ),
        ),
      ],
    );

    // Row(
    //   children: [
    //     if (showCountryLabel)
    //       Container(
    //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    //         decoration: BoxDecoration(
    //           color: Theme.of(context).cardColor.withOpacity(0.5),
    //           borderRadius: BorderRadius.circular(8),
    //         ),
    //         child: Row(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             if (flagImagePath != null)
    //               Container(
    //                 width: 24,
    //                 height: 16,
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(2),
    //                 ),
    //                 child: Image.asset(flagImagePath ?? '', fit: BoxFit.cover),
    //               ),
    //             const SizedBox(width: 8),
    //             if (countryCode != null)
    //               Text(
    //                 countryCode ?? '',
    //                 style: const TextStyle(
    //                   fontSize: 16,
    //                 ),
    //               ),
    //           ],
    //         ),
    //       ),
    //     if (showCountryLabel) const SizedBox(width: 12),
    //     Expanded(
    //       child: Container(
    //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    //         decoration: BoxDecoration(
    //           color: Theme.of(context).cardColor.withOpacity(0.5),
    //           borderRadius: BorderRadius.circular(8),
    //         ),
    //         child: Row(
    //           children: [
    //             Expanded(
    //               child: TextField(
    //                 controller: controller,
    //                 keyboardType: textInputType,
    //                 readOnly: isReadOnly,
    //                 onChanged: onChanged,
    //                 style:
    //                     TextStyle(color: isDark ? Colors.white : Colors.black),
    //                 decoration: InputDecoration(
    //                   hintText: hintText,
    //                   hintStyle: TextStyle(
    //                       color: isDark ? Colors.white38 : Colors.grey[400]),
    //                   filled: true,
    //                   fillColor: Colors.transparent,
    //                   border: OutlineInputBorder(
    //                     borderRadius: BorderRadius.circular(8),
    //                     borderSide: BorderSide.none,
    //                   ),
    //                   contentPadding: const EdgeInsets.symmetric(
    //                     horizontal: 16,
    //                     vertical: 14,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             if (suffixWidget != null)
    //               Padding(
    //                 padding: const EdgeInsets.only(right: 8),
    //                 child: suffixWidget,
    //               ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
