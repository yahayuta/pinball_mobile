import 'dart:async';
import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';

class Launcher extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  double charge = 0.0; // 0.0 .. maxCharge
  final double maxCharge;
  bool charging = false;
  final Paint _paint = Paint()..color = Colors.green;

  final List<Body> _ballsToLaunch = [];
  final Map<Body, Timer> _removalTimers = {};

  Launcher({
    required this.position,
    this.maxCharge = 1.5,
  });

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBox(
      1.0,  // 2m wide = 40px
      3.0,  // 6m tall = 120px
      Vector2.zero(),
      0,
    );
    
    final fixtureDef = FixtureDef(
      shape,
      friction: 0.3,
      restitution: 0.0,
      isSensor: true,  // Don't collide with other objects
      userData: this,
    );

    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void startCharging() {
    charging = true;
    charge = 0.0;
  }

  void increaseCharge(double dt) {
    if (!charging) return;
    charge += dt; // simple linear charge
    if (charge > maxCharge) charge = maxCharge;
  }

  double releaseCharge() {
    charging = false;
    final c = charge;
    charge = 0.0;
    for (final ball in _ballsToLaunch) {
      // Apply a strong, angled impulse DIRECTLY to the ball
      final impulse = Vector2(-c * 32000, -c * 240000);
      ball.applyLinearImpulse(impulse);
    }
    _ballsToLaunch.clear();
    return c;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (charging) {
      increaseCharge(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    // Draw launcher background with border
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: 2.0,   // 2m wide
      height: 6.0,  // 6m tall
    );
    canvas.drawRect(rect, paint);
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    canvas.drawRect(rect, paint);

    // Draw charge bar with border
    if (charge > 0) {
      final barHeight = (charge / maxCharge).clamp(0.0, 1.0) * 5.8;
      final barRect = Rect.fromLTRB(
        -0.9,               // Left (m)
        2.9 - barHeight,    // Top (m)
        0.9,                // Right (m)
        2.9,                // Bottom (m)
      );
      canvas.drawRect(barRect, _paint..style = PaintingStyle.fill);
      canvas.drawRect(barRect, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0);
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      _removalTimers[other.body]?.cancel();
      _removalTimers.remove(other.body);
      if (!_ballsToLaunch.contains(other.body)) {
        _ballsToLaunch.add(other.body);
      }
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is PinballBall) {
      final timer = Timer(const Duration(milliseconds: 100), () {
        _ballsToLaunch.remove(other.body);
        _removalTimers.remove(other.body);
      });
      _removalTimers[other.body] = timer;
    }
  }
}

