import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:squat_arena/pages/workout_page.dart';
import 'package:squat_arena/bindings/WorkoutBinding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      getPages: [
        GetPage(name: '/workout', page: () => WorkoutPage(), bindings: [WorkoutBinding()]),
      ],
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text('SQUAT ARENA'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/workout'),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
