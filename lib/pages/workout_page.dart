import 'package:flutter/material.dart';
import 'package:squat_arena/controllers/workout_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

// ignore: must_be_immutable
class WorkoutPage extends GetView<WorkoutController> {
  WorkoutPage({Key? key}) : super(key: key);

  final ConstraintId box0 = ConstraintId('box0');
  final ConstraintId box1 = ConstraintId('box1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: ConstraintLayout(
        children: [
          Container(
            decoration: BoxDecoration(border: Border.all(width: 5, color: Colors.blue)),
          ).applyConstraint(id: box0, topLeftTo: parent),

          /// 뼈다구 페인트
          if (controller.customPaint.value != null)
            Obx(
              () => Container(
                decoration: BoxDecoration(border: Border.all(width: 5, color: Colors.red)),
                child: controller.customPaint.value!,
              ).applyConstraint(
                width: 200,
                height: Get.height * 0.8,
                centerRightTo: box0.rightMargin(40),
              ),
            ),
        ],
      ),
    );
  }
}

/// 카메라 프리뷰
// if (controller.cameraCon != null && (controller.cameraCon?.value.isInitialized ?? false))
//   Container(
//     child: _changingCameraLens
//         ? const Center(child: Text('Changing camera lens'))
//         : CameraPreview(controller.cameraCon!),
//   ).applyConstraint(
//     id: box1,
//     width: 200,
//     height: Get.height * 0.8,
//     centerLeftTo: box0.leftMargin(20),
//     left: box0.left.margin(20),
//   ),

// Future _switchLiveCamera() async {
//   setState(() => _changingCameraLens = true);
//   _cameraIndex = (_cameraIndex + 1) % cameras.length;
//
//   await _stopLiveFeed();
//   await _startLiveFeed();
//   setState(() => _changingCameraLens = false);
// }

// Widget? _floatingActionButton() {
//   if (cameras.length == 1) return null;
//   return SizedBox(
//       height: 70.0,
//       width: 70.0,
//       child: FloatingActionButton(
//         onPressed: _switchLiveCamera,
//         child: Icon(
//           Platform.isIOS ? Icons.flip_camera_ios_outlined : Icons.flip_camera_android_outlined,
//           size: 40,
//         ),
//       ));
// }

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
