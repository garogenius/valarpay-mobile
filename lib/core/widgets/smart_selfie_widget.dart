import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

enum LivenessInstruction {
  lookStraight('Please look straight ahead'),
  blink('Please blink your eyes'),
  smile('Please smile slightly'),
  turnLeft('Please turn your head slightly left'),
  turnRight('Please turn your head slightly right'),
  done('Capturing final image...'),
  completed('Verification completed!');

  final String message;
  const LivenessInstruction(this.message);
}

class SmartSelfieWidget extends StatefulWidget {
  final Future<bool> Function(String selfieBase64, List<String> livenessImagesBase64) onComplete;
  
  const SmartSelfieWidget({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<SmartSelfieWidget> createState() => _SmartSelfieWidgetState();
}

class _SmartSelfieWidgetState extends State<SmartSelfieWidget> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 0.1,
    ),
  );

  bool _isProcessing = false;
  bool _isInitializing = true;
  bool _hasPermission = false;
  bool _isFinished = false;
  bool _isCapturingFrame = false;

  LivenessInstruction _currentInstruction = LivenessInstruction.lookStraight;
  
  final List<String> _livenessImages = [];
  String? _finalSelfieImage;
  
  late AnimationController _progressController;
  
  DateTime _lastCaptureTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _hasPermission = true;
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      
      setState(() {
        _isInitializing = false;
      });
      _startVerification();
    } else {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasPermission = false;
        });
      }
    }
  }

  void _startVerification() {
    _cameraController?.startImageStream((image) {
      if (_isProcessing || _isFinished || _isCapturingFrame) return;
      _isProcessing = true;
      _processImage(image).then((_) {
        _isProcessing = false;
      });
    });
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) return;

      final face = faces.first;
      bool instructionCompleted = false;

      // Check if face is centered and reasonable size
      final boundingBox = face.boundingBox;
      if (boundingBox.width < 100) return; 

      switch (_currentInstruction) {
        case LivenessInstruction.lookStraight:
          if ((face.headEulerAngleY ?? 0).abs() < 15 && (face.headEulerAngleZ ?? 0).abs() < 15) {
            instructionCompleted = true;
          }
          break;
        case LivenessInstruction.blink:
          final leftEye = face.leftEyeOpenProbability ?? 1.0;
          final rightEye = face.rightEyeOpenProbability ?? 1.0;
          if (leftEye < 0.4 || rightEye < 0.4) {
            instructionCompleted = true;
          }
          break;
        case LivenessInstruction.smile:
          final smiling = face.smilingProbability ?? 0.0;
          if (smiling > 0.2) {
            instructionCompleted = true;
          }
          break;
        case LivenessInstruction.turnLeft:
          if ((face.headEulerAngleY ?? 0) < -7) {
            instructionCompleted = true;
          }
          break;
        case LivenessInstruction.turnRight:
          if ((face.headEulerAngleY ?? 0) > 7) {
            instructionCompleted = true;
          }
          break;
        default:
          break;
      }

      if (instructionCompleted) {
        _nextInstruction();
      } else {
        // Periodic capture during action (throttle to 250ms for SPEED)
        if (_livenessImages.length < 8 && DateTime.now().difference(_lastCaptureTime).inMilliseconds > 250) {
          _captureLivenessFrame();
          _lastCaptureTime = DateTime.now();
        }
      }
    } catch (e) {
      debugPrint('Face processing error: $e');
    }
  }

  Future<void> _captureLivenessFrame() async {
    if (_isCapturingFrame || _cameraController == null || !_cameraController!.value.isInitialized || _livenessImages.length >= 8) return;
    try {
      _isCapturingFrame = true;
      final xFile = await _cameraController!.takePicture();
      final File rawFile = File(xFile.path);
      final File compressedFile = await _compress(rawFile, maxWidth: 400); // Liveness can be smaller
      
      final bytes = await compressedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      if (_livenessImages.length < 8) {
        _livenessImages.add(base64String);
      }
      
      // Cleanup compressed file
      if (compressedFile.existsSync()) {
        try { compressedFile.deleteSync(); } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error capturing liveness frame: $e');
    } finally {
      _isCapturingFrame = false;
    }
  }

  void _nextInstruction() {
    // Capture whenever an instruction is successfully met
    _captureLivenessFrame();
    _lastCaptureTime = DateTime.now();

    final values = LivenessInstruction.values;
    final currentIndex = values.indexOf(_currentInstruction);
    
    // Last real human movement is turnRight (index 4)
    if (currentIndex < values.indexOf(LivenessInstruction.turnRight)) {
      if (mounted) {
        setState(() {
          _currentInstruction = values[currentIndex + 1];
        });
        _progressController.forward(from: 0);
      }
    } else if (_currentInstruction != LivenessInstruction.done && _currentInstruction != LivenessInstruction.completed) {
      // Just finished the last human instruction! 
      // Move to 'done' and trigger the final high-res capture.
      if (mounted) {
        setState(() {
           _currentInstruction = LivenessInstruction.done;
        });
      }
      _captureFinalSelfie();
    }
  }
  
  Future<void> _captureFinalSelfie() async {
    try {
      await _cameraController?.stopImageStream();
      
      // We already capture liveness frames during the stream for maximum speed.
      // One final high-res selfie will follow.
      debugPrint("✅ Instructions finished. Liveness frames collected: ${_livenessImages.length}");

      // Capture the high quality final selfie with fallback system
      XFile? xFile;
      try {
        xFile = await _cameraController?.takePicture();
      } catch (e) {
        debugPrint('High-res capture failed: $e');
      }

      if (xFile != null) {
         final File rawFile = File(xFile.path);
         final File compressedFile = await _compress(rawFile, quality: 40, maxWidth: 600); 
         _finalSelfieImage = base64Encode(await compressedFile.readAsBytes());
         
         if (compressedFile.existsSync()) {
           try { compressedFile.deleteSync(); } catch (_) {}
         }
      } else if (_livenessImages.isNotEmpty) {
          _finalSelfieImage = _livenessImages.first;
          debugPrint('Using fallback image from liveness frames.');
      }
      
      if (mounted) {
        setState(() {
           _currentInstruction = LivenessInstruction.completed;
        });
      }
      
      _finishAndSubmit();
    } catch(e) {
      debugPrint('Capture final selfie failed: $e');
      if (_finalSelfieImage == null && _livenessImages.isNotEmpty) {
        _finalSelfieImage = _livenessImages.first;
      }
      _finishAndSubmit();
    }
  }

  Future<File> _compress(File file, {int quality = 25, int maxWidth = 480}) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.path, 'sm_${DateTime.now().microsecondsSinceEpoch}.jpg');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: (maxWidth * 4 / 3).toInt(), // Maintain 3:4 aspect ratio
        format: CompressFormat.jpeg,
      );
      
      // Clean up the original file immediately
      if (file.existsSync()) {
        try { file.deleteSync(); } catch (_) {}
      }
      
      return result != null ? File(result.path) : file;
    } catch (e) {
      return file;
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    try {
      InputImageRotation rotation;
      switch (_cameraController!.description.sensorOrientation) {
        case 90: rotation = InputImageRotation.rotation90deg; break;
        case 180: rotation = InputImageRotation.rotation180deg; break;
        case 270: rotation = InputImageRotation.rotation270deg; break;
        default: rotation = InputImageRotation.rotation0deg;
      }

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      if (image.planes.isEmpty) return null;

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: _concatenatePlanes(image.planes),
        metadata: metadata,
      );
    } catch (_) {
      return null;
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    try {
      final WriteBuffer buffer = WriteBuffer();
      for (final plane in planes) {
        buffer.putUint8List(plane.bytes);
      }
      return buffer.done().buffer.asUint8List();
    } catch (e) {
      return Uint8List(0);
    }
  }

  Future<void> _finishAndSubmit() async {
    if (_isFinished) return;
    
    // Show the "Verifying Identity..." overlay
    if (mounted) {
      setState(() {
        _isFinished = true;
      });
    }
    
    try {
      if (_finalSelfieImage != null) {
        // Wait for the caller to complete their processing (API calls, etc.)
        await widget.onComplete(_finalSelfieImage!, _livenessImages);
      }
    } catch (e) {
      debugPrint('Error in onComplete: $e');
    } finally {
      // Hide the loader so the caller can show a dialog or error message on top of the results
      if (mounted) {
        setState(() {
          _isFinished = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFF76301))),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              const Text('Camera permission required', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initCamera,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF76301)),
                child: const Text('Grant Access', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
             child: FittedBox(
               fit: BoxFit.cover,
               child: SizedBox(
                   width: _cameraController!.value.previewSize?.height ?? 1,
                   height: _cameraController!.value.previewSize?.width ?? 1,
                   child: CameraPreview(_cameraController!)
               ),
             ),
          ),
          
          // OPay style Overlay
          Positioned.fill(
             child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                   Colors.black.withOpacity(0.7),
                   BlendMode.srcOut
                ),
                child: Stack(
                   children: [
                      Container(
                         decoration: const BoxDecoration(
                            color: Colors.black,
                            backgroundBlendMode: BlendMode.dstOut
                         ),
                      ),
                      Align(
                         alignment: Alignment.center,
                         child: Container(
                            width: 280,
                            height: 280,
                            decoration: const BoxDecoration(
                               color: Colors.white,
                               shape: BoxShape.circle
                            ),
                         ),
                      ),
                   ],
                ),
             ),
          ),

          Align(
             alignment: Alignment.center,
             child: Container(
                width: 282,
                height: 282,
                decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   border: Border.all(color: const Color(0xFFF76301), width: 4),
                ),
             ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Identity Verification',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Instruction Box
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentInstruction.message,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Progress indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: LivenessInstruction.values.sublist(0, 5).map((e) {
                           bool completed = LivenessInstruction.values.indexOf(e) < LivenessInstruction.values.indexOf(_currentInstruction);
                           bool isCurrent = e == _currentInstruction;
                           return Container(
                              width: isCurrent ? 12 : 8,
                              height: isCurrent ? 12 : 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                 shape: BoxShape.circle,
                                 color: isCurrent ? const Color(0xFFF76301) : (completed ? Colors.green : Colors.white24),
                              ),
                           );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
          
          if (_isFinished)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFF76301)),
                    SizedBox(height: 16),
                    Text('Verifying Identity...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

