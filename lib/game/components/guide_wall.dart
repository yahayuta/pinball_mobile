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
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (var i = 0; i < vertices.length - 1; i++) {
      canvas.drawLine(
        Offset(vertices[i].x, vertices[i].y),
        Offset(vertices[i + 1].x, vertices[i + 1].y),
        paint,
      );
    }
  }
}
