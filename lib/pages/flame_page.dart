import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'dart:math' as math;

class FlamePage extends StatelessWidget {
  const FlamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: MyGame(),
      ),
    );
  }
}

class MyGame extends FlameGame {
  SpriteComponent background = SpriteComponent();

  double elapsedTime = 0;

  @override
  void update(double dt) {
    super.update(dt);

    // 1초마다 새로운 원 추가
    elapsedTime += dt;

    if (elapsedTime > 1) {
      add(Enemy());
      elapsedTime = 0;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    add(background
      ..sprite = await loadSprite('background.png')
      ..size = size);
  }
}

class Enemy extends PositionComponent {
  Enemy()
      : super(
          position: Vector2(0, 100),
          size: Vector2(20, 20),
        );

  @override
  void update(double dt) {
    super.update(dt);

    // 오른쪽으로 이동
    position.x += 100 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 원 그리기
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(position.toOffset(), size.x, paint);
  }
}
