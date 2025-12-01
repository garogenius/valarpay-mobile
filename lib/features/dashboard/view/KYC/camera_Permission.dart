import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/dashboard/view/KYC/identity_verification.dart';
import 'package:valarpay/features/models/bvn_verification_request.dart';
import '../../widgets/Kyc/kyc_progress_bar.dart';
import 'kyc_step_provider.dart';

class CameraPermissionPage extends ConsumerStatefulWidget {
  final BvnVerificationRequest request;
  const CameraPermissionPage({required this.request, Key? key})
      : super(key: key);

  @override
  ConsumerState<CameraPermissionPage> createState() =>
      _CameraPermissionPageState();
}

class _CameraPermissionPageState extends ConsumerState<CameraPermissionPage> {
  bool _isLoading = false;

  Future<void> _requestCameraPermission() async {
    setState(() => _isLoading = true);
    try {
      final status = await Permission.camera.request();

      if (status.isGranted) {
        ref.read(kycStepProvider.notifier).state = 5;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                IdentityVerificationPage(request: widget.request),
          ),
        );
      } else if (status.isDenied) {
        // Permission denied
        AppMessenger.show(
          context,
          message: 'Camera permission is required for identity verification',
          type: MessageType.error,
        );
      } else if (status.isPermanentlyDenied) {
        _showOpenSettingsDialog();
      }
    } catch (e) {
      AppMessenger.show(
        context,
        message: 'Failed to request camera permission: ${e.toString()}',
        type: MessageType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Show dialog to guide user to app settings
  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text(
            'Camera access has been permanently denied. Please enable it in app settings to continue with identity verification.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
@override
  void initState() {
    Future.microtask(() {
      ref
          .read(kycStepProvider.notifier)
          .state = 5;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              IdentityVerificationPage(request: widget.request),
        ),
      );
    });

    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(kycStepProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(kycStepProvider.notifier).state = 3;
              Navigator.pop(context);
            }),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Step Progress Bar
              StepProgressBar(currentStep: currentStep),
              const SizedBox(height: 60),
              // Camera Icon with Background
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/icons/Camera.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFF76301),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Title
              const Text(
                'Camera Permission Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              // Description
              const Text(
                'To keep your account secure, we need access to your camera. This allows us to capture your face for identity verification, confirm it\'s really you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Warning Text
              const Text(
                'Don\'t worry—your camera is only used for verification and nothing else',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF76301),
                  fontFamily: 'SF Pro',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  letterSpacing: 0.06,
                ),
              ),
              const SizedBox(height: 40),
              // Allow Permission Button
              FullWidthButton(
                text: 'Allow Permission',
                isEnabled: true,
                isLoading: _isLoading,
                onPressed: _requestCameraPermission,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
