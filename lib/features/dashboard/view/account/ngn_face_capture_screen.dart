import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/connectivity_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/smart_selfie_widget.dart';
import 'package:valarpay/features/notifiers/wallet_notifier.dart';
import 'package:valarpay/features/notifiers/account_creation_status_provider.dart';

class NgnFaceCaptureScreen extends ConsumerStatefulWidget {
  final String docType;
  final String docNumber;
  
  const NgnFaceCaptureScreen({
    required this.docType,
    required this.docNumber,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<NgnFaceCaptureScreen> createState() => _NgnFaceCaptureScreenState();
}

class _NgnFaceCaptureScreenState extends ConsumerState<NgnFaceCaptureScreen> {
  bool _isLoading = false;

  Future<bool> _submitNgnAccountCreation(String base64Selfie, List<String> base64Liveness) async {
    try {
      setState(() => _isLoading = true);

      final success = await ref
          .read(walletNotifierProvider.notifier)
          .openNgnAccount(
            docType: widget.docType.toLowerCase(),
            docNumber: widget.docNumber,
            selfieImage: base64Selfie,
            livenessImages: base64Liveness,
          );

      if (success) {
        if (!mounted) return false;
        
        AppMessenger.show(
          context,
          type: MessageType.success,
          message: 'NGN Account created successfully!',
        );

        if (mounted) {
           Navigator.pop(context); // Remove camera screen
           
           ref.read(accountCreationProcessingProvider.notifier).state = true;
           
           final rootContext = ConnectivityService.navigatorKey.currentContext;
           if (rootContext != null) {
              _showSuccessDialogOnContext(rootContext);
           }
        }
        return true;
      } else {
        if (!mounted) return false;
        AppMessenger.show(
          context, 
          type: MessageType.error, 
          message: ref.read(walletNotifierProvider).message ?? 'Account creation failed. Please try again.'
        );
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Account creation failed: ${e.toString()}',
      );
      return false;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                  Icons.hourglass_empty,
                  size: 50,
                  color: Color(0xFFF76301),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification in Progress',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your account opening request is being processed. We will notify you of the status shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/dashboard');
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
          return await _submitNgnAccountCreation(selfie, liveness);
        },
      ),
    );
  }
}
