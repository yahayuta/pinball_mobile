import 'dart:async';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';

class PinballHole extends BodyComponent with ContactCallbacks {
  final Vector2 exitPosition;
  final Vector2 exitVelocity;

  PinballHole({
    required Vector2 position,
    Vector2? exitPosition,
    Vector2? exitVelocity,
  }) : exitPosition = exitPosition ?? Vector2.zero(),
        exitVelocity = exitVelocity ?? Vector2.zero(),
        super(
          bodyDef: BodyDef(
            position: position,
            type: BodyType.static,
          ),
        );

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 1.0;

    final fixtureDef = FixtureDef(
      shape,
      isSensor: true,
      userData: this,
    );

    return world.createBody(bodyDef as BodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, 1.0, paint);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      other.body.setAwake(false);
      Timer(const Duration(seconds: 1), () {
        other.body.setTransform(exitPosition, 0);
        other.body.linearVelocity = exitVelocity;
        other.body.setAwake(true);
      });
    }
  }
}
