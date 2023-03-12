import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:squat_arena/painters/pose_painter.dart';

class WorkoutController extends GetxController {
  CameraController? cameraCon;
  final PoseDetector poseDetector = PoseDetector(options: PoseDetectorOptions());
  List<CameraDescription> cameras = [];
  final CameraLensDirection initialDirection = CameraLensDirection.front;
  int cameraIndex = -1;
  final Rx<CustomPaint?> customPaint = const CustomPaint().obs;
  bool isProcessing = false; // pose 디텍팅 빈도 컨트롤
  int count = 0; // 디텍팅 카운터

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('⚪ WorkoutController init');
    cameras = await availableCameras();
    await initCamera(cameras);
  }

  @override
  void onClose() {
    super.onClose();
    poseDetector.close();
    stopLiveFeed();
  }

  Future<void> initCamera(List<CameraDescription> cameras) async {
    /// 몇번 카메라 인지 cameraIndex 찾는 중
    if (cameras.any(
      (element) {
        return element.lensDirection == initialDirection && element.sensorOrientation == 90;
      },
    )) {
      cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) {
          return element.lensDirection == initialDirection && element.sensorOrientation == 90;
        }),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == initialDirection) {
          cameraIndex = i;
          break;
        }
      }
    }

    /// 찾으면 liveFeed 시작
    if (cameraIndex != -1) {
      debugPrint('⚪ cameras[_cameraIndex].sensorOrientation : ${cameras[cameraIndex].sensorOrientation}');
      startLiveFeed(cameras);
    }
  }

  Future startLiveFeed(List<CameraDescription> cameras) async {
    final camera = cameras[cameraIndex];
    cameraCon = CameraController(camera, ResolutionPreset.low, enableAudio: false);
    cameraCon?.initialize().then((_) {
      cameraCon?.startImageStream(processCameraImage);
    });
  }

  Future processCameraImage(CameraImage image) async {
    if (isProcessing) return;
    isProcessing = true;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[cameraIndex];
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
    processImage(inputImage);

    await 0.1.delay();
    isProcessing = false;
  }

  Future<void> processImage(InputImage inputImage) async {
    if (count % 100 == 0) debugPrint('⚪ count : $count');

    final poses = await poseDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null && inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size, inputImage.inputImageData!.imageRotation);
      customPaint.value = CustomPaint(painter: painter);
      count++;
    } else {
      customPaint.value = null;
      debugPrint('⚠️ error @  : customPaint.value = null');
    }
  }

  Future stopLiveFeed() async {
    await cameraCon?.stopImageStream();
    await cameraCon?.dispose();
    cameraCon = null;
  }
}
