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
  Timer? _autoLaunchTimer;

  Launcher({required this.position, this.maxCharge = 40.0});

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(
        (game as PinballGame).size.x * 0.05, 
        15.0, // Reduced detection zone height (was 50)
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.0,
      restitution: 0.0, // Zero restitution to stop bouncing
      isSensor: true, // Use sensor to avoid physical interference
      userData: this,
    );

    final bodyDef = BodyDef(position: position, type: BodyType.static);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void startCharging() {
    if (charging || _ballsToLaunch.isEmpty) return;
    charging = true;
    _rebounding = false;
    charge = 0.0;
    debugPrint('Launcher: START CHARGING for ${_ballsToLaunch.length} balls');
    (game as PinballGame).audioManager.playSoundEffect('audio/launcher_charge.wav');
  }

  void increaseCharge(double dt) {
    if (!charging) return;
    charge += dt * 80.0; // Slower charging for better control
    if (charge > maxCharge) charge = maxCharge;
  }

  double releaseCharge() {
    final balls = List<Body>.from(_ballsToLaunch);
    charging = false;
    _rebounding = true;
    _reboundTime = 0.0;
    
    final c = charge;
    charge = 0.0;
    
    debugPrint('Launcher: RELEASE with charge=$c, balls=${balls.length}');
    
    for (final ball in balls) {
      if (!ball.isAwake) ball.setAwake(true);
      // Now that ball mass (density 0.005) is correct for its radius (15),
      // we can use standard linearVelocity safely. Forge2D has velocity caps, 
      // usually around 120 units/sec, so attempting 500,000 was causing 
      // the solver to clamp the speed (hence -36 in logs).
      final launchSpeed = ((c / maxCharge).clamp(0.6, 1.0)) * 180.0; // Increased base speed
      debugPrint('Launcher: Applying velocity $launchSpeed to $ball');
      ball.linearVelocity = Vector2(0, -launchSpeed); // Pure vertical
      ball.angularVelocity = 0.0; 
      
      // Temporarily remove gravity so the ball reaches the deflector curve without slowing down
      ball.gravityScale = Vector2.zero();

    }
    
    (game as PinballGame).audioManager.playSoundEffect('audio/launcher_release.wav');
    _ballsToLaunch.clear(); // Clear to prevent immediate rapid-fire
    return c;
  }

  @override
  void render(Canvas canvas) {
    // Render the VISUAL plunger (static/animating) - separate from detection zone
    final tubePaint = Paint()..color = Colors.grey[900]!..style = PaintingStyle.fill;
    final tubeRect = Rect.fromCenter(center: Offset.zero, width: 2.0, height: 6.0);
    canvas.drawRect(tubeRect, tubePaint);

    double plungerOffset = 0.0;
    if (charging) {
      plungerOffset = (charge / maxCharge).clamp(0.0, 1.0) * 3.0;
    } else if (_rebounding) {
      plungerOffset = sin(_reboundTime * 15.0) * 0.5 * exp(-_reboundTime * 3.0);
    }

    final currentTipY = -2.0 + plungerOffset;
    final plungerRect = Rect.fromLTRB(-0.6, currentTipY, 0.6, currentTipY + 4.0);
    canvas.drawRect(plungerRect, Paint()..color = Colors.grey[400]!);
    canvas.drawCircle(Offset(0, currentTipY + 4.0), 0.8, Paint()..color = Colors.red[900]!);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      debugPrint('Launcher: Ball sensed');
      if (!_ballsToLaunch.contains(other.body)) {
        _ballsToLaunch.add(other.body);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (charging) {
      increaseCharge(dt);
      if (charge >= maxCharge) {
        releaseCharge();
        (game as PinballGame).activateBallSave();
      }
    }
    
    if (_rebounding) {
      _reboundTime += dt;
      if (_reboundTime > 1.0) {
        _rebounding = false;
        _reboundTime = 0.0;
      }
    }
    
    // Auto-fire with delay to allow manual control first
    if (_ballsToLaunch.isNotEmpty && !charging && !_rebounding && _autoLaunchTimer == null) {
      _autoLaunchTimer = Timer(const Duration(milliseconds: 1000), () { // Reduced from 2500 for higher frequency
        if (_ballsToLaunch.isNotEmpty && !charging) {
          startCharging();
        }
        _autoLaunchTimer = null;
      });
    } else if (_ballsToLaunch.isEmpty) {
      _autoLaunchTimer?.cancel();
      _autoLaunchTimer = null;
    }
  }

  @override
  void onRemove() {
    _autoLaunchTimer?.cancel();
    super.onRemove();
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is PinballBall) {
      // Immediate removal to allow re-sensing if it falls back quickly
      if (!_ballsToLaunch.contains(other.body)) return;
      if (other.body.linearVelocity.y < -1.0) {
          _ballsToLaunch.remove(other.body);
          debugPrint('Launcher: Ball departed');
      }
    }
  }
}
