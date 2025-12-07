import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/dashboard/view/home/homescreen.dart';
import 'package:valarpay/features/models/login.dart';
import 'package:valarpay/features/models/set_wallet_pin_request.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../../../../controller/pin_controller.dart';
import '../../widgets/Kyc/Dialog/passcode_success.dart';

class ConfirmTransactionPinPage extends ConsumerStatefulWidget {
  const ConfirmTransactionPinPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConfirmTransactionPinPage> createState() =>
      _ConfirmTransactionPinPageState();
}

class _ConfirmTransactionPinPageState
    extends ConsumerState<ConfirmTransactionPinPage> {
  Future<void> _createPin(
    BuildContext context,
    WidgetRef ref,
    String pin,
    String? errorMessage,
  ) async {
    try {
      final request = SetWalletPinRequest(pin: pin);
      final response = await ref
          .read(userNotifierProvider.notifier)
          .setWalletPin(request);

      if (response != null) {
        await ref.read(pinControllerProvider.notifier).savePinSecurely(pin);

        if (context.mounted) {
          _showSuccessDialog(context, ref);
        }
      } else {
        if (context.mounted) {
          AppMessenger.show(
            context,
            message: errorMessage ?? 'Failed to save PIN',
            type: MessageType.error,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppMessenger.show(
          context,
          message: 'An unexpected error occurred: $e',
          type: MessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinControllerProvider);
    final userState = ref.watch(userNotifierProvider);
    final pinNotifier = ref.read(pinControllerProvider.notifier);
    final isFormValid = pinNotifier.isConfirmPinValid();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Confirm Your Transaction Pin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Re-enter your 4-digit PIN to always authorize and secure every transaction',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontFamily: 'SF Pro',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
            const SizedBox(height: 40),

            /// ✅ PIN Input Boxes (safe deferred update)
            PinFieldAutoFill(
              codeLength: 4,
              currentCode: pinState.confirmPin,
              decoration: BoxLooseDecoration(
                gapSpace: 12,
                strokeColorBuilder: FixedColorBuilder(Colors.grey.shade400),
                bgColorBuilder: FixedColorBuilder(
                  Colors.grey.shade50.withOpacity(0.8),
                ),
                radius: const Radius.circular(8),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                strokeWidth: 1.4,
              ),
              onCodeChanged: (code) {
                if (code != null && code.length <= 4) {
                  Future.microtask(() {
                    pinNotifier.updateConfirmPin(code);
                  });
                }
              },
            ),

            const SizedBox(height: 40),
            FullWidthButton(
              text: 'Continue',
              isEnabled: isFormValid,
              isLoading: userState.isInitialLoading,
              onPressed:
                  isFormValid
                      ? () async {
                        pinNotifier.submitConfirmPin(
                          context,
                          onSuccess: () async {
                            await _createPin(
                              context,
                              ref,
                              pinState.pin,
                              userState.message,
                            );
                          },
                          onError: () {
                            _showPinMismatchDialog(context, ref);
                          },
                        );
                      }
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PasscodeSuccessDialog(
          headerText: 'Pin',
          onDone: () async {
            try {
              // Step 1: Clear pins from memory
              ref.read(pinControllerProvider.notifier).clearAllPins();

              // Step 2: Refresh user profile and update state
              final updatedUser =
                  await ref
                      .read(userNotifierProvider.notifier)
                      .refreshUserProfile();

              if (updatedUser != null) {
                ref.read(userProvider.notifier).setUser(updatedUser);

                final currentToken = await SessionService.getAccessToken();
                if (currentToken != null) {
                  await SessionService.saveSession(
                    LoginResponse(
                      user: updatedUser,
                      accessToken: currentToken,
                      message: 'Success',
                      statusCode: 200,
                    ),
                  );
                }
              }

              // Step 3: Close dialog first
              if (mounted) {
                Navigator.of(dialogContext, rootNavigator: true).pop();

                // Step 4: Navigate to home immediately after closing dialog
                // Use the parent context (from the widget state, not dialog)
                context.pushReplacement('/');
              }
            } catch (e) {
              if (mounted) {
                Navigator.of(dialogContext, rootNavigator: true).pop();
                AppMessenger.show(
                  context,
                  message: 'Error completing PIN setup: $e',
                  type: MessageType.error,
                );
              }
            }
          },
        );
      },
    );
  }

  void _showPinMismatchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PINs do not match. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontFamily: 'SF Pro',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF76301),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ref
                                .read(pinControllerProvider.notifier)
                                .clearConfirmPin();
                          },
                          child: const Text(
                            'Try Again',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
