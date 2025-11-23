import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

/// A rollover switch that detects when the ball passes over it.
/// Commonly used in lanes and ramps to award points and track progress.
class RolloverSwitch extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  final double radius;
  final Function(PinballBall)? onActivate;
  final Color color;
  final AudioManager audioManager;
  final String? id;
  
  bool _isActivated = false;
  double _activationTime = 0.0;
  static const _activationDuration = 0.3; // Visual feedback duration
  
  RolloverSwitch({
    required this.position,
    this.radius = 1.5,
    this.onActivate,
    this.color = Colors.yellow,
    required this.audioManager,
    this.id,
  });

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      isSensor: true, // Sensor - doesn't physically interact, just detects
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
    if (other is PinballBall && !_isActivated) {
      activate(other);
    }
  }

  void activate(PinballBall ball) {
    _isActivated = true;
    _activationTime = 0.0;
    audioManager.playSoundEffect('audio/rollover.mp3', impactForce: 0.7);
    if (id != null) {
      (game as PinballGame).missionManager.onObjectHit(id!);
    }
    onActivate?.call(ball);
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
    final renderRadius = _isActivated ? radius * 1.2 : radius;
    
    // Draw glow effect when activated
    if (_isActivated) {
      canvas.drawCircle(
        Offset.zero,
        renderRadius * 1.5,
        Paint()
          ..color = renderColor.withAlpha((255 * 0.4).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    
    // Draw main rollover body
    canvas.drawCircle(
      Offset.zero,
      renderRadius,
      Paint()
        ..color = renderColor
        ..style = PaintingStyle.fill,
    );
    
    // Draw border
    canvas.drawCircle(
      Offset.zero,
      renderRadius,
      Paint()
        ..color = Colors.white.withAlpha(_isActivated ? 255 : 150)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.2,
    );
    
    // Draw center indicator
    canvas.drawCircle(
      Offset.zero,
      renderRadius * 0.3,
      Paint()
        ..color = _isActivated ? color : Colors.white.withAlpha(100)
        ..style = PaintingStyle.fill,
    );
  }
}
