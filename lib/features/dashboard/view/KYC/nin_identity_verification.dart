import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/nin_verification_request.dart';
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
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  bool _isCaptured = false;
  bool _isLoading = false;
  File? _capturedImage;
  Timer? _countdownTimer;
  int _countdown = 10;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      PermissionStatus status = await Permission.camera.status;

      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDialog();
        }
        return;
      }

      status = await Permission.camera.request();

      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          if (mounted) _showPermissionDialog();
        }
        return;
      }

      _cameras = await availableCameras();
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _startCountdown();
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Camera Permission Required'),
            content: const Text(
              'Camera access is required for identity verification. Please enable it in your app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Settings'),
              ),
            ],
          ),
    );
  }

  void _startCountdown() {
    setState(() {
      _countdown = 10;
      _isCaptured = false;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        await _capturePhoto();
      }
    });
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() => _isCapturing = true);
      final image = await _controller!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/nin_face_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File savedImage = await File(image.path).copy(imagePath);

      setState(() {
        _capturedImage = savedImage;
        _isCaptured = true;
        _isCapturing = false;
      });
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      setState(() => _isCapturing = false);
    }
  }

  void _retake() {
    setState(() {
      _capturedImage = null;
      _isCaptured = false;
    });
    _startCountdown();
  }

  Future<String> convertFileToBase64Async(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Compress image to reduce size before Base64 encoding
  Future<File> compressImage(File file) async {
    try {
      // Read image bytes
      final bytes = await file.readAsBytes();
      log(
        '📏 Original image size: ${bytes.length} bytes (${(bytes.length / 1024).toStringAsFixed(2)} KB)',
      );

      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        log('❌ Failed to decode image');
        return file;
      }

      // Resize if too large (max width/height 800px)
      img.Image resized = image;
      if (image.width > 800 || image.height > 800) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? 800 : null,
          height: image.height > image.width ? 800 : null,
        );
        log(
          '📐 Resized from ${image.width}x${image.height} to ${resized.width}x${resized.height}',
        );
      }

      // Compress as JPEG with quality 70
      final compressed = img.encodeJpg(resized, quality: 70);
      log(
        '📏 Compressed image size: ${compressed.length} bytes (${(compressed.length / 1024).toStringAsFixed(2)} KB)',
      );

      // Save compressed image
      final directory = await getApplicationDocumentsDirectory();
      final compressedPath =
          '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressed);

      log('✅ Image compressed successfully');
      return compressedFile;
    } catch (e) {
      log('❌ Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }

  Future<void> _submitNinVerification(File capturedImage) async {
    try {
      setState(() => _isLoading = true);

      log("🔍 Starting NIN verification...");
      log("📸 Image path: ${capturedImage.path}");
      log("📏 Original image size: ${await capturedImage.length()} bytes");

      // Compress image first to reduce size
      final compressedImage = await compressImage(capturedImage);
      log("📏 Compressed image size: ${await compressedImage.length()} bytes");

      // Convert to Base64
      String base64Image = await convertFileToBase64Async(compressedImage);
      log("✅ Base64 conversion complete, length: ${base64Image.length}");

      // Add data URI prefix for backend
      final selfieImage = 'data:image/jpeg;base64,$base64Image';
      log("✅ Data URI created, total length: ${selfieImage.length}");

      final requestBody = NinVerificationRequest(
        nin: widget.nin,
        selfieImage: selfieImage,
      );
      log("📤 Sending request with NIN: ${widget.nin}");

      // Call backend API
      final response = await ref
          .read(userNotifierProvider.notifier)
          .verifyNinTier2(requestBody);

      log("📥 Response received:");
      log("   - Status Code: ${response?.statusCode}");
      log("   - Message: ${response?.message}");
      log("   - Is Success: ${response?.isSuccess}");

      if (response != null && response.isSuccess) {
        log("✅ NIN verification successful!");

        // Refresh user profile to get updated tier
        await ref.read(userNotifierProvider.notifier).refreshUserProfile();

        if (!mounted) return;

        AppMessenger.show(
          context,
          type: MessageType.success,
          message: response.message ?? 'Tier 2 verification successful!',
        );

        _showSuccessDialog();
      } else {
        final errorMsg =
            response?.message ??
            response?.error ??
            'NIN verification failed. Please try again.';
        log("❌ NIN verification failed: $errorMsg");

        if (!mounted) return;

        AppMessenger.show(context, type: MessageType.error, message: errorMsg);
      }
    } catch (e, stackTrace) {
      log("❌ Exception during NIN verification: $e");
      log("Stack trace: $stackTrace");

      if (!mounted) return;

      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Verification failed: ${e.toString()}',
      );
      _retake();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
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
                'Tier 2 Upgrade Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your account has been upgraded to Tier 2. You now have access to higher transaction limits.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to home/dashboard
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
  void dispose() {
    _controller?.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF76301),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_isCameraInitialized && !_isCaptured)
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.previewSize!.height,
                              height: _controller!.value.previewSize!.width,
                              child: CameraPreview(_controller!),
                            ),
                          )
                        else if (_capturedImage != null)
                          Image.file(_capturedImage!, fit: BoxFit.cover),
                        if (!_isCaptured && _isCameraInitialized)
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                '$_countdown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (_isCapturing)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_isCameraInitialized && _isCaptured)
                TextButton(
                  onPressed: _isCameraInitialized ? _retake : null,
                  child: const Icon(Icons.refresh, size: 40),
                ),
              const Text(
                'Tips for a Successful Identity Verification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              const TipItem(
                text:
                    'Stay in a bright, well-lit environment for clear visibility',
              ),
              const SizedBox(height: 16),
              const TipItem(
                text:
                    'Hold your phone steady at eye level without shaking hands',
              ),
              const SizedBox(height: 16),
              const TipItem(
                text:
                    'Keep your entire face clearly visible inside the camera frame',
              ),
              const SizedBox(height: 16),
              const TipItem(
                text:
                    'Remove caps, glasses, or face coverings for accurate detection',
              ),
              const SizedBox(height: 20),
              FullWidthButton(
                text: 'Continue',
                isLoading: _isLoading,
                isEnabled: _capturedImage != null,
                onPressed: () {
                  if (_capturedImage != null) {
                    _submitNinVerification(_capturedImage!);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TipItem extends StatelessWidget {
  final String text;

  const TipItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF9CA3AF), width: 1.5),
          ),
          child: const Icon(Icons.check, size: 12, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontFamily: 'SF Pro',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
