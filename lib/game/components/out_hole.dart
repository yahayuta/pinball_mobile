import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';

class OutHole extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  final Vector2 size;

  OutHole({
    required this.position,
    required this.size,
  });

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(
        size.x / 2,
        size.y / 2,
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(
      shape,
      isSensor: true, // Sensor so ball passes through
      userData: this,
    );

    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static,
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      (game as PinballGame).onBallLost(other);
    }
  }
}
