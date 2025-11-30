import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

class PinballTarget extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  final double width;
  final double height;
  final void Function(PinballBall)? onHit;
  final int hitsToTrigger;
  final String? id;
  int _hitCount = 0;
  Sprite? sprite;

  bool _isHit = false;
  double _hitTime = 0;
  static const double _hitDuration = 0.3; // Duration target stays "hit"

  PinballTarget({
    required this.position,
    this.width = 2.0,
    this.height = 1.0,
    this.onHit,
    this.hitsToTrigger = 1,
    this.id,
    this.sprite,
  });

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(width / 2, height / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(
      shape,
      density: 1.0,
      restitution: 0.2,
      friction: 0.5,
      userData: this,
    );

    final bodyDef = BodyDef(
      type: BodyType.static, // Targets are usually static
      position: position,
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      sprite!.renderRect(canvas, Rect.fromCenter(center: Offset.zero, width: width * 20, height: height * 20));
    } else {
      final paint = Paint()
        ..color = _isHit ? Colors.red : Colors.blueGrey
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: width * 20, // Convert to screen coordinates
        height: height * 20, // Convert to screen coordinates
      );
      canvas.drawRect(rect, paint);

      // Draw border
      paint
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(rect, paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isHit) {
      _hitTime += dt;
      if (_hitTime >= _hitDuration) {
        _isHit = false;
      }
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      _isHit = true;
      _hitTime = 0;
      _hitCount++;
      final gameRef = game as PinballGame;
      gameRef.audioManager.playSoundEffect('audio/target_hit.wav');
      if (id != null) {
        gameRef.missionManager.onObjectHit(id!);
      }
      if (onHit != null && _hitCount >= hitsToTrigger) {
        onHit!(other);
        _hitCount = 0;
      }
    }
  }
}
