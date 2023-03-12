import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:squat_arena/painters/pose_painter.dart';
import 'package:squat_arena/main.dart';
import 'package:get/get.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  int _cameraIndex = -1;
  String _text = '';
  final CameraLensDirection initialDirection = CameraLensDirection.front;
  CameraController? cameraCon;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  bool _changingCameraLens = false;

  final ConstraintId box0 = ConstraintId('box0');
  final ConstraintId box1 = ConstraintId('box1');

  @override
  void initState() {
    super.initState();

    /// 몇번 카메라 인지 _cameraIndex 찾는 중
    if (cameras.any(
      (element) {
        return element.lensDirection == initialDirection && element.sensorOrientation == 90;
      },
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) {
          return element.lensDirection == initialDirection && element.sensorOrientation == 90;
        }),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }

    /// 찾으면 liveFeed 시작
    if (_cameraIndex != -1) {
      debugPrint('⚪ cameras[_cameraIndex].sensorOrientation : ${cameras[_cameraIndex].sensorOrientation}');
      _startLiveFeed();
    }
  }

  @override
  void dispose() async {
    super.dispose();
    _canProcess = false;
    _poseDetector.close();
    _stopLiveFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: ConstraintLayout(
        children: [
          Container(
            decoration: BoxDecoration(border: Border.all(width: 5, color: Colors.blue)),
          ).applyConstraint(id: box0, topLeftTo: parent),

          /// 카메라 프리뷰
          if (cameraCon?.value.isInitialized ?? false)
            Container(
              child:
                  _changingCameraLens ? const Center(child: Text('Changing camera lens')) : CameraPreview(cameraCon!),
            ).applyConstraint(
              id: box1,
              width: 200,
              height: Get.height * 0.8,
              centerLeftTo: box0.leftMargin(20),
              left: box0.left.margin(20),
            ),

          /// 뼈다구 페인트
          if (_customPaint != null)
            Container(
              decoration: BoxDecoration(border: Border.all(width: 5, color: Colors.red)),
              child: _customPaint!,
            ).applyConstraint(
              width: 200,
              height: Get.height * 0.8,
              centerLeftTo: box0.leftMargin(20),
              left: box0.left.margin(20),
            ),
        ],
      ),
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null && inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size, inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    cameraCon = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );

    cameraCon?.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      cameraCon?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      cameraCon?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      cameraCon?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await cameraCon?.stopImageStream();
    await cameraCon?.dispose();
    cameraCon = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);

    if (imageRotation == null) return;

    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    // widget.onImage(inputImage);
    processImage(inputImage);
  }

  Widget? _floatingActionButton() {
    if (cameras.length == 1) return null;
    return SizedBox(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          onPressed: _switchLiveCamera,
          child: Icon(
            Platform.isIOS ? Icons.flip_camera_ios_outlined : Icons.flip_camera_android_outlined,
            size: 40,
          ),
        ));
  }
}

// 사이즈 스케일러
// Positioned(
//   bottom: 100,
//   left: 50,
//   right: 50,
//   child: Slider(
//     value: zoomLevel,
//     min: minZoomLevel,
//     max: maxZoomLevel,
//     onChanged: (newSliderValue) {
//       setState(() {
//         zoomLevel = newSliderValue;
//         _controller!.setZoomLevel(zoomLevel);
//       });
//     },
//     divisions: (maxZoomLevel - 1).toInt() < 1 ? null : (maxZoomLevel - 1).toInt(),
//   ),
// )
