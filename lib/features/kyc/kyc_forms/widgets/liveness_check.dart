// import 'dart:io';

// import 'package:auto_route/auto_route.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

// import '../../../../utils/constants/values.dart';

// @RoutePage()
// class LivenessCheckScreen extends StatefulWidget {
//   const LivenessCheckScreen({super.key});

//   @override
//   State<LivenessCheckScreen> createState() => _LivenessCheckScreenState();
// }

// class _LivenessCheckScreenState extends State<LivenessCheckScreen> {
//   static const LivenessConfig _config = LivenessConfig(
//     challengeTypes: [ChallengeType.smile],
//     alwaysIncludeBlink: false,
//     numberOfRandomChallenges: 1,
//     contourChallengeTypes: [ChallengeType.smile],
//     challengeInstructions: {ChallengeType.smile: 'Smile to capture your photo'},
//     defaultChallengeHintConfig: ChallengeHintConfig(enabled: false),
//   );

//   List<CameraDescription>? _cameras;
//   String? _errorMessage;
//   bool _isLoading = true;
//   bool _isReturningImage = false;

//   late final LivenessTheme _theme = LivenessTheme.fromMaterialColor(
//     AppColors.primaryColor,
//     brightness: Brightness.dark,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _loadCameras();
//   }

//   Future<void> _loadCameras() async {
//     try {
//       final cameras = await availableCameras();
//       final hasFrontCamera = cameras.any(
//         (camera) => camera.lensDirection == CameraLensDirection.front,
//       );

//       if (!hasFrontCamera) {
//         setState(() {
//           _errorMessage = 'No front camera is available on this device.';
//           _isLoading = false;
//         });
//         return;
//       }

//       setState(() {
//         _cameras = cameras;
//         _isLoading = false;
//       });
//     } catch (_) {
//       setState(() {
//         _errorMessage = 'Unable to start the camera. Please try again.';
//         _isLoading = false;
//       });
//     }
//   }

//   void _returnCapturedImage(XFile imageFile) {
//     if (!mounted || _isReturningImage) return;

//     _isReturningImage = true;
//     context.router.pop(File(imageFile.path));
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: AppColors.darkBlue,
//         body: Center(child: CircularProgressIndicator(color: AppColors.white)),
//       );
//     }

//     if (_errorMessage != null) {
//       return Scaffold(
//         backgroundColor: AppColors.darkBlue,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: AppColors.white),
//             onPressed: () => context.router.pop(),
//           ),
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.error_outline,
//                   color: AppColors.white,
//                   size: 56,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   _errorMessage!,
//                   textAlign: TextAlign.center,
//                   style: AppTextStyles.cabinRegular14White,
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: () => context.router.pop(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                   ),
//                   child: const Text('Go back'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return LivenessDetectionScreen(
//       cameras: _cameras!,
//       config: _config,
//       theme: _theme,
//       captureFinalImage: true,
//       showCaptureImageButton: false,
//       showStatusIndicators: false,
//       customAppBar: AppBar(
//         title: const Text('Verify your photo'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.router.pop(),
//         ),
//       ),
//       onFinalImageCaptured: (sessionId, imageFile, metadata) {
//         _returnCapturedImage(imageFile);
//       },
//     );
//   }
// }
