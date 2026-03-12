import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'paddle.dart';
import 'brick.dart';

class Ball extends CircleComponent with CollisionCallbacks {
  static const double _defaultSpeed = 320.0;
  double speed;
  Vector2 velocity;
  final void Function() onFallOff;

  Color? skinColor;

  Ball({required Vector2 startPosition, this.skinColor, required this.onFallOff})
      : speed = _defaultSpeed,
        velocity = Vector2(0, -1),
        super(
          radius: 8,
          position: startPosition,
          anchor: Anchor.center,
          paint: Paint()..color = skinColor ?? Colors.white,
        ) {
    final angle = (Random().nextDouble() * 60 - 30) * (pi / 180);
    velocity = Vector2(sin(angle), -cos(angle));
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * speed * dt;

    final parentSize = (parent as dynamic).size as Vector2;

    if (position.x - radius <= 0) {
      position.x = radius;
      velocity.x = velocity.x.abs();
    } else if (position.x + radius >= parentSize.x) {
      position.x = parentSize.x - radius;
      velocity.x = -velocity.x.abs();
    }

    if (position.y - radius <= 0) {
      position.y = radius;
      velocity.y = velocity.y.abs();
    }

    if (position.y - radius > parentSize.y) {
      onFallOff();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Brick) {
      other.hit();
      _reflectOff(other);
    } else if (other is Paddle) {
      _reflectOffPaddle(other);
    }
  }

  void _reflectOff(Brick brick) {
    final brickCenter = brick.position + brick.size / 2;
    final diff = position - brickCenter;
    if (diff.x.abs() / brick.size.x > diff.y.abs() / brick.size.y) {
      velocity.x = -velocity.x;
    } else {
      velocity.y = -velocity.y;
    }
    _normalizeVelocity();
  }

  void _reflectOffPaddle(Paddle paddle) {
    final relativeX =
        (position.x - paddle.position.x) / paddle.size.x; // 0..1
    final angle = (relativeX - 0.5) * pi * 0.7; // -63..+63 degrees
    velocity = Vector2(sin(angle), -cos(angle).abs());
    _normalizeVelocity();
  }

  void _normalizeVelocity() {
    if (velocity.length > 0) velocity.normalize();
  }

  void setSpeed(double newSpeed) => speed = newSpeed;
  void resetSpeed() => speed = _defaultSpeed;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius * 0.4, radius * 0.4), radius * 0.3, shinePaint);
  }
}
