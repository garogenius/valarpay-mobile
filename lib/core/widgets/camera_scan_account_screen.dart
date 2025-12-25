import 'dart:async';
// removed unused imports

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';

// CameraScanScreen: opens camera, performs real-time text recognition and returns
// the first found 10-digit number to the caller via Navigator.pop(context, result).
class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  CameraController? _controller;
  bool _isDetecting = false;
  String? detectedNumber;
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  List<TextBlock> _blocks = [];
  Timer? _frameTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
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

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();

    // start periodic captures for pseudo real-time detection
    _frameTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      _captureAndProcess();
    });

    if (mounted) setState(() {});
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Camera Permission Required'),
            content: const Text(
              'Camera access is required to scan account numbers. Please enable it in your app settings.',
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

  Future<void> _captureAndProcess() async {
    if (_isDetecting) return;
    if (_controller == null || !_controller!.value.isInitialized) return;
    _isDetecting = true;
    try {
      final file = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final recognized = await _textRecognizer.processImage(inputImage);
      _blocks = recognized.blocks;

      for (final block in recognized.blocks) {
        final text = block.text.replaceAll(RegExp(r'[^0-9]'), '');
        final match = RegExp(r'\d{10}').firstMatch(text);
        if (match != null) {
          final number = match.group(0);
          if (number != null && number.length == 10) {
            detectedNumber = number;
            _frameTimer?.cancel();
            await _controller?.dispose();
            if (mounted) Navigator.of(context).pop(detectedNumber);
            break;
          }
        }
      }
    } catch (e) {
      // ignore
    } finally {
      _isDetecting = false;
    }
  }

  // We capture still images periodically and process them; no CameraImage->InputImage conversion needed here.

  @override
  void dispose() {
    _textRecognizer.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _onButtonPressed() async {
      try {
        final file = await _controller!.takePicture();
        final path = file.path;
        final inputImage = InputImage.fromFilePath(path);
        final recognized = await _textRecognizer.processImage(inputImage);
        for (final block in recognized.blocks) {
          final text = block.text.replaceAll(RegExp(r'[^0-9]'), '');
          final match = RegExp(r'\d{10}').firstMatch(text);
          if (match != null) {
            final number = match.group(0);
            if (number != null) {
              await _controller?.stopImageStream();
              await _controller?.dispose();
              if (mounted) Navigator.of(context).pop(number);
              return;
            }
          }
        }
        AppMessenger.show(
          context,
          message: 'No 10-digit number found',
          type: MessageType.error,
        );
        Navigator.of(context).pop();
      } catch (e) {
        // ignore
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Account Number',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            CameraPreview(_controller!),

            // overlay rectangle in center
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _OverlayPainter(
                    blocks: _blocks,
                    controller: _controller,
                  ),
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: FullWidthButton(
                    text: 'Capture & Scan',
                    onPressed: () async {
                      _onButtonPressed();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final List<TextBlock> blocks;
  final CameraController? controller;

  _OverlayPainter({required this.blocks, required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = appTheme.primaryColor;

    // draw a central rectangle
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.8,
      height: size.height * 0.4,
    );
    canvas.drawRect(rect, paint);

    // (Optional) Could draw block bounding boxes here if coordinate mapping is available.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
