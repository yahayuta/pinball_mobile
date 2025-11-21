import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class WallBody extends BodyComponent {
  @override
  final Vector2 position;
  final Vector2 size;
  @override
  final double angle;
  final Color color;
  final Sprite? sprite; // Added sprite property
  final double friction;
  final double restitution;

  WallBody({
    required this.position,
    required this.size,
    this.angle = 0.0,
    this.color = Colors.grey,
    this.sprite, // Added sprite to constructor
    this.friction = 0.3,
    this.restitution = 0.5,
  });

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBox(
      size.x / 2,
      size.y / 2,
      Vector2.zero(),
      0,
    );
    
    final fixtureDef = FixtureDef(
      shape,
      friction: friction,
      restitution: restitution,
    );

    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static,
      angle: angle,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      sprite!.render(canvas, position: Vector2.zero(), size: size);
    } else {
      final paint = Paint()
        ..color = color.withAlpha((255 * 0.8).toInt())
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;
      
      // Draw filled rectangle with border and glow
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      );

      // Add subtle glow
      canvas.drawRect(
        rect.inflate(2),
        paint
          ..color = color.withAlpha((255 * 0.2).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3),
      );

      // Draw main body
      canvas.drawRect(rect, paint..color = color.withAlpha((255 * 0.8).toInt()));
      
      // Draw border
      paint
        ..style = PaintingStyle.stroke
        ..color = Colors.white;
      canvas.drawRect(rect, paint);
    }
  }
}
