import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/features/models/user.dart';
import 'package:valarpay/features/models/user_tier.dart';
import 'package:intl/intl.dart';

class Tier1Card extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final UserModel? user;
  final TierInfo? tierInfo;

  const Tier1Card({
    Key? key,
    this.isExpanded = true,
    required this.onToggle,
    this.user,
    this.tierInfo,
  }) : super(key: key);

  @override
  State<Tier1Card> createState() => _Tier1CardState();
}

class _Tier1CardState extends State<Tier1Card> {
  @override
  Widget build(BuildContext context) {
    final isBvnVerified = widget.user?.isBvnVerified ?? false;
    final nationality = widget.user?.country ?? 'Not Set';

    return Container(
      width: 335.w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              width: 335.w,
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF76301),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tier 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Requirements Section (always visible)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requirements',
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : const Color(0xFF9CA3AF),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 12.h),

                   // Requirements Row(s)
                  if (widget.tierInfo != null)
                    ...widget.tierInfo!.requirements.map((req) {
                      bool isVerified = false;
                      if (req.toLowerCase().contains('identity') && (isBvnVerified || (widget.user?.isNinVerified ?? false))) isVerified = true;
                      if (req.toLowerCase().contains('basic information') && (widget.user?.fullname != null)) isVerified = true;
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              req,
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              isVerified ? Icons.check_circle : Icons.cancel,
                              color: isVerified ? Colors.green : Colors.red,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  else ...[
                    // Fallback to BVN if tierInfo is null
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Identity',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF111827),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              (isBvnVerified || (widget.user?.isNinVerified ?? false)) ? Icons.check_circle : Icons.cancel,
                              color: (isBvnVerified || (widget.user?.isNinVerified ?? false)) ? Colors.green : Colors.red,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              (isBvnVerified || (widget.user?.isNinVerified ?? false)) ? 'Verified' : 'Not Verified',
                              style: TextStyle(
                                color: (isBvnVerified || (widget.user?.isNinVerified ?? false)) ? Colors.green : Colors.red,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],

                  // Nationality Row (keep as it's useful but maybe not in API requirements)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nationality',
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        nationality,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Limits Section (shown when expanded)
          if (widget.isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashed Line
                  Container(
                    width: 295.w,
                    height: 2.h,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[600]!
                                  : const Color(0xFF111827),
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: CustomPaint(
                      painter: DashedLinePainter(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[600]!
                                : const Color(0xFF111827),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                   // Limits Section - Two Columns
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column - Credit Limits
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Transaction Limit',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[400]
                                        : const Color(0xFF9CA3AF),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.tierInfo?.dailyTransactionLimit != null
                                  ? '₦${NumberFormat('#,###.00').format(widget.tierInfo!.dailyTransactionLimit)}'
                                  : 'Unlimited',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Column - Debit Limits (Balance Limit)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Maximum Balance',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[400]
                                        : const Color(0xFF9CA3AF),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.tierInfo?.balanceLimit != null
                                  ? '₦${NumberFormat('#,###.00').format(widget.tierInfo!.balanceLimit)}'
                                  : 'Unlimited',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            SizedBox(height: 12.h), // Add spacing when collapsed
        ],
      ),
    );
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({this.color = const Color(0xFF111827)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
