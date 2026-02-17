import 'package:flutter/material.dart';

class ProfileRowItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isClickable;
  final VoidCallback? onTap;

  const ProfileRowItem({
    super.key,
    required this.label,
    required this.value,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(width: 16),

            // Value and arrow
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isClickable) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
