import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/features/notifiers/airtime_notifier.dart';
import 'package:valarpay/features/notifiers/auth_notifier.dart';
import 'package:valarpay/features/notifiers/cable_notifier.dart';
import 'package:valarpay/features/notifiers/change_passcode_notifier.dart';
import 'package:valarpay/features/notifiers/change_password_notifier.dart';
import 'package:valarpay/features/notifiers/data_notifier.dart';
import 'package:valarpay/features/notifiers/electricity_notifier.dart';
import 'package:valarpay/features/notifiers/giftcard_notifier.dart';
import 'package:valarpay/features/notifiers/internet_notifier.dart';
import 'package:valarpay/features/notifiers/report_scam_notifier.dart';
import 'package:valarpay/features/notifiers/reset_pin_notifier.dart';
import 'package:valarpay/features/notifiers/transfer_notifier.dart';
import 'package:valarpay/features/notifiers/update_details_notifier.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/notifiers/betting_notifier.dart';
import 'package:valarpay/features/notifiers/education_notifier.dart';
import 'package:valarpay/features/notifiers/international_airtime_notifier.dart';
import 'package:valarpay/features/notifiers/savings_notifier.dart';
import 'package:valarpay/features/notifiers/easylife_notifier.dart';
import 'package:valarpay/features/notifiers/fixed_deposit_notifier.dart';
import 'package:valarpay/features/notifiers/investment_notifier.dart';

class GlobalLoadingOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalLoadingOverlay({super.key, required this.child});

  @override
  ConsumerState<GlobalLoadingOverlay> createState() =>
      _GlobalLoadingOverlayState();
}

