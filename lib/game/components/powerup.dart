import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

enum PowerUpType { extraLife, paddleWide, paddleNarrow, speedUp }

class PowerUp extends CircleComponent with CollisionCallbacks {
  final PowerUpType type;
  static const double _fallSpeed = 150.0;

  PowerUp({required Vector2 position, required this.type})
      : super(
          radius: 10,
          position: position,
          anchor: Anchor.center,
          paint: Paint()..color = _colorFor(type),
        ) {
    add(CircleHitbox());
  }

  static Color _colorFor(PowerUpType type) {
    switch (type) {
      case PowerUpType.extraLife:
        return Colors.pink;
      case PowerUpType.paddleWide:
        return Colors.cyan;
      case PowerUpType.paddleNarrow:
        return Colors.purple;
      case PowerUpType.speedUp:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (type) {
      case PowerUpType.extraLife:
        return Icons.favorite;
      case PowerUpType.paddleWide:
        return Icons.expand;
      case PowerUpType.paddleNarrow:
        return Icons.compress;
      case PowerUpType.speedUp:
        return Icons.speed;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += _fallSpeed * dt;
    if (position.y > (parent as dynamic).size.y + 20) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final tp = TextPaint(
      style: const TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
    final label = type == PowerUpType.extraLife
        ? '+'
        : type == PowerUpType.paddleWide
            ? 'W'
            : type == PowerUpType.paddleNarrow
                ? 'N'
                : 'S';
    tp.render(canvas, label, Vector2(radius, radius), anchor: Anchor.center);
  }
}
