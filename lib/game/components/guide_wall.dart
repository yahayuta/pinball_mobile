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
    // Outer glow
    final glowPaint = Paint()
      ..color = color.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    
    // Core glow (more intense)
    final coreGlowPaint = Paint()
      ..color = color.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    final Path path = Path();
    if (vertices.isNotEmpty) {
      path.moveTo(vertices[0].x, vertices[0].y);
      for (var i = 1; i < vertices.length; i++) {
        path.lineTo(vertices[i].x, vertices[i].y);
      }
    }
    
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, coreGlowPaint);

    // Main neon line
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.35;
    
    canvas.drawPath(path, paint);

    // Center sharp bright line
    paint
      ..color = Colors.white
      ..strokeWidth = 0.1;
    canvas.drawPath(path, paint);
  }
}
