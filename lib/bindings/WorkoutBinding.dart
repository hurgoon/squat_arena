import 'package:get/get.dart';
import 'package:squat_arena/controllers/workout_controller.dart';

class WorkoutBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(WorkoutController());
  }
}
