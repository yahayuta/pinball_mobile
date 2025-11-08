import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';

class DropTarget extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  final Vector2 size;
  final Function(PinballBall)? onHit;
  final Color color;

  bool _isDown = false;
  late final PrismaticJoint _joint;

  DropTarget({
    required this.position,
    Vector2? size,
    this.onHit,
    this.color = Colors.green,
  }) : size = size ?? Vector2(1.0, 2.0);

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBox(size.x / 2, size.y / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(
      shape,
      density: 1.0,
      restitution: 0.2,
      friction: 0.3,
      userData: this,
    );

    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: position,
      userData: this,
    );

    final dropTargetBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    final anchorBody = world.createBody(BodyDef(position: position));

    final jointDef = PrismaticJointDef()
      ..initialize(anchorBody, dropTargetBody, position, Vector2(0, 1))
      ..enableLimit = true
      ..lowerTranslation = 0.0
      ..upperTranslation = size.y * 0.9
      ..enableMotor = true
      ..motorSpeed = 10.0
      ..maxMotorForce = 1000.0;

    final PrismaticJoint newJoint = PrismaticJoint(jointDef);
    world.physicsWorld.createJoint(newJoint);
    _joint = newJoint;

    return dropTargetBody;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall && !_isDown) {
      hit();
      onHit?.call(other);
    }
  }

  void hit() {
    _isDown = true;
    _joint.motorSpeed = -10.0; // Move down
    Future.delayed(const Duration(seconds: 3), () => reset());
  }

  void reset() {
    _isDown = false;
    _joint.motorSpeed = 10.0; // Move up
  }

  @override
  void render(Canvas canvas) {
    final renderColor = _isDown ? Colors.grey : color;

    final paint = Paint()
      ..color = renderColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.x,
      height: size.y,
    );

    canvas.drawRect(rect, paint);
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    canvas.drawRect(rect, paint);
  }
}
