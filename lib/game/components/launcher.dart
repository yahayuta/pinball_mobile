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
        1.0, // 2m wide = 40px
        3.0, // 6m tall = 120px
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.3,
      restitution: 0.9, // Make it bouncy so it launches the ball
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
    charge += dt * 10.0; // simple linear charge
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
      // Apply a strong impulse UPWARD into the playfield
      // X: negative (left), Y: large positive (upward)
      final magnitude = (c / maxCharge).clamp(0.0, 1.0) * 50000000.0; // Scale based on charge
      final impulse = Vector2(-magnitude * 0.3, -magnitude); // Mostly upward
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
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    // Draw launcher background with border
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: 2.0, // 2m wide
      height: 6.0, // 6m tall
    );
    canvas.drawRect(rect, paint);
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    canvas.drawRect(rect, paint);

    // Draw charge bar with border
    if (charge > 0) {
      final barHeight = (charge / maxCharge).clamp(0.0, 1.0) * 5.8;
      final barRect = Rect.fromLTRB(
        -0.9, // Left (m)
        2.9 - barHeight, // Top (m)
        0.9, // Right (m)
        2.9, // Bottom (m)
      );
      Color barColor;
      if (charge / maxCharge < 0.33) {
        barColor = Colors.green;
      } else if (charge / maxCharge < 0.66) {
        barColor = Colors.yellow;
      } else {
        barColor = Colors.red;
      }
      canvas.drawRect(barRect, Paint()..color = barColor..style = PaintingStyle.fill);
      canvas.drawRect(
        barRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
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
