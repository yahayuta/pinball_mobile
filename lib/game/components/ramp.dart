import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/pinball_game.dart'; // Added for PinballGame type

class PinballRamp extends BodyComponent with ContactCallbacks {
  final List<Vector2> vertices;
  final List<Body> _ballsInside = [];

  PinballRamp({required this.vertices});

  @override
  Body createBody() {
    final shape = ChainShape()..createChain(vertices);

    final fixtureDef = FixtureDef(shape, isSensor: true);

    final bodyDef = BodyDef(
      position: Vector2.zero(),
      type: BodyType.static,
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue.withAlpha((255 * 0.5).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final path = Path();
    path.moveTo(vertices[0].x, vertices[0].y);
    for (var i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].x, vertices[i].y);
    }

    canvas.drawPath(path, paint);
  }

    if (other is PinballBall) {
      if (_ballsInside.contains(other.body)) {
        _ballsInside.remove(other.body);
        other.body.gravityScale = Vector2(0, 1);
        (game as PinballGame).audioManager.playSoundEffect('audio/ramp_exit.wav'); // New sound effect
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final ball in _ballsInside) {
      final rampDirection = vertices[1] - vertices[0];
      rampDirection.normalize();
      final force = rampDirection * 200;
      ball.applyForce(force);
    }
  }
}
