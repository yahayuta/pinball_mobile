import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class LauncherRamp extends BodyComponent {
  final Vector2 position;
  final Vector2 size; // Represents the overall bounding box for the ramp
  final Color color;

  LauncherRamp({
    required this.position,
    required this.size,
    this.color = Colors.blueGrey,
  });

  @override
  Body createBody() {
    final shape = PolygonShape()..set(
      [
        Vector2(0, 0), // Bottom-right
        Vector2(-size.x, 0), // Bottom-left
        Vector2(-size.x * 0.5, -size.y), // Top-left (angled)
        Vector2(0, -size.y * 0.8), // Top-right (angled)
      ],
    );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.1, // Slightly more friction than ball, but still low
      restitution: 0.7, // Good bounciness
    );

    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Render the ramp shape (for debugging/visualization)
    final path = Path();
    final shape = (body.fixtures.first.shape as PolygonShape);
    path.moveTo(shape.vertices[0].x, shape.vertices[0].y);
    for (var i = 1; i < shape.vertices.length; i++) {
      path.lineTo(shape.vertices[i].x, shape.vertices[i].y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}