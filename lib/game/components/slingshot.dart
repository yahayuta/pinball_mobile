import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/audio_manager.dart';

/// A slingshot component that actively kicks the ball when hit.
/// Positioned near flippers to create dynamic, fast-paced gameplay.
class Slingshot extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  final Vector2 size;
  @override
  final double angle;
  final Function(PinballBall)? onHit;
  final Color color;
  final AudioManager audioManager;
  
  bool _isActivated = false;
  double _activationTime = 0.0;
  static const _activationDuration = 0.15;
  
  Slingshot({
    required this.position,
    Vector2? size,
    this.angle = 0.0,
    this.onHit,
    this.color = Colors.red,
    required this.audioManager,
  }) : size = size ?? Vector2(4.0, 1.0);

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(size.x / 2, size.y / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(
      shape,
      density: 1000.0, // Very heavy - immovable
      restitution: 1.2, // Very bouncy (increased from 1.0)
      friction: 0.05, // Reduced friction for cleaner kick
      userData: this,
    );

    final bodyDef = BodyDef(
      type: BodyType.static,
      position: position,
      angle: angle,
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      activate(other);
    }
  }

  void activate(PinballBall ball) {
    _isActivated = true;
    _activationTime = 0.0;
    
    // Apply strong impulse away from slingshot with upward component
    final impulseDirection = (ball.body.position - body.position)..normalize();
    // Add upward component for more dynamic gameplay
    final adjustedDirection = Vector2(
      impulseDirection.x,
      impulseDirection.y - 0.2, // Upward bias
    )..normalize();
    final impulseStrength = 10000.0;
    ball.body.applyLinearImpulse(adjustedDirection * impulseStrength);
    
    audioManager.playSoundEffect('audio/bumper.wav', impactForce: 1.5); // Replaced slingshot.mp3 with bumper.wav as placeholder
    onHit?.call(ball);
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
    final renderColor = _isActivated ? Colors.white : color;
    
    // Draw glow effect when activated
    if (_isActivated) {
      final glowRect = Rect.fromCenter(
        center: Offset.zero,
        width: size.x * 1.3,
        height: size.y * 1.3,
      );
      canvas.drawRect(
        glowRect,
        Paint()
          ..color = renderColor.withAlpha((255 * 0.6).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    
    // Draw main slingshot body
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.x,
      height: size.y,
    );
    
    canvas.drawRect(
      rect,
      Paint()
        ..color = renderColor
        ..style = PaintingStyle.fill,
    );
    
    // Draw border
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.15,
    );
    
    // Draw diagonal stripes for visual interest
    if (!_isActivated) {
      final stripePaint = Paint()
        ..color = Colors.white.withAlpha(50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.2;
      
      for (double x = -size.x / 2; x < size.x / 2; x += 0.8) {
        canvas.drawLine(
          Offset(x, -size.y / 2),
          Offset(x + size.y, size.y / 2),
          stripePaint,
        );
      }
    }
  }
}
