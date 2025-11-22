import 'dart:async';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/pinball_game.dart'; // Added for PinballGame type

class Launcher extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  double charge = 0.0; // 0.0 .. maxCharge
  final double maxCharge;
  bool charging = false;

  final List<Body> _ballsToLaunch = [];
  final Map<Body, Timer> _removalTimers = {};

  Launcher({required this.position, this.maxCharge = 5.0});

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(
        1.0, // 2.0m wide = 40px
        3.0, // 6m tall = 120px
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.0,
      restitution: 1.2, // High bounciness but not excessive
      isSensor: false, // Allow collision so it can push the ball
      userData: this,
    );

    final bodyDef = BodyDef(position: position, type: BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void startCharging() {
    charging = true;
    charge = 0.0;
    debugPrint('Launcher: START CHARGING');
    (game as PinballGame).audioManager.playSoundEffect('audio/launcher_charge.mp3'); // New sound effect
  }

  void increaseCharge(double dt) {
    if (!charging) return;
    charge += dt * 15.0; // Increased from 10.0 for faster charge
    if (charge > maxCharge) charge = maxCharge;
    debugPrint('Launcher charge: ${(charge / maxCharge * 100).toStringAsFixed(0)}%');
  }

  double releaseCharge() {
    charging = false;
    final c = charge;
    charge = 0.0;
    debugPrint('Launcher: RELEASE with charge=$c, balls=${_ballsToLaunch.length}');
    
    // Log detailed info about balls
    debugPrint('Launcher: All balls in game: ${(game as PinballGame).balls.length}');
    for (int i = 0; i < _ballsToLaunch.length; i++) {
      debugPrint('  Ball $i: body=${_ballsToLaunch[i]}, position=${_ballsToLaunch[i].position}');
    }
    
    for (final ball in _ballsToLaunch) {
      // Apply a very strong impulse UPWARD into the playfield
      // Very high value to ensure ball reaches playfield with balanced density
      final magnitude = (c / maxCharge).clamp(0.0, 1.0) * 15000000000.0; // 15B for moderate ball weight
      final impulse = Vector2(0, -magnitude); // Purely vertical impulse
      debugPrint('Applying impulse: $impulse (magnitude=$magnitude) to ball at ${ball.position}');
      ball.applyLinearImpulse(impulse);
    }
    (game as PinballGame).audioManager.playSoundEffect('audio/launcher_release.mp3');
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
    // Draw outer launcher tube with ultra-realistic metallic finish
    final tubePaint = Paint()
      ..color = Colors.grey[900]!
      ..style = PaintingStyle.fill;

    final tubeRect = Rect.fromCenter(
      center: Offset.zero,
      width: 2.0,
      height: 6.0,
    );
    canvas.drawRect(tubeRect, tubePaint);
    
    // Draw metallic rim with beveled effect
    canvas.drawRect(
      tubeRect,
      Paint()
        ..color = Colors.grey[200]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.3,
    );
    
    // Inner bevel light
    canvas.drawLine(
      const Offset(-0.9, -2.85),
      const Offset(-0.9, 2.85),
      Paint()
        ..color = Colors.white.withAlpha(150)
        ..strokeWidth = 0.2,
    );
    
    // Inner bevel shadow
    canvas.drawLine(
      const Offset(0.9, -2.85),
      const Offset(0.9, 2.85),
      Paint()
        ..color = Colors.black.withAlpha(120)
        ..strokeWidth = 0.2,
    );

    // Draw spring plunger with enhanced realism
    if (charge > 0) {
      final chargePercent = (charge / maxCharge).clamp(0.0, 1.0);
      final plungerHeight = chargePercent * 4.8;
      final plungerTop = 2.4 - plungerHeight;
      
      final plungerRect = Rect.fromLTRB(
        -0.65,
        plungerTop,
        0.65,
        2.4,
      );
      
      // Plunger color progression
      Color plungerColor;
      if (chargePercent < 0.33) {
        plungerColor = Colors.green[400]!;
      } else if (chargePercent < 0.66) {
        plungerColor = Colors.amber[500]!;
      } else {
        plungerColor = Colors.red[400]!;
      }
      
      // Plunger main body
      canvas.drawRect(
        plungerRect,
        Paint()
          ..color = plungerColor
          ..style = PaintingStyle.fill,
      );
      
      // Plunger top highlight (beveled edge)
      canvas.drawRect(
        Rect.fromLTRB(
          plungerRect.left,
          plungerTop,
          plungerRect.right,
          plungerTop + 0.2,
        ),
        Paint()
          ..color = Colors.white.withAlpha(180)
          ..style = PaintingStyle.fill,
      );
      
      // Plunger side highlight
      canvas.drawRect(
        Rect.fromLTRB(
          plungerRect.left,
          plungerTop,
          plungerRect.left + 0.15,
          plungerRect.bottom,
        ),
        Paint()
          ..color = Colors.white.withAlpha(100)
          ..style = PaintingStyle.fill,
      );
      
      // Plunger border
      canvas.drawRect(
        plungerRect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.18,
      );
      
      // Draw compressed spring coils below plunger
      final coilStartY = 2.45;
      final coilSpacing = 0.22;
      for (int i = 0; i < 7; i++) {
        final coilY = coilStartY + (i * coilSpacing);
        if (coilY < 4.0) {
          canvas.drawCircle(
            Offset(0, coilY),
            0.26,
            Paint()
              ..color = Colors.grey[400]!
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.14,
          );
        }
      }
    } else {
      // Draw relaxed spring coils
      final coilStartY = 2.8;
      final coilSpacing = 0.45;
      for (int i = 0; i < 5; i++) {
        final coilY = coilStartY + (i * coilSpacing);
        if (coilY < 4.2) {
          canvas.drawCircle(
            Offset(0, coilY),
            0.32,
            Paint()
              ..color = Colors.grey[600]!
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.11,
          );
        }
      }
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    debugPrint('Launcher.beginContact CALLED: other=$other, other.runtimeType=${other.runtimeType}');
    debugPrint('  Contact fixture A userData: ${contact.fixtureA.userData}, B userData: ${contact.fixtureB.userData}');
    
    if (other is PinballBall) {
      debugPrint('  -> IS PinballBall! Adding to launcher!');
      _removalTimers[other.body]?.cancel();
      _removalTimers.remove(other.body);
      if (!_ballsToLaunch.contains(other.body)) {
        _ballsToLaunch.add(other.body);
        debugPrint('  -> Ball added. Total: ${_ballsToLaunch.length}');
      }
    } else {
      debugPrint('  -> NOT a PinballBall, ignoring. Type is ${other.runtimeType}');
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is PinballBall) {
      debugPrint('Launcher.endContact: removing ball');
      final timer = Timer(const Duration(milliseconds: 100), () {
        _ballsToLaunch.remove(other.body);
        _removalTimers.remove(other.body);
      });
      _removalTimers[other.body] = timer;
    }
  }
}
