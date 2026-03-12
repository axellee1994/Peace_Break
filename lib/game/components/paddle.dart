import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class Paddle extends RectangleComponent with DragCallbacks {
  static const double _defaultWidth = 90.0;
  static const double _height = 14.0;
  final double screenWidth;
  double _baseWidth = _defaultWidth;

  Color? skinColor;

  Paddle({required this.screenWidth, this.skinColor})
      : super(
          size: Vector2(_defaultWidth, _height),
          anchor: Anchor.center,
          paint: Paint()..color = skinColor ?? const Color(0xFF6C63FF),
        ) {
    add(RectangleHitbox());
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.x += event.localDelta.x;
    _clamp();
  }

  void moveTo(double x) {
    position.x = x;
    _clamp();
  }

  void _clamp() {
    final half = size.x / 2;
    position.x = position.x.clamp(half, screenWidth - half);
  }

  void widen(double factor) {
    _baseWidth = size.x;
    size.x = (_baseWidth * factor).clamp(40, screenWidth * 0.8);
    paint.color = skinColor ?? const Color(0xFF6C63FF);
  }

  void resetWidth() {
    size.x = _defaultWidth;
  }

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(7),
    );
    canvas.drawRRect(rrect, paint);

    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 2, size.x - 8, 4),
        const Radius.circular(2),
      ),
      highlight,
    );
  }
}
