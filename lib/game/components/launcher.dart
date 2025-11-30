import 'dart:async';
import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

class Launcher extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  double charge = 0.0; // 0.0 .. maxCharge
  final double maxCharge;
  bool charging = false;
  
  // Animation state
  bool _rebounding = false;
  double _reboundTime = 0.0;

  final List<Body> _ballsToLaunch = [];
  final Map<Body, Timer> _removalTimers = {};

  Launcher({required this.position, this.maxCharge = 5.0});

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(
        (game as PinballGame).size.x * 0.05,
        10.0,
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.0,
      restitution: 1.2,
      isSensor: false,
      userData: this,
    );

    final bodyDef = BodyDef(position: position, type: BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void startCharging() {
    charging = true;
    _rebounding = false;
    charge = 0.0;
    debugPrint('Launcher: START CHARGING');
    (game as PinballGame).audioManager.playSoundEffect('audio/launcher_charge.wav');
  }

  void increaseCharge(double dt) {
    if (!charging) return;
    charge += dt * 15.0;
    if (charge > maxCharge) charge = maxCharge;
    debugPrint('Launcher charge: ${(charge / maxCharge * 100).toStringAsFixed(0)}%');
  }

  double releaseCharge() {
    charging = false;
    _rebounding = true;
    _reboundTime = 0.0;
    
    final c = charge;
    charge = 0.0;
    debugPrint('Launcher: RELEASE with charge=$c, balls=${_ballsToLaunch.length}');
    
    for (final ball in _ballsToLaunch) {
      final launchSpeed = ((c / maxCharge).clamp(0.3, 1.0)) * 200000.0;
      final velocity = Vector2(0, -launchSpeed);
      ball.linearVelocity = velocity;
      ball.setTransform(ball.position + Vector2(0, -2.0), 0);
    }
    (game as PinballGame).audioManager.playSoundEffect('audio/launcher_release.wav');
    _ballsToLaunch.clear();
    return c;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (charging) {
      increaseCharge(dt);
    }
    if (_rebounding) {
      _reboundTime += dt;
      if (_reboundTime > 1.0) {
        _rebounding = false;
        _reboundTime = 0.0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final tubePaint = Paint()
      ..color = Colors.grey[900]!
      ..style = PaintingStyle.fill;

    final tubeRect = Rect.fromCenter(
      center: Offset.zero,
      width: 2.0,
      height: 6.0,
    );
    canvas.drawRect(tubeRect, tubePaint);
    
    canvas.drawRect(
      tubeRect,
      Paint()
        ..color = Colors.grey[200]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.3,
    );
    
    canvas.drawLine(
      const Offset(-0.9, -2.85),
      const Offset(-0.9, 2.85),
      Paint()
        ..color = Colors.white.withAlpha(150)
        ..strokeWidth = 0.2,
    );
    
    canvas.drawLine(
      const Offset(0.9, -2.85),
      const Offset(0.9, 2.85),
      Paint()
        ..color = Colors.black.withAlpha(120)
        ..strokeWidth = 0.2,
    );

    double plungerOffset = 0.0;
    
    if (charging) {
      final chargePercent = (charge / maxCharge).clamp(0.0, 1.0);
      plungerOffset = chargePercent * 3.0;
    } else if (_rebounding) {
      final t = _reboundTime * 15.0;
      final decay = exp(-_reboundTime * 3.0);
      plungerOffset = sin(t) * 0.5 * decay;
    }

    final restingY = -2.0;
    final currentTipY = restingY + plungerOffset;
    
    final plungerRect = Rect.fromLTRB(
      -0.6,
      currentTipY,
      0.6,
      currentTipY + 4.0,
    );
    
    canvas.drawRect(
      plungerRect,
      Paint()..color = Colors.grey[400]!..style = PaintingStyle.fill
    );
    canvas.drawRect(
      plungerRect,
      Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth=0.1
    );
    
    canvas.drawCircle(
      Offset(0, currentTipY + 4.0),
      0.8,
      Paint()..color = Colors.red[900]!
    );
    
    final springStartY = -4.5;
    final springEndY = currentTipY;
    
    final springPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.15
      ..strokeCap = StrokeCap.round;
      
    final path = Path();
    path.moveTo(0, springStartY);
    
    final height = springEndY - springStartY;
    final effectiveHeight = height > 0.1 ? height : 0.1;
    
    final coils = 10;
    final coilHeight = effectiveHeight / coils;
    final width = 0.8;
    
    for (int i = 0; i < coils; i++) {
      final y = springStartY + i * coilHeight;
      path.lineTo(width, y + coilHeight / 2);
      path.lineTo(-width, y + coilHeight);
    }
    path.lineTo(0, springEndY);
    
    canvas.drawPath(path, springPaint);
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
