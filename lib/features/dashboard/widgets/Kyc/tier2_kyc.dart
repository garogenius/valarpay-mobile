import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/features/dashboard/view/KYC/NIN.dart';
import 'package:valarpay/features/dashboard/view/KYC/BVN.dart' as valarpay_bvn;
import 'package:valarpay/features/models/user.dart';
import 'package:valarpay/features/models/user_tier.dart';
import 'package:intl/intl.dart';

class Tier2Card extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final UserModel? user;
  final TierInfo? tierInfo;

  const Tier2Card({
    Key? key,
    this.isExpanded = false,
    required this.onToggle,
    this.user,
    this.tierInfo,
  }) : super(key: key);

  @override
  State<Tier2Card> createState() => _Tier2CardState();
}

class _Tier2CardState extends State<Tier2Card> {
  @override
  Widget build(BuildContext context) {
    final nin = widget.user?.nin;
    final isNinVerified = widget.user?.isNinVerified ?? false;

    return Container(
      width: 335.w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: const Color(0xFFFFEEE3), width: 6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Clickable upgrade text
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      bool isBvnVerified = widget.user?.isBvnVerified ?? false;
                      if (isBvnVerified && isNinVerified) return;

                      if (isBvnVerified && !isNinVerified) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NINPage(isTierUpgrade: true),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const valarpay_bvn.BVNPage(isTierUpgrade: true),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          (() {
                            bool isBvnVerified = widget.user?.isBvnVerified ?? false;
                            bool bothVerified = isBvnVerified && isNinVerified;
                            return bothVerified ? 'Tier 2' : 'Upgrade to Tier 2';
                          })(),
                          style: TextStyle(
                            color: (() {
                              bool isBvnVerified = widget.user?.isBvnVerified ?? false;
                              bool bothVerified = isBvnVerified && isNinVerified;
                              return bothVerified
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFFF76301);
                            })(),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            bool isBvnVerified = widget.user?.isBvnVerified ?? false;
                            bool bothVerified = isBvnVerified && isNinVerified;
                            
                            if (!bothVerified) {
                              return Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: const Color(0xFFF76301),
                                  size: 14.sp,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Clickable dropdown icon
                GestureDetector(
                  onTap: widget.onToggle,
                  child: Container(
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
                ),
              ],
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
                      bool isBvnVerified = widget.user?.isBvnVerified ?? false;
                      if (req.toLowerCase().contains('identity') && isBvnVerified && isNinVerified) isVerified = true;
                      
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
                    // Fallback to Identity if tierInfo is null
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Identity',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              (widget.user?.isBvnVerified ?? false) && isNinVerified ? Icons.check_circle : Icons.cancel,
                              color: (widget.user?.isBvnVerified ?? false) && isNinVerified ? Colors.green : Colors.red,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
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
                      // Left Column - Transaction Limits
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

                      // Right Column - Balance limits
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
