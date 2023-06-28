import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotePage extends GetView {
  const NotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Test')),
      body: GetBuilder<RhythmController>(
        init: RhythmController(),
        builder: (ctrl) {
          return CustomPaint(
            painter: NotePainter(ctrl.notePosition, ctrl.noteWidth, ctrl.noteHeight, ctrl.noteList),
            size: MediaQuery.of(context).size,
          );
        },
      ),
    );
  }
}

class RhythmController extends GetxController {
  double notePosition = -50;
  double noteSpeed = 5;
  double noteWidth = 50;
  double noteHeight = 50;

  final List<Note> noteList = [
    Note('rect', -50, 50, 50),
    Note('rect', -150, 30, 20),
    Note('rect', -200, 80, 10),
  ];

  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(Duration(milliseconds: 20), _onTick);
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }

  void _onTick(Timer timer) {
    notePosition += noteSpeed;
    if (notePosition > Get.width) {
      // notePosition = -50; // 처음으로 되돌아옴
    }
    update();
  }
}

class Note {
  Note(this.noteShape, this.notePosition, this.noteWidth, this.noteHeight);
  final String noteShape;
  final double notePosition;
  final double noteWidth;
  final double noteHeight;
}

class NotePainter extends CustomPainter {
  NotePainter(this.notePosition, this.noteWidth, this.noteHeight, this.noteList);

  final double notePosition;
  final double noteWidth;
  final double noteHeight;
  final List<Note> noteList;

  // makeRectList(Canvas canvas, Size size, Paint notePaint, List<Note> noteList) {
  //   return List.generate(noteList.length, (i) {
  //     final Note note = noteList[i];
  //     return canvas.drawRect(
  //         Rect.fromLTWH(
  //             note.notePosition - 200, size.height / 3 - note.noteHeight / 2, note.noteWidth, note.noteHeight),
  //         notePaint);
  //   });
  // }

  @override
  void paint(Canvas canvas, Size size) {
    Paint notePaint = Paint()..color = Colors.blue;
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 100, size.height / 3 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 200, size.height / 4 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 300, size.height / 5 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 400, size.height / 4 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 500, size.height / 3 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 600, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 700, size.height / 3 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 800, size.height / 4 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 900, size.height / 5 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 1000, size.height / 4 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 1100, size.height / 3 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(Rect.fromLTWH(notePosition, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);
    canvas.drawRect(
        Rect.fromLTWH(notePosition - 1200, size.height / 2 - noteHeight / 2, noteWidth, noteHeight), notePaint);

    // makeRectList(canvas, size, notePaint, noteList);

    // List.generate(noteList.length, (i) {
    //   final Note note = noteList[i];
    //   return canvas.drawRect(
    //       Rect.fromLTWH(
    //           note.notePosition - 200, size.height / 3 - note.noteHeight / 2, note.noteWidth, note.noteHeight),
    //       notePaint);
    // }).toList();
  }

  @override
  bool shouldRepaint(NotePainter oldDelegate) {
    return oldDelegate.notePosition != notePosition;
  }
}

///
// dependencies:
// flutter_audio_query: ^4.0.0
// flame: ^1.0.0
//
// class NoteWidget extends StatelessWidget {
//   final double xPosition;
//   final double yPosition;
//   final double width;
//   final double height;
//
//   NoteWidget({
//     required this.xPosition,
//     required this.yPosition,
//     required this.width,
//     required this.height,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: NotePainter(),
//       size: Size(width, height),
//     );
//   }
// }
//
// class NotePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw your note on the canvas here
//   }
//
//   @override
//   bool shouldRepaint(NotePainter oldDelegate) {
//     return false;
//   }
// }
//
// class MyGame extends BaseGame {
//   late List<NoteWidget> notes;
//
//   @override
//   Future<void> onLoad() async {
//     // Load your audio files here using flutter_audio_query
//     // Create NoteWidgets and add them to the `notes` list
//
//     add(notes);
//
//     super.onLoad();
//   }
//
//   @override
//   void update(double dt) {
//     // Update the position of each note based on the current time and speed
//     for (var note in notes) {
//       note.xPosition += speed * dt;
//     }
//
//     super.update(dt);
//   }
// }
