import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/services/connectivity_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/widgets/smart_selfie_widget.dart';
import 'package:valarpay/features/dashboard/view/KYC/setup_pin.dart';
import 'package:valarpay/features/models/bvn_verification_request.dart';
import 'package:valarpay/features/notifiers/wallet_notifier.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/core/services/smileid_socket_service.dart';
import '../../widgets/Kyc/Dialog/profile_setup_dialog.dart';
import 'package:valarpay/features/models/api_response.dart';
import 'kyc_step_provider.dart';

class IdentityVerificationPage extends ConsumerStatefulWidget {
  final BvnVerificationRequest request;
  const IdentityVerificationPage({required this.request, Key? key}) : super(key: key);

  @override
  ConsumerState<IdentityVerificationPage> createState() => _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends ConsumerState<IdentityVerificationPage> {
  StreamSubscription? _kycSub;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    // SmileIdSocketService().connect();
    // No longer using sockets here as per requirements.
  }

  @override
  void dispose() {
    _kycSub?.cancel();
    super.dispose();
  }

  Future<bool> _handleKycSubmission(String selfie, List<String> liveness) async {
    setState(() {
      _isVerifying = true;
    });

    try {
      final success = await ref.read(walletNotifierProvider.notifier).submitBiometricKyc(
            selfieImage: selfie,
            livenessImages: liveness,
          );

      if (!success) {
        setState(() {
          _isVerifying = false;
        });
        return false;
      }

      // Check the status in the response
      final responseState = ref.read(walletNotifierProvider);
      final apiResponse = responseState.data?.first;

      if (apiResponse != null) {
        final data = apiResponse.data;
        if (data is Map &&
            (data['status'] == 'passed' ||
                data['status'] == 'completed' ||
                data['status'] == 'PROCESSING')) {
          // If status is passed or completed (and maybe PROCESSING if we want to move on anyway)
          // The USER says "when the status is passed or completed it will be successfully verifying"
          // but they also say "Please no need to listen to socket connection for this endpoint you just get the response and move on."
          // If the status is PROCESSING, it means the job has been submitted.
          // For now, let's treat passed/completed/PROCESSING as "success" for moving on
          // based on their instructions "you just get the response and move on".
          
            if (mounted) {
              setState(() {
                _isVerifying = false;
              });
              // Refresh profile
              ref.read(userNotifierProvider.notifier).refreshUserProfile();
              AppMessenger.show(context,
                  type: MessageType.success, message: apiResponse.message);
              
              Navigator.pop(context); // Close the camera page
              
              // Use root context for the dialog
              final rootContext = ConnectivityService.navigatorKey.currentContext;
              if (rootContext != null) {
                _showSuccessDialogOnContext(rootContext);
              } else {
                _showSuccessDialog();
              }
              return true;
            }
        } else {
          setState(() {
            _isVerifying = false;
          });
          AppMessenger.show(context,
              message: apiResponse.message, type: MessageType.error);
          return false;
        }
      }

      setState(() {
        _isVerifying = false;
      });
      return false;
    } catch (e, stack) {
      log('Submit KYC error: $e\n$stack');
      setState(() {
        _isVerifying = false;
      });
      AppMessenger.show(context, message: e.toString(), type: MessageType.error);
      return false;
    }
  }

  void _showSuccessDialog() => _showSuccessDialogOnContext(context);

  void _showSuccessDialogOnContext(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProfileSetupSuccessDialog(
          onContinue: () {
            // After successful KYC, proceed to set up transaction PIN using context.go to clear stacks
            context.go('/setup-pin');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartSelfieWidget(
      onComplete: _handleKycSubmission,
    );
  }
}

