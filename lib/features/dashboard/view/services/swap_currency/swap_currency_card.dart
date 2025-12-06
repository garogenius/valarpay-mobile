import 'package:flutter/material.dart';

class CurrencyAmountInput extends StatelessWidget {
  final String label; // e.g. "I have"
  final TextEditingController controller;
  final String currencyCode; // e.g. "NGN"
  final String currencySymbol; // e.g. "#"
  final String flagAsset;
  final bool isEditable;
  final VoidCallback onCurrencyTap;

  const CurrencyAmountInput({
    super.key,
    required this.label,
    required this.controller,
    required this.currencyCode,
    required this.currencySymbol,
    required this.flagAsset,
    required this.onCurrencyTap,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// LEFT SIDE (LABEL + INPUT)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currencySymbol,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(width: 4),

                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      enabled: isEditable,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : Colors.grey[400],
                          fontSize: 24,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          /// RIGHT SIDE (FLAG + CODE)
          GestureDetector(
            onTap: onCurrencyTap,
            child: Row(
              children: [
                Image.asset(
                  flagAsset,
                  width: 28,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  currencyCode,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