class _GlobalLoadingOverlayState extends ConsumerState<GlobalLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Critical Flows
    final authState = ref.watch(authNotifierProvider);
    final userState = ref.watch(userNotifierProvider);
    final transferState = ref.watch(transferNotifierProvider);

    // Bill Payments & Purchases
    final airtimePurchaseState = ref.watch(airtimePurchaseNotifierProvider);
    final electricityPaymentState = ref.watch(
      electricityPaymentNotifierProvider,
    );
    final cablePaymentState = ref.watch(cablePaymentNotifierProvider);
    final dataPurchaseState = ref.watch(dataPurchaseNotifierProvider);
    final internetPaymentState = ref.watch(internetPaymentNotifierProvider);
    final giftCardState = ref.watch(giftCardNotifierProvider);

    // Settings & Security
    final changePasswordState = ref.watch(changePasswordNotifierProvider);
    final changePasscodeState = ref.watch(changePasscodeNotifierProvider);
    final resetPinState = ref.watch(resetPinNotifierProvider);
    final updateDetailsState = ref.watch(updateDetailsNotifierProvider);
    final reportScamState = ref.watch(reportScamNotifierProvider);

    // New additions
    final educationPurchaseState = ref.watch(educationPurchaseProvider);
    final internationalPurchaseState = ref.watch(internationalAirtimePurchaseProvider);
    final bettingPayState = ref.watch(bettingPayNotifierProvider);
    final savingsPlanState = ref.watch(savingsPlanNotifierProvider);
    final easyLifePlanState = ref.watch(easyLifePlanNotifierProvider);
    final fixedDepositState = ref.watch(fixedDepositNotifierProvider);
    final investmentActionState = ref.watch(investmentActionNotifierProvider);
    final investmentProductState = ref.watch(investmentProductNotifierProvider);
    final investmentListState = ref.watch(investmentListNotifierProvider);
    final investmentDetailsState = ref.watch(investmentDetailsNotifierProvider);

    // Verification and Plan Notifiers
    final educationVerifyState = ref.watch(educationVerificationProvider);
    final internationalPlanState = ref.watch(internationalAirtimePlanProvider);
    final internationalFxState = ref.watch(internationalFxRateProvider);

    // Initial Fetch Notifiers
    final internetPlansState = ref.watch(internetPlansNotifierProvider);
    final cablePlansState = ref.watch(cablePlansNotifierProvider);
    final cableVariationState = ref.watch(cableVariationNotifierProvider);
    final electricityState = ref.watch(electricityNotifierProvider);
    final electricityBillInfoState = ref.watch(electricityBillInfoNotifierProvider);
    final bettingPlatformsState = ref.watch(bettingPlatformsNotifierProvider);
    final schoolBillersState = ref.watch(schoolBillersProvider);
    final vendingProvidersState = ref.watch(vendingProvidersProvider);
    final internationalCountriesState = ref.watch(internationalCountriesProvider);

    final internetVariationState = ref.watch(internetVariationNotifierProvider);
    final internetBeneficiaryState = ref.watch(internetBeneficiaryNotifierProvider);
    final airtimeBeneficiaryState = ref.watch(airtimeBeneficiaryNotifierProvider);
    final dataBeneficiaryState = ref.watch(dataBeneficiaryNotifierProvider);
    final electricityBeneficiaryState = ref.watch(electricityBeneficiaryNotifierProvider);
    final cableBeneficiaryState = ref.watch(cableBeneficiaryNotifierProvider);
    final bettingBeneficiaryState = ref.watch(bettingBeneficiaryNotifierProvider);

    // Check if any of the critical notifiers are in initial loading state AND overlay is NOT hidden
    final isLoading =
        (authState.isInitialLoading && !authState.isOverlayHidden) ||
        (userState.isInitialLoading && !userState.isOverlayHidden) ||
        (transferState.isInitialLoading && !transferState.isOverlayHidden) ||
        (airtimePurchaseState.isInitialLoading &&
            !airtimePurchaseState.isOverlayHidden) ||
        (electricityPaymentState.isInitialLoading &&
            !electricityPaymentState.isOverlayHidden) ||
        (cablePaymentState.isInitialLoading &&
            !cablePaymentState.isOverlayHidden) ||
        (dataPurchaseState.isInitialLoading &&
            !dataPurchaseState.isOverlayHidden) ||
        (internetPaymentState.isInitialLoading &&
            !internetPaymentState.isOverlayHidden) ||
        (giftCardState.isInitialLoading && !giftCardState.isOverlayHidden) ||
        (changePasswordState.isInitialLoading &&
            !changePasswordState.isOverlayHidden) ||
        (changePasscodeState.isInitialLoading &&
            !changePasscodeState.isOverlayHidden) ||
        (resetPinState.isInitialLoading && !resetPinState.isOverlayHidden) ||
        (updateDetailsState.isInitialLoading &&
            !updateDetailsState.isOverlayHidden) ||
        (reportScamState.isInitialLoading && !reportScamState.isOverlayHidden) ||
        (educationPurchaseState.isInitialLoading && !educationPurchaseState.isOverlayHidden) ||
        (internationalPurchaseState.isInitialLoading && !internationalPurchaseState.isOverlayHidden) ||
        (bettingPayState.isInitialLoading && !bettingPayState.isOverlayHidden) ||
        (savingsPlanState.isInitialLoading && !savingsPlanState.isOverlayHidden) ||
        (easyLifePlanState.isInitialLoading && !easyLifePlanState.isOverlayHidden) ||
        (fixedDepositState.isInitialLoading && !fixedDepositState.isOverlayHidden) ||
        (investmentActionState.isInitialLoading && !investmentActionState.isOverlayHidden) ||
        (investmentProductState.isInitialLoading && !investmentProductState.isOverlayHidden) ||
        (investmentListState.isInitialLoading && !investmentListState.isOverlayHidden) ||
        (investmentDetailsState.isInitialLoading && !investmentDetailsState.isOverlayHidden) ||
        (educationVerifyState.isInitialLoading && !educationVerifyState.isOverlayHidden) ||
        (internationalPlanState.isInitialLoading && !internationalPlanState.isOverlayHidden) ||
        (internationalFxState.isInitialLoading && !internationalFxState.isOverlayHidden) ||
        (internetPlansState.isInitialLoading && !internetPlansState.isOverlayHidden) ||
        (cablePlansState.isInitialLoading && !cablePlansState.isOverlayHidden) ||
        (cableVariationState.isInitialLoading && !cableVariationState.isOverlayHidden) ||
        (electricityState.isInitialLoading && !electricityState.isOverlayHidden) ||
        (electricityBillInfoState.isInitialLoading && !electricityBillInfoState.isOverlayHidden) ||
        (bettingPlatformsState.isInitialLoading && !bettingPlatformsState.isOverlayHidden) ||
        (schoolBillersState.isInitialLoading && !schoolBillersState.isOverlayHidden) ||
        (vendingProvidersState.isInitialLoading && !vendingProvidersState.isOverlayHidden) ||
        (internationalCountriesState.isInitialLoading && !internationalCountriesState.isOverlayHidden) ||

        (internetVariationState.isInitialLoading && !internetVariationState.isOverlayHidden) ||
        (internetBeneficiaryState.isInitialLoading && !internetBeneficiaryState.isOverlayHidden) ||
        (airtimeBeneficiaryState.isInitialLoading && !airtimeBeneficiaryState.isOverlayHidden) ||
        (dataBeneficiaryState.isInitialLoading && !dataBeneficiaryState.isOverlayHidden) ||
        (electricityBeneficiaryState.isInitialLoading && !electricityBeneficiaryState.isOverlayHidden) ||
        (cableBeneficiaryState.isInitialLoading && !cableBeneficiaryState.isOverlayHidden) ||
        (bettingBeneficiaryState.isInitialLoading && !bettingBeneficiaryState.isOverlayHidden);

    return Stack(
      children: [
        widget.child,
        if (isLoading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Image.asset(
                'assets/gifs/valarpay.gif',
                width: 85.w,
                height: 85.h,
                fit: BoxFit.contain,
              ),
            ),
            // child:
            // Center(
            //   child: AnimatedBuilder(
            //     animation: _controller,
            //     builder: (context, child) {
            //       return Stack(
            //         alignment: Alignment.center,
            //         children: [
            //           // Outer ring - rotates clockwise
            //           Transform.rotate(
            //             angle: _controller.value * 2 * 3.14159,
            //             child: SizedBox(
            //               width: 120,
            //               height: 120,
            //               child: CustomPaint(
            //                 painter: _GradientArcPainter(
            //                   progress: _controller.value,
            //                   radius: 60,
            //                   strokeWidth: 6,
            //                   sweepAngle: 4.71239, // 270 degrees
            //                 ),
            //               ),
            //             ),
            //           ),
            //           // Inner ring - rotates counter-clockwise
            //           Transform.rotate(
            //             angle: -_controller.value * 2 * 3.14159,
            //             child: SizedBox(
            //               width: 90,
            //               height: 90,
            //               child: CustomPaint(
            //                 painter: _GradientArcPainter(
            //                   progress: _controller.value,
            //                   radius: 45,
            //                   strokeWidth: 5,
            //                   sweepAngle: 4.71239, // 270 degrees
            //                 ),
            //               ),
            //             ),
            //           ),
            //           // Pulsing logo in center
            //           Transform.scale(
            //             scale:
            //                 1.0 +
            //                 (0.05 * (0.5 - (_controller.value - 0.5).abs())),
            //             child: Container(
            //               width: 60,
            //               height: 60,
            //               decoration: BoxDecoration(
            //                 shape: BoxShape.circle,
            //                 color: Colors.white,
            //                 boxShadow: [
            //                   BoxShadow(
            //                     color: appTheme.primaryColor.withOpacity(0.2),
            //                     blurRadius: 15,
            //                     spreadRadius: 3,
            //                   ),
            //                 ],
            //               ),
            //               padding: const EdgeInsets.all(10),
            //               child: Image.asset(
            //                 'assets/images/logo.png',
            //                 fit: BoxFit.contain,
            //               ),
            //             ),
            //           ),
            //         ],
            //       );
            //     },
            //   ),
            // ),
          ),
      ],
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final double progress;
  final double radius;
  final double strokeWidth;
  final double sweepAngle;

  _GradientArcPainter({
    required this.progress,
    required this.radius,
    required this.strokeWidth,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw the gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      colors: [
        appTheme.primaryColor,
        appTheme.primaryColor.withOpacity(0.7),
        appTheme.primaryColor.withOpacity(0.3),
        appTheme.primaryColor.withOpacity(0.0),
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final paint =
        Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    // Draw arc with gap (not a complete circle)
    canvas.drawArc(
      rect,
      -3.14159 / 2, // Start from top
      sweepAngle, // Sweep angle (270 degrees = 4.71239 radians)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.sweepAngle != sweepAngle;
  }
}
