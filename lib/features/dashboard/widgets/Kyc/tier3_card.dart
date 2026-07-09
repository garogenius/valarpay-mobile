import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/dashboard/view/KYC/proof_of_address.dart';
import 'package:valarpay/features/models/kyc_address_request.dart';
import 'package:valarpay/features/models/user.dart';
import 'package:valarpay/features/models/user_tier.dart';
import 'package:intl/intl.dart';

class Tier3Card extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isNinVerified;
  final bool isAddressSubmitted;
  final bool isTier2OrHigher;
  final UserModel? user;
  final TierInfo? tierInfo;

  const Tier3Card({
    Key? key,
    this.isExpanded = false,
    required this.onToggle,
    this.isNinVerified = false,
    this.isAddressSubmitted = false,
    this.isTier2OrHigher = false,
    this.user,
    this.tierInfo,
  }) : super(key: key);

  @override
  State<Tier3Card> createState() => _Tier3CardState();
}

class _Tier3CardState extends State<Tier3Card> {
  @override
  Widget build(BuildContext context) {
    final nin = widget.user?.nin;
    final address = widget.user?.address;
    final city = widget.user?.city;
    final state = widget.user?.state;

    // Format address display
    String formattedAddress = 'Not Set';
    if (address != null && address.isNotEmpty) {
      final parts = <String>[];
      parts.add(address);
      if (city != null && city.isNotEmpty) parts.add(city);
      if (state != null && state.isNotEmpty) parts.add(state);
      formattedAddress = parts.join(', ');
    }

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
          // View Review Progress Button (shown when address is submitted)
          if (widget.isAddressSubmitted)
            GestureDetector(
              onTap: () {
                // Navigate to review progress page
                context.push('/kyc-review-progress');
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4ED),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'View Review Progress',
                      style: TextStyle(
                        color: const Color(0xFFF76301),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          color: const Color(0xFFF76301),
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

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
                    onTap: widget.isTier2OrHigher && !widget.isAddressSubmitted
                        ? () {
                            // Directly navigate to document upload for Tier 3 review
                            final request = const KycAddressRequest();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => 
                                    ProofOfAddressPage(addressRequest: request),
                              ),
                            );
                          }
                        : null,
                    child: Row(
                      children: [
                        Text(
                          widget.isAddressSubmitted 
                              ? 'Tier 3' 
                              : 'Upgrade to Tier 3',
                          style: TextStyle(
                            color: widget.isTier2OrHigher && !widget.isAddressSubmitted
                                ? const Color(0xFFF76301)
                                : const Color(0xFF9CA3AF),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.isTier2OrHigher && !widget.isAddressSubmitted) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: const Color(0xFFF76301),
                            size: 14.sp,
                          ),
                        ],
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
                  SizedBox(height: 12.h),                   // Requirements Row(s)
                  if (widget.tierInfo != null)
                    ...widget.tierInfo!.requirements.map((req) {
                      bool isVerified = false;
                      // Logic to determine if requirement is met
                      if (req.toLowerCase().contains('nin') && widget.isNinVerified) isVerified = true;
                      if (req.toLowerCase().contains('address') && widget.isAddressSubmitted) isVerified = true;
                      if (req.toLowerCase().contains('bvn') && (widget.user?.isBvnVerified ?? false)) isVerified = true;
                      if (req.toLowerCase().contains('statement') && (widget.user?.bankStatementUrl != null)) isVerified = true;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                req,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF111827),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
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
                    // Fallback requirements if tierInfo is null
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NIN',
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
                            if (nin != null && nin.isNotEmpty) ...[
                              Text(
                                '***${nin.substring(nin.length - 4)}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[400]
                                          : const Color(0xFF6B7280),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 8.w),
                            ],
                            Icon(
                              widget.isNinVerified
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  widget.isNinVerified
                                      ? Colors.green
                                      : Colors.red,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Address Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Address',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              widget.isAddressSubmitted
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  widget.isAddressSubmitted
                                      ? Colors.green
                                      : Colors.red,
                              size: 16.sp,
                            ),
                          ],
                        ),
                        if (address != null && address.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            formattedAddress,
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[400]
                                      : const Color(0xFF6B7280),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
                  SizedBox(height: 16.h),                   // Limits Section - Two Columns
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
