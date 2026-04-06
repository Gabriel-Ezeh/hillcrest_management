import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:auto_route/auto_route.dart';

// ──────────────────────────────────────────────
// Liveness challenge definitions
// ──────────────────────────────────────────────

enum ChallengeType { lookStraight, smile, turnLeft, turnRight, capturing }

class Challenge {
  final ChallengeType type;
  final String instruction;
  final String icon;
  final String completedText;

  const Challenge({
    required this.type,
    required this.instruction,
    required this.icon,
    required this.completedText,
  });
}

const List<Challenge> kChallenges = [
  Challenge(
    type: ChallengeType.lookStraight,
    instruction: 'Look straight at the camera',
    icon: '👤',
    completedText: 'Face detected ✓',
  ),
  Challenge(
    type: ChallengeType.smile,
    instruction: 'Now smile!',
    icon: '😊',
    completedText: 'Smile detected ✓',
  ),
  Challenge(
    type: ChallengeType.turnLeft,
    instruction: 'Turn your head to the left',
    icon: '⬅️',
    completedText: 'Left turn detected ✓',
  ),
  Challenge(
    type: ChallengeType.turnRight,
    instruction: 'Turn your head to the right',
    icon: '➡️',
    completedText: 'Right turn detected ✓',
  ),
];

// ──────────────────────────────────────────────
// Face Capture Screen
// ──────────────────────────────────────────────

