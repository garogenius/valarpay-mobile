import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/dashboard/view/KYC/nin_identity_verification.dart';

class NinCameraPermissionPage extends ConsumerStatefulWidget {
  final String nin;
  const NinCameraPermissionPage({required this.nin, Key? key})
      : super(key: key);

  @override
  ConsumerState<NinCameraPermissionPage> createState() =>
      _NinCameraPermissionPageState();
}

class _NinCameraPermissionPageState
    extends ConsumerState<NinCameraPermissionPage> {
  bool _isLoading = false;

  Future<void> _requestCameraPermission() async {
    setState(() => _isLoading = true);
    try {
      final status = await Permission.camera.request();

      if (status.isGranted) {
        context.push('/nin-identity-verification/${widget.nin}');
      } else if (status.isDenied) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                'To verify your identity for Tier 2 upgrade, we need access to your camera. This allows us to capture your face for identity verification.',
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
