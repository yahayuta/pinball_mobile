import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class GuideWall extends BodyComponent {
  final List<Vector2> vertices;
  final Color color;
  final double restitution;

  GuideWall(this.vertices, {this.color = Colors.grey, this.restitution = 0.0});

  @override
  Body createBody() {
    final shape = ChainShape()..createChain(vertices);
    final fixtureDef = FixtureDef(shape, friction: 0.1, restitution: restitution);
    final bodyDef = BodyDef(type: BodyType.static);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    // Background glow
    final glowPaint = Paint()
      ..color = color.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 // Wide glow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    final Path path = Path();
    if (vertices.isNotEmpty) {
      path.moveTo(vertices[0].x, vertices[0].y);
      for (var i = 1; i < vertices.length; i++) {
        path.lineTo(vertices[i].x, vertices[i].y);
      }
    }
    
    canvas.drawPath(path, glowPaint);

    // Main neon line
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3; // Correct world units thickness
    
    canvas.drawPath(path, paint);

    // Core bright line
    paint
      ..color = Colors.white
      ..strokeWidth = 0.08;
    canvas.drawPath(path, paint);
  }
}
