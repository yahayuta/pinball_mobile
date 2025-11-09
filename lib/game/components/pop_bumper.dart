import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/components/visual_effects.dart';
import 'package:pinball_mobile/game/audio_manager.dart';

class PopBumper extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  final double radius;
  final Function(PinballBall)? onHit;
  final Color color;
  final AudioManager audioManager;

  bool _isActivated = false;
  double _activationTime = 0.0;
  static const _activationDuration = 0.15; // seconds

  PopBumper({
    required this.position,
    this.radius = 2.0,
    this.onHit,
    this.color = Colors.orange,
    required this.audioManager,
  });

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      density: 1000.0, // Very heavy - effectively immovable
      restitution: 2.0, // Extra bouncy to propel the ball
      friction: 0.1,
      userData: this,
    );

    final bodyDef = BodyDef(
      type: BodyType.static,
      position: position,
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      activate();
      // Apply impulse to the ball
      final impulseDirection = (other.body.position - body.position)
        ..normalize();
      other.body.applyLinearImpulse(impulseDirection * 5000);
      onHit?.call(other);
    }
  }

  void activate() {
    _isActivated = true;
    _activationTime = 0.0;
    audioManager.playSoundEffect('audio/bumper.mp3');
    parent?.add(BumperHitEffect(position: position, color: color));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isActivated) {
      _activationTime += dt;
      if (_activationTime >= _activationDuration) {
        _isActivated = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final renderColor = _isActivated ? Colors.yellow : color;
    final glowRadius = _isActivated ? radius * 1.2 : radius;

    // Draw glow effect when activated
    if (_isActivated) {
      canvas.drawCircle(
        Offset.zero,
        glowRadius,
        Paint()
          ..color = renderColor.withAlpha((255 * 0.3).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Draw main bumper body
    final paint = Paint()
      ..color = renderColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    // Draw filled circle with border
    canvas.drawCircle(Offset.zero, radius, paint);
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    canvas.drawCircle(Offset.zero, radius, paint);
  }
}
