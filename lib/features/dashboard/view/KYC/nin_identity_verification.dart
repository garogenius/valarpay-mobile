import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/connectivity_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/smart_selfie_widget.dart';
import 'package:valarpay/features/dashboard/view/KYC/setup_pin.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class NinIdentityVerificationPage extends ConsumerStatefulWidget {
  final String nin;
  const NinIdentityVerificationPage({required this.nin, Key? key})
    : super(key: key);

  @override
  ConsumerState<NinIdentityVerificationPage> createState() =>
      _NinIdentityVerificationPageState();
}

class _NinIdentityVerificationPageState
    extends ConsumerState<NinIdentityVerificationPage> {
  bool _isLoading = false;

  Future<bool> _submitNinVerification(String base64Selfie, List<String> base64Liveness) async {
    try {
      setState(() => _isLoading = true);

      log("🔍 Step 2: Submitting Smart Selfie Registration (liveness check)...");

      // The images are already raw base64 from the smart selfie widget
      // Just pass them directly — the endpoint expects plain base64 strings
      log("✅ Selfie length: ${base64Selfie.length}, Liveness frames: ${base64Liveness.length}");

      // Call the correct SmileID biometric endpoint
      final response = await ref
          .read(userNotifierProvider.notifier)
          .submitSmartSelfieRegister(
            selfieImage: base64Selfie,
            livenessImages: base64Liveness,
          );

      log("📥 SmileID Response:");
      log("   - Status Code: ${response?.statusCode}");
      log("   - Message: ${response?.message}");

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        log("✅ Smart Selfie Registration successful!");

        // Refresh user profile to get updated tier/verification status
        await ref.read(userNotifierProvider.notifier).refreshUserProfile();

        if (!mounted) return false;

        AppMessenger.show(
          context,
          type: MessageType.success,
          message: response.message ?? 'Verification submitted successfully!',
        );

        // Close the camera screen first so the dialog appears on the previous screen
        if (mounted) {
           Navigator.pop(context); // This removes NinIdentityVerificationPage
           
           // Use the root navigator context to ensure the dialog stays visible after the pop
           final rootContext = ConnectivityService.navigatorKey.currentContext;
           if (rootContext != null) {
              _showSuccessDialogOnContext(rootContext);
           } else {
              _showSuccessDialog(); // Fallback
           }
        }
        return true;
      } else {
        final errorMsg = response?.message ?? 'Verification failed. Please try again.';
        log("❌ Smart Selfie Registration failed: $errorMsg");

        if (!mounted) return false;

        AppMessenger.show(context, type: MessageType.error, message: errorMsg);
        return false;
      }
    } catch (e, stackTrace) {
      log("❌ Exception during verification: $e");
      log("Stack trace: $stackTrace");

      if (!mounted) return false;

      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Verification failed: ${e.toString()}',
      );
      return false;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() => _showSuccessDialogOnContext(context);

  void _showSuccessDialogOnContext(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF76301).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Color(0xFFF76301),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Registration Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your account has been successfully verified. You can now access all features and enjoy secure transactions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Use context.go to clear all paths and go home
                    // Since it's a success, we clear everything
                    context.go('/setup-pin');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF76301),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SmartSelfieWidget(
        onComplete: (selfie, liveness) async {
          return await _submitNinVerification(selfie, liveness);
        },
      ),
    );
  }
}
