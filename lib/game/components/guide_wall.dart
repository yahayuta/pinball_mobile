import 'package:flame_forge2d/flame_forge2d.dart';

class GuideWall extends BodyComponent {
  final List<Vector2> vertices;

  GuideWall(this.vertices);

  @override
  Body createBody() {
    final shape = ChainShape()..createChain(vertices);
    final fixtureDef = FixtureDef(shape, friction: 0.1, restitution: 0.0);
    final bodyDef = BodyDef(type: BodyType.static);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
