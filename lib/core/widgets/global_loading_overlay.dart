import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class GlobalLoadingOverlay extends ConsumerWidget {
  final Widget child;

  const GlobalLoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        (reportScamState.isInitialLoading && !reportScamState.isOverlayHidden);

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.6),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const SweepGradient(
                          colors: [
                            appTheme.primaryColor,
                            Colors.orangeAccent,
                            Colors.white,
                            appTheme.primaryColor,
                          ],
                          stops: [0.0, 0.5, 0.75, 1.0],
                          tileMode: TileMode.repeated,
                        ).createShader(bounds);
                      },
                      child: CircularProgressIndicator(
                        strokeWidth: 8,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
