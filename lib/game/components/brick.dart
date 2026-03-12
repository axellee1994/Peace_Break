import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'powerup.dart';

class Brick extends RectangleComponent with CollisionCallbacks {
  int hitPoints;
  final int maxHitPoints;
  final int scoreValue;
  final int coinValue;
  final void Function(int score, int coins) onDestroyed;
  final void Function(PowerUpType type, Vector2 position) onDropPowerUp;

  static final _rng = Random();

  Brick({
    required Vector2 position,
    required Vector2 size,
    required this.hitPoints,
    required this.onDestroyed,
    required this.onDropPowerUp,
  })  : maxHitPoints = hitPoints,
        scoreValue = hitPoints * 100,
        coinValue = hitPoints * 10,
        super(
          position: position,
          size: size,
          paint: Paint()..color = _colorFor(hitPoints),
        ) {
    add(RectangleHitbox());
  }

  static Color _colorFor(int hp) {
    switch (hp) {
      case 1:
        return const Color(0xFF4CAF50);
      case 2:
        return const Color(0xFFFF9800);
      case 3:
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9C27B0);
    }
  }

  void hit() {
    hitPoints--;
    if (hitPoints <= 0) {
      if (_rng.nextDouble() < 0.20) {
        final types = PowerUpType.values;
        final type = types[_rng.nextInt(types.length)];
        onDropPowerUp(type, center.clone());
      }
      onDestroyed(scoreValue, coinValue);
      removeFromParent();
    } else {
      paint.color = _colorFor(hitPoints);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(size.toRect(), borderPaint);
  }
}
