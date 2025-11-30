import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

class PinballSpinner extends BodyComponent with ContactCallbacks {
  final double width;
  final double height;
  final Function(int score) onSpin;

  PinballSpinner({
    required Vector2 position,
    this.width = 1.0,
    this.height = 5.0,
    required this.onSpin,
  }) : super(
         bodyDef: BodyDef(position: position, type: BodyType.dynamic),
       );

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(width / 2, height / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(
      shape,
      density: 1.0,
      restitution: 0.5,
      friction: 0.5,
      userData: this,
    );

    final body = world.createBody(bodyDef as BodyDef)
      ..createFixture(fixtureDef);

    final staticBody = world.createBody(BodyDef());
    final RevoluteJointDef<Body, Body> revoluteJointDef = RevoluteJointDef()
      ..initialize(staticBody, body, body.position);
    world.createJoint(RevoluteJoint(revoluteJointDef));

    return body;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );
    canvas.drawRect(rect, paint);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      onSpin(100);
      (game as PinballGame).audioManager.playSoundEffect('audio/spinner.wav');
    }
  }
}