/// A liveness-check screen that walks the user through [kChallenges], then
/// captures a photo.  On success it pops with a [File] so the calling screen
/// (IndividualKycDocumentUploadScreen) can store it:
///
/// ```dart
/// final result = await context.router.push(const LivenessCheckRoute());
/// if (result is File) { /* use the captured photo */ }
/// ```
@RoutePage()
class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _isCapturing = false;
  List<Face> _faces = [];
  CameraDescription? _currentCamera;
  int _frameCount = 0;

  // ── Liveness challenge state ──
  int _currentChallengeIndex = 0;
  int _holdFrames = 0;
  static const int _holdThreshold = 8;
  String _statusText = 'Initializing camera...';
  bool _challengeComplete = false;
  bool _showCheckmark = false;

  // ── Animation ──
  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _initializeFaceDetector();
    _initializeCamera();
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.1,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    _currentCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      _currentCamera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();
    } catch (e) {
      if (mounted) setState(() => _statusText = 'Camera error: $e');
      return;
    }

    if (!mounted) return;
    setState(() => _statusText = kChallenges[0].instruction);
    _cameraController!.startImageStream(_processImage);
  }

  void _resetChallenge() {
    setState(() {
      _currentChallengeIndex = 0;
      _holdFrames = 0;
      _challengeComplete = false;
      _showCheckmark = false;
      _isCapturing = false;
      _statusText = kChallenges[0].instruction;
    });

    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_cameraController!.value.isStreamingImages) {
      _cameraController!.startImageStream(_processImage);
    }
  }

  // ─────────────────────────────────────────────────
  // Photo capture — called after all challenges pass.
  // Pops with a File so the KYC screen can store it.
  // ─────────────────────────────────────────────────

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
      _statusText = 'Capturing...';
    });

    try {
      await _cameraController!.stopImageStream();
      final XFile photo = await _cameraController!.takePicture();

      if (!mounted) return;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              _PhotoReviewScreen(imagePath: photo.path, faces: _faces),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        // ✅ User accepted — return the captured File to the KYC screen.
        context.router.pop(File(photo.path));
      } else {
        // User chose to retake — reset the challenge flow.
        _resetChallenge();
      }
    } catch (e) {
      debugPrint('❌ Capture error: $e');
      _resetChallenge();
    }
  }

  // ─────────────────────────────────────────────────
  // Frame processing + challenge evaluation
  // ─────────────────────────────────────────────────

  void _processImage(CameraImage image) {
    if (_isDetecting || _isCapturing || _challengeComplete) return;
    _isDetecting = true;
    _frameCount++;

    final inputImage = _convertCameraImage(image);
    if (inputImage == null) {
      _isDetecting = false;
      return;
    }

    _faceDetector!
        .processImage(inputImage)
        .then((faces) {
          if (!mounted) return;

          _faces = faces;

          if (faces.isEmpty) {
            setState(() {
              _holdFrames = 0;
              _statusText = 'Position your face in the frame';
            });
            _isDetecting = false;
            return;
          }

          final face = faces.first;
          final challenge = kChallenges[_currentChallengeIndex];
          final bool passed = _evaluateChallenge(face, challenge.type);

          setState(() {
            if (passed) {
              _holdFrames++;
              _progressController.animateTo(
                _holdFrames / _holdThreshold,
                curve: Curves.easeOut,
              );

              if (_holdFrames >= _holdThreshold) {
                _showCheckmark = true;
                _holdFrames = 0;
                _progressController.reset();

                if (_currentChallengeIndex < kChallenges.length - 1) {
                  _statusText = challenge.completedText;
                  Future.delayed(const Duration(milliseconds: 600), () {
                    if (!mounted) return;
                    setState(() {
                      _currentChallengeIndex++;
                      _showCheckmark = false;
                      _statusText =
                          kChallenges[_currentChallengeIndex].instruction;
                    });
                  });
                } else {
                  _statusText = 'All checks passed!';
                  _challengeComplete = true;
                  Future.delayed(const Duration(milliseconds: 400), () {
                    _capturePhoto();
                  });
                }
              } else {
                _statusText = challenge.instruction;
              }
            } else {
              if (_holdFrames > 0) {
                _holdFrames = (_holdFrames - 2).clamp(0, _holdThreshold);
                _progressController.animateTo(
                  _holdFrames / _holdThreshold,
                  curve: Curves.easeOut,
                );
              }
              _statusText = challenge.instruction;
            }
          });

          _isDetecting = false;
        })
        .catchError((e) {
          debugPrint('❌ Detection error: $e');
          _isDetecting = false;
        });
  }

  bool _evaluateChallenge(Face face, ChallengeType type) {
    final smile = face.smilingProbability ?? 0;
    final leftEye = face.leftEyeOpenProbability ?? 0;
    final rightEye = face.rightEyeOpenProbability ?? 0;
    final headY = face.headEulerAngleY ?? 0;
    final headZ = face.headEulerAngleZ ?? 0;

    switch (type) {
      case ChallengeType.lookStraight:
        return leftEye > 0.4 &&
            rightEye > 0.4 &&
            headY.abs() < 15 &&
            headZ.abs() < 10;

      case ChallengeType.smile:
        return smile > 0.7 && headY.abs() < 20;

      case ChallengeType.turnLeft:
        return headY > 25;

      case ChallengeType.turnRight:
        return headY < -25;

      case ChallengeType.capturing:
        return false;
    }
  }

  // ─────────────────────────────────────────────────
  // CameraImage → InputImage (Android NV21 / iOS BGRA)
  // ─────────────────────────────────────────────────

  InputImage? _convertCameraImage(CameraImage image) {
    final camera = _currentCamera;
    if (camera == null) return null;

    final InputImageRotation rotation;
    if (Platform.isAndroid) {
      switch (camera.sensorOrientation) {
        case 0:
          rotation = InputImageRotation.rotation0deg;
          break;
        case 90:
          rotation = InputImageRotation.rotation90deg;
          break;
        case 180:
          rotation = InputImageRotation.rotation180deg;
          break;
        case 270:
          rotation = InputImageRotation.rotation270deg;
          break;
        default:
          rotation = InputImageRotation.rotation0deg;
      }
    } else {
      rotation = InputImageRotation.rotation90deg;
    }

    if (Platform.isAndroid) {
      final int rawFormat = image.format.raw;

      if (_frameCount == 1) {
        debugPrint(
          '📷 format=$rawFormat, planes=${image.planes.length}, '
          'size=${image.width}x${image.height}',
        );
      }

      Uint8List bytes;
      if (rawFormat == 17) {
        final WriteBuffer wb = WriteBuffer();
        for (final plane in image.planes) {
          wb.putUint8List(plane.bytes);
        }
        bytes = wb.done().buffer.asUint8List();
      } else if (rawFormat == 35) {
        bytes = _yuv420toNv21(image);
      } else {
        return null;
      }

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    }

    // iOS
    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.bgra8888,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _yuv420toNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = width * height ~/ 2;
    final Uint8List nv21 = Uint8List(ySize + uvSize);

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    int yIndex = 0;
    for (int row = 0; row < height; row++) {
      final int rowStart = row * yPlane.bytesPerRow;
      for (int col = 0; col < width; col++) {
        nv21[yIndex++] = yPlane.bytes[rowStart + col];
      }
    }

    final int uvPixelStride = uPlane.bytesPerRow > width ~/ 2 ? 2 : 1;

    if (vPlane.bytes.length >= uvSize - 1 && uvPixelStride == 2) {
      int uvIndex = ySize;
      for (int row = 0; row < height ~/ 2; row++) {
        final int rowStart = row * vPlane.bytesPerRow;
        for (int col = 0; col < width - 1; col++) {
          nv21[uvIndex++] = vPlane.bytes[rowStart + col];
        }
        if (uvIndex < nv21.length) {
          nv21[uvIndex++] = vPlane.bytes[rowStart + width - 2];
        }
      }
    } else {
      int uvIndex = ySize;
      final int uvWidth = width ~/ 2;
      final int uvHeight = height ~/ 2;
      for (int row = 0; row < uvHeight; row++) {
        for (int col = 0; col < uvWidth; col++) {
          final int vIdx = row * vPlane.bytesPerRow + col * uvPixelStride;
          final int uIdx = row * uPlane.bytesPerRow + col * uvPixelStride;
          if (vIdx < vPlane.bytes.length && uIdx < uPlane.bytes.length) {
            nv21[uvIndex++] = vPlane.bytes[vIdx];
            nv21[uvIndex++] = uPlane.bytes[uIdx];
          }
        }
      }
    }

    return nv21;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  // ─────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(_statusText, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    final challenge = _currentChallengeIndex < kChallenges.length
        ? kChallenges[_currentChallengeIndex]
        : null;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          _CameraPreviewWidget(
            controller: _cameraController!,
            faces: _faces,
            isFrontCamera:
                _currentCamera?.lensDirection == CameraLensDirection.front,
          ),

          // Dark vignette overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                radius: 0.85,
              ),
            ),
          ),

          // Oval face guide
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.02);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 240,
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(120),
                      border: Border.all(
                        color: _showCheckmark
                            ? Colors.greenAccent
                            : _faces.isNotEmpty
                            ? Colors.tealAccent.withOpacity(0.8)
                            : Colors.white24,
                        width: _showCheckmark ? 4 : 2.5,
                      ),
                    ),
                    child: _showCheckmark
                        ? const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                              size: 64,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),

          // Top: step progress indicators
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(kChallenges.length, (i) {
                      final bool done = i < _currentChallengeIndex;
                      final bool active = i == _currentChallengeIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: active ? 32 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: done
                              ? Colors.greenAccent
                              : active
                              ? Colors.tealAccent
                              : Colors.white24,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Challenge instruction card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (challenge != null)
                          Text(
                            challenge.icon,
                            style: const TextStyle(fontSize: 36),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          _statusText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Step ${_currentChallengeIndex + 1} of ${kChallenges.length}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Hold progress bar
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _progressController.value > 0.7
                                ? Colors.greenAccent
                                : Colors.tealAccent,
                          ),
                          minHeight: 5,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom: Reset button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton.icon(
                onPressed: _resetChallenge,
                icon: const Icon(Icons.refresh, color: Colors.white54),
                label: const Text(
                  'Start Over',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Camera preview widget (private to this file)
// ──────────────────────────────────────────────

class _CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final List<Face> faces;
  final bool isFrontCamera;

  const _CameraPreviewWidget({
    required this.controller,
    required this.faces,
    required this.isFrontCamera,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize!.height,
        height: controller.value.previewSize!.width,
        child: controller.buildPreview(),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Photo review screen (private to this file)
// ──────────────────────────────────────────────

class _PhotoReviewScreen extends StatelessWidget {
  final String imagePath;
  final List<Face> faces;

  const _PhotoReviewScreen({required this.imagePath, required this.faces});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(imagePath), fit: BoxFit.cover),

          // Success banner
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user,
                      color: Colors.greenAccent,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Liveness Verified',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'All challenges passed successfully',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'File: ${imagePath.split('/').last}',
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.replay),
                    label: const Text('Retake'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.check),
                    label: const Text('Use Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
