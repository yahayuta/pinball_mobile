import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

class ScorePowerUp extends BodyComponent with ContactCallbacks {
  final int score;

  ScorePowerUp({required Vector2 position, this.score = 1000})
    : super(
        bodyDef: BodyDef(position: position, type: BodyType.static),
      );

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 1.0;

    final fixtureDef = FixtureDef(shape, isSensor: true, userData: this);

    return world.createBody(bodyDef as BodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, 1.0, paint);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      (game as PinballGame).addScore(score, body.position);
      (game as PinballGame).audioManager.playSoundEffect('audio/power_up_collect.mp3'); // New sound effect
      removeFromParent();
    }
  }
}



class BallSavePowerUp extends BodyComponent with ContactCallbacks {
  BallSavePowerUp({required Vector2 position})
    : super(
        bodyDef: BodyDef(position: position, type: BodyType.static),
      );

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 1.0;

    final fixtureDef = FixtureDef(shape, isSensor: true, userData: this);

    return world.createBody(bodyDef as BodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, 1.0, paint);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      (game as PinballGame).activateBallSave();
      (game as PinballGame).audioManager.playSoundEffect('audio/power_up_collect.mp3'); // New sound effect
      removeFromParent();
    }
  }
}
