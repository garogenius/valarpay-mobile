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
import 'package:valarpay/features/notifiers/wallet_notifier.dart';
import 'package:valarpay/features/models/nin_verification_request.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class NinIdentityVerificationPage extends ConsumerStatefulWidget {
  final String nin;
  final String? docType;
  final bool isTierUpgrade;
  const NinIdentityVerificationPage({required this.nin, this.docType, this.isTierUpgrade = false, Key? key})
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

      bool isSuccess = false;
      String errorMessage = 'Verification failed. Please try again.';

      if (widget.isTierUpgrade) {
        log("🔍 Submitting Tier 2 Upgrade (liveness check)...");
        final request = NinVerificationRequest(
          nin: widget.nin,
          docType: widget.docType,
          selfieImage: base64Selfie,
          livenessImages: base64Liveness,
        );
        final res = await ref.read(userNotifierProvider.notifier).verifyNinTier2(request);
        isSuccess = res?.isSuccess ?? false;
        if (!isSuccess) {
          errorMessage = res?.message ?? errorMessage;
        }
      } else {
        log("🔍 Submitting Account Creation (liveness check)...");
        // Call the correct SmileID biometric endpoint for account creation
        isSuccess = await ref
            .read(walletNotifierProvider.notifier)
            .openNgnAccount(
              docType: (widget.docType ?? 'nin').toLowerCase(),
              docNumber: widget.nin,
              selfieImage: base64Selfie,
              livenessImages: base64Liveness,
            );
        if (!isSuccess) {
          errorMessage = ref.read(walletNotifierProvider).message ?? errorMessage;
        }
      }

      if (isSuccess) {
        log("✅ Smart Selfie Registration successful!");

        // Refresh user profile to get updated tier/verification status
        await ref.read(userNotifierProvider.notifier).refreshUserProfile();

        final user = ref.read(userProvider);
        String? newAccountNumber;
        String? newBankName;
        if (!widget.isTierUpgrade && user != null && user.wallets.isNotEmpty) {
           try {
              final ngnWallet = user.wallets.firstWhere((w) => w.currency == 'NGN');
              newAccountNumber = ngnWallet.accountNumber;
              newBankName = ngnWallet.bankName;
           } catch (_) {
              newAccountNumber = user.wallets.first.accountNumber;
              newBankName = user.wallets.first.bankName;
           }
        }

        if (!mounted) return false;

        // Close the camera screen first so the dialog appears on the previous screen
        if (mounted) {
           Navigator.pop(context); // This removes NinIdentityVerificationPage
           
           // Use the root navigator context to ensure the dialog stays visible after the pop
           final rootContext = ConnectivityService.navigatorKey.currentContext;
           if (rootContext != null) {
              _showSuccessDialogOnContext(rootContext, accountNumber: newAccountNumber, bankName: newBankName);
           } else {
              _showSuccessDialog(accountNumber: newAccountNumber, bankName: newBankName); // Fallback
           }
        }
        return true;
      } else {
        log("❌ Smart Selfie Registration failed: $errorMessage");

        if (!mounted) return false;

        // Close the camera screen so the user can see the previous screen while they interact with the failure modal
        Navigator.pop(context);
        
        final rootContext = ConnectivityService.navigatorKey.currentContext;
        if (rootContext != null) {
          _showFailureDialogOnContext(rootContext, errorMessage);
        } else {
          _showFailureDialog(errorMessage);
        }
        return false;
      }
    } catch (e, stackTrace) {
      log("❌ Exception during verification: $e");
      log("Stack trace: $stackTrace");

      if (!mounted) return false;

      Navigator.pop(context);
      
      final rootContext = ConnectivityService.navigatorKey.currentContext;
      if (rootContext != null) {
        _showFailureDialogOnContext(rootContext, 'Verification failed: ${e.toString()}');
      } else {
        _showFailureDialog('Verification failed: ${e.toString()}');
      }
      return false;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog({String? accountNumber, String? bankName}) => _showSuccessDialogOnContext(context, accountNumber: accountNumber, bankName: bankName);

  void _showSuccessDialogOnContext(BuildContext ctx, {String? accountNumber, String? bankName}) {
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
              if (accountNumber != null && bankName != null) ...[
                Text(
                  'Your account has been successfully created. Here are your account details:',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Account Number:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          Text(accountNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bank Name:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          Text(bankName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Text(
                  'Your account has been successfully verified. You can now access all features and enjoy secure transactions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
              ],
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

  void _showFailureDialog(String errorMessage) => _showFailureDialogOnContext(context, errorMessage);

  void _showFailureDialogOnContext(BuildContext ctx, String errorMessage) {
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
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification Failed',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
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
