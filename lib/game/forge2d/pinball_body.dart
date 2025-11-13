import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../components/visual_effects.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
// import 'package:pinball_mobile/game/pinball_game.dart'; // Added
export '../components/target.dart' show PinballTarget;

class PinballBall extends BodyComponent {
  final Vector2 initialPosition;
  final double radius;
  final Sprite? sprite;
  final Vector2? initialVelocity;

  PinballBall({
    required this.initialPosition,
    this.radius = 0.5, // 10 pixels in game scale = 0.5 meters in physics scale
    this.sprite,
    this.initialVelocity,
  });

  @override
  Body createBody() {
    // Create a circular fixture
    final shape = CircleShape()..radius = radius;

    // Define the body characteristics
    final fixtureDef = FixtureDef(
      shape,
      density: 1.0,
      restitution: 0.9, // Reduced bounciness for realism
      friction: 0.3, // Increased friction
    );

    // Create the body definition
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      bullet: true, // Enable continuous collision detection
      userData: this, // For collision callbacks
    );

    final body = world.createBody(bodyDef)..createFixture(fixtureDef);

    if (initialVelocity != null) {
      body.linearVelocity = initialVelocity!;
    }

    return body;
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      sprite!.render(canvas, position: Vector2.zero(), size: Vector2.all(radius * 2));
    } else {
      final paint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;

      // Draw filled circle with border
      canvas.drawCircle(Offset.zero, radius, paint);
      paint.style = PaintingStyle.stroke;
      paint.color = Colors.white;
      canvas.drawCircle(Offset.zero, radius, paint);

      // Draw a line to indicate spin
      canvas.save();
      canvas.rotate(body.angularVelocity * 0.05); // Rotate based on angular velocity
      canvas.drawLine(
        Offset(0, -radius * 0.8),
        Offset(0, radius * 0.8),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 0.1,
      );
      canvas.restore();
    }
  }
}

class PinballBumper extends BodyComponent {
  @override
  final Vector2 position;
  final double radius;
  final Function(PinballBall)? onHit;
  final Color color;
  final Sprite? sprite; // Added sprite property
  bool _isActivated = false;
  double _activationTime = 0.0;
  static const _activationDuration = 0.15; // seconds

  PinballBumper({
    required this.position,
    this.radius = 1.0,
    this.onHit,
    this.color = Colors.blue,
    this.sprite, // Added sprite to constructor
  });

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      density: 1000.0, // Very heavy - effectively immovable
      restitution: 1.0, // Perfectly elastic collision
      friction: 0.2,
      userData: this,
    );

    final bodyDef = BodyDef(
      type: BodyType.static,
      position: position,
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void activate() {
    _isActivated = true;
    _activationTime = 0.0;
    parent?.add(BumperHitEffect(position: position, color: color));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isActivated) {
      _activationTime += dt;
      if (_activationTime >= _activationDuration) {
        _isActivated = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      sprite!.render(canvas, position: Vector2.zero(), size: Vector2.all(radius * 2));
    } else {
      final renderColor = _isActivated ? Colors.yellow : color;
      final glowRadius = _isActivated ? radius * 1.2 : radius;

      // Draw glow effect when activated
      if (_isActivated) {
        canvas.drawCircle(
          Offset.zero,
          glowRadius,
          Paint()
            ..color = renderColor.withAlpha((255 * 0.3).toInt())
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }

      // Draw main bumper body
      final paint = Paint()
        ..color = renderColor
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;

      // Draw filled circle with border
      canvas.drawCircle(Offset.zero, radius, paint);
      paint.style = PaintingStyle.stroke;
      paint.color = Colors.white;
      canvas.drawCircle(Offset.zero, radius, paint);
    }
  }
}

class PinballFlipper extends BodyComponent {
  @override
  final Vector2 position;
  final bool isLeft;
  final double length;
  final Color color;
  final AudioManager audioManager;
  final Sprite? sprite; // Added sprite property

  static const double flipperUpAngle = -0.6; // In radians, ~35 degrees up
  static const double flipperDownAngle = 0.2; // In radians, ~12 degrees down
  bool _isPressed = false;

  late final RevoluteJoint _joint;

  PinballFlipper({
    required this.position,
    required this.isLeft,
    this.length = 2.0,
    this.color = Colors.purple,
    required this.audioManager,
    this.sprite, // Added sprite to constructor
  });

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(
        length / 2,
        length / 5, // thickness
        Vector2(isLeft ? -length / 2 : length / 2, 0),
        0.0,
      );

    final fixtureDef = FixtureDef(
      shape,
      density: 10.0,
      restitution: 0.3,
      friction: 0.6,
    );

    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: position,
      userData: this,
    );

    final flipperBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    final anchorBody = world.createBody(BodyDef(position: position));

    final jointDef = RevoluteJointDef()
      ..initialize(anchorBody, flipperBody, position)
      ..enableMotor = true
      ..motorSpeed = 0.0
      ..maxMotorTorque = 1000000000.0 // Increased max motor torque
      ..enableLimit = true;

    if (isLeft) {
      jointDef.lowerAngle = flipperUpAngle;
      jointDef.upperAngle = flipperDownAngle;
    } else {
      jointDef.lowerAngle = -flipperDownAngle;
      jointDef.upperAngle = -flipperUpAngle;
    }

    final RevoluteJoint newJoint = RevoluteJoint(jointDef);
    world.physicsWorld.createJoint(newJoint);
    _joint = newJoint;

    return flipperBody;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isPressed) {
      _joint.motorSpeed = isLeft ? -40.0 : 40.0;
    } else {
      _joint.motorSpeed = isLeft ? 40.0 : -40.0;
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      sprite!.render(canvas, position: Vector2.zero(), size: Vector2(length, length / 2.5));
    } else {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;

      // Draw filled rectangle with border
      final rect = Rect.fromCenter(
        center: Offset(isLeft ? -length / 2 : length / 2, 0),
        width: length,
        height: length / 2.5,
      );
      canvas.drawRect(rect, paint);
      paint.style = PaintingStyle.stroke;
      paint.color = Colors.white;
      canvas.drawRect(rect, paint);
    }
  }

  void press() {
    _isPressed = true;
    // Access the game instance to use _calculatePan
    // final gameRef = findGame() as PinballGame;
    audioManager.playSoundEffect(
      'audio/flipper_press.mp3',
      impactForce: 1.0,
    );
  }

  void release() {
    _isPressed = false;
    // final gameRef = findGame() as PinballGame;
    audioManager.playSoundEffect(
      'audio/flipper_release.mp3',
      impactForce: 1.0,
    );
  }
}

class PinballPost extends BodyComponent {
  @override
  final Vector2 position;
  final double radius;
  final Color color;
  final Sprite? sprite; // Added sprite property

  PinballPost({
    required this.position,
    this.radius = 0.2,
    this.color = Colors.white,
    this.sprite, // Added sprite to constructor
  });

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      density: 1000.0, // Very heavy - effectively immovable
      restitution: 0.6, // Increased bounciness
      friction: 0.2,
    );

    final bodyDef = BodyDef(
      type: BodyType.static,
      position: position,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      sprite!.render(canvas, position: Vector2.zero(), size: Vector2.all(radius * 2));
    } else {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset.zero, radius, paint);
    }
  }
}