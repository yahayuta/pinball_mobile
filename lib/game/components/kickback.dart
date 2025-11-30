import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/audio_manager.dart';

/// A kickback mechanism that saves the ball from outlane drains.
/// Applies a strong horizontal impulse when activated.
class Kickback extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  final Vector2 size;
  final bool isLeftSide; // true for left outlane, false for right
  final Function(PinballBall)? onActivate;
  final AudioManager audioManager;
  final double cooldownSeconds;
  
  bool _isActive = true; // Can be activated
  bool _isTriggered = false; // Currently triggering
  double _triggerTime = 0.0;
  double _cooldownTime = 0.0;
  static const _triggerDuration = 0.2;
  
  Kickback({
    required this.position,
    Vector2? size,
    required this.isLeftSide,
    this.onActivate,
    required this.audioManager,
    this.cooldownSeconds = 10.0,
  }) : size = size ?? Vector2(2.0, 3.0);

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(size.x / 2, size.y / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(
      shape,
      isSensor: true, // Sensor - detects but doesn't collide
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
    if (other is PinballBall && _isActive && !_isTriggered) {
      trigger(other);
    }
  }

  void trigger(PinballBall ball) {
    _isTriggered = true;
    _triggerTime = 0.0;
    _isActive = false;
    _cooldownTime = 0.0;
    
    // Apply strong horizontal impulse toward center with upward component
    final direction = isLeftSide ? 1.0 : -1.0;
    // Increased forces for more effective saves
    final impulse = Vector2(
      direction * 18000.0,
      -8000.0,
    );
    ball.body.applyLinearImpulse(impulse);
    
    audioManager.playSoundEffect('audio/bumper.wav', impactForce: 2.0); // Placeholder
    onActivate?.call(ball);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Handle trigger animation
    if (_isTriggered) {
      _triggerTime += dt;
      if (_triggerTime >= _triggerDuration) {
        _isTriggered = false;
      }
    }
    
    // Handle cooldown
    if (!_isActive) {
      _cooldownTime += dt;
      if (_cooldownTime >= cooldownSeconds) {
        _isActive = true;
        _cooldownTime = 0.0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    Color renderColor;
    if (_isTriggered) {
      renderColor = Colors.white;
    } else if (_isActive) {
      renderColor = Colors.green;
    } else {
      renderColor = Colors.grey;
    }
    
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.x,
      height: size.y,
    );
    
    // Draw glow when triggered
    if (_isTriggered) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.x * 1.5,
          height: size.y * 1.5,
        ),
        Paint()
          ..color = Colors.white.withAlpha((255 * 0.7).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    
    // Draw main body
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
        ..strokeWidth = 0.2,
    );
    
    // Draw arrow indicator
    if (_isActive) {
      final arrowPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.25;
      
      final arrowDirection = isLeftSide ? 1.0 : -1.0;
      final arrowX = arrowDirection * 0.5;
      
      // Arrow shaft
      canvas.drawLine(
        Offset(-arrowX, 0),
        Offset(arrowX, 0),
        arrowPaint,
      );
      
      // Arrow head
      canvas.drawLine(
        Offset(arrowX, 0),
        Offset(arrowX - arrowDirection * 0.3, -0.3),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(arrowX, 0),
        Offset(arrowX - arrowDirection * 0.3, 0.3),
        arrowPaint,
      );
    }
    
    // Draw "X" when inactive
    if (!_isActive && !_isTriggered) {
      final xPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.3;
      
      canvas.drawLine(
        Offset(-size.x * 0.3, -size.y * 0.3),
        Offset(size.x * 0.3, size.y * 0.3),
        xPaint,
      );
      canvas.drawLine(
        Offset(size.x * 0.3, -size.y * 0.3),
        Offset(-size.x * 0.3, size.y * 0.3),
        xPaint,
      );
    }
  }
}
