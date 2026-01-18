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
      sprite!.render(
        canvas,
        position: Vector2(-width / 2, -height / 2),
        size: Vector2(width, height),
      );
    } else {
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: width,
        height: height,
      );

      // Draw background glow
      final glowPaint = Paint()
        ..color = (_isHit ? Colors.white : Colors.blue.withAlpha(100))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _isHit ? 2.0 : 1.0);
      canvas.drawRect(rect.inflate(0.2), glowPaint);

      // Main body
      final paint = Paint()
        ..shader = LinearGradient(
          colors: _isHit 
            ? [Colors.white, Colors.redAccent] 
            : [Colors.blueGrey.shade800, Colors.blueGrey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect)
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, paint);

      // Procedural detail: concentric design
      final detailPaint = Paint()
        ..color = _isHit ? Colors.white : Colors.cyanAccent.withAlpha(150)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.1;
      
      canvas.drawRect(rect.deflate(0.25), detailPaint);
      canvas.drawCircle(Offset.zero, width * 0.15, detailPaint);
      
      // Glass highlight
      final highlightPaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withAlpha(100), Colors.white.withAlpha(0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect.deflate(0.1));
      canvas.drawOval(
        Rect.fromLTWH(-width * 0.4, -height * 0.4, width * 0.5, height * 0.3),
        highlightPaint,
      );

      // Draw border with glow
      paint
        ..color = _isHit ? Colors.white : Colors.cyanAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.15;
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
