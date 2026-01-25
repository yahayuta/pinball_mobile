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
    this.radius = 2.5, // 10 pixels in game scale = 0.5 meters in physics scale
    this.sprite,
    this.initialVelocity,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  Body createBody() {
    // Create a circular fixture
    final shape = CircleShape()..radius = radius;

    // Define the body characteristics
    final fixtureDef = FixtureDef(
      shape,
      density: 0.005, // Feather-light (0.005)
      restitution: 0.95, // High reactive bounce
      friction: 0.0, // frictionless
    );

    // Create the body definition
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      bullet: true, // Enable continuous collision detection
      userData: this, // For collision callbacks
      linearDamping: 0.0, // No air resistance
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
      // Center the sprite on the body
      sprite!.render(
        canvas,
        position: Vector2(-radius, -radius),
        size: Vector2.all(radius * 2),
      );
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

class PinballBumper extends BodyComponent with ContactCallbacks {
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
      restitution: 1.5, // Active kicking effect
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

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PinballBall) {
      activate();
      onHit?.call(other);
    }
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
      // Center the sprite on the body
      sprite!.render(
        canvas,
        position: Vector2(-radius, -radius),
        size: Vector2.all(radius * 2),
      );
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

  static const double flipperUpAngle = -1.5; // In radians, ~86 degrees up
  static const double flipperDownAngle = 0.6; // In radians, ~34 degrees down
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
        length / 10, // thinner thickness for better look
        Vector2(isLeft ? length / 2 : -length / 2, 0), // Pivot is at (0,0)
        0.0,
      );

    final fixtureDef = FixtureDef(
      shape,
      density: 10.0,
      restitution: 0.5, // Reduced from 1.0
      friction: 0.4, // Reduced from 0.6 for better contact
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
      ..maxMotorTorque = 100000000.0 // Very high torque for snap
      ..enableLimit = true;

    if (isLeft) {
      // Left flipper: pivots on left, body extends right
      // In this coordinate system, negative angle is UP, positive is DOWN
      jointDef.lowerAngle = -0.6; // UP limit
      jointDef.upperAngle = 0.5;  // DOWN limit
    } else {
      // Right flipper: pivots on right, body extends left
      // Here, positive angle is UP, negative is DOWN
      jointDef.lowerAngle = -0.5; // DOWN limit
      jointDef.upperAngle = 0.6;  // UP limit
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
      // Left flipper needs negative speed to go to lowerAngle (UP)
      // Right flipper needs positive speed to go to upperAngle (UP)
      _joint.motorSpeed = isLeft ? -100.0 : 100.0; 
    } else {
      // Return to resting position
      _joint.motorSpeed = isLeft ? 100.0 : -100.0;
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      final height = length / 2.5;
      
      // The body shape is defined as:
      // Vector2(isLeft ? length / 2 : -length / 2, 0)
      
      sprite!.render(
        canvas, 
        position: Vector2(isLeft ? 0 : -length, -height / 2), 
        size: Vector2(length, height)
      );
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
    debugPrint('Flipper: ${isLeft ? "LEFT" : "RIGHT"} PRESS');
    _isPressed = true;
    // Access the game instance to use _calculatePan
    // final gameRef = findGame() as PinballGame;
    audioManager.playSoundEffect(
      'audio/flipper_press.wav',
      impactForce: 1.0,
    );
  }

  void release() {
    debugPrint('Flipper: ${isLeft ? "LEFT" : "RIGHT"} RELEASE');
    _isPressed = false;
    // final gameRef = findGame() as PinballGame;
    audioManager.playSoundEffect(
      'audio/flipper_release.wav',
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
    this.radius = 8.0, // Increased from 2.0
    this.color = Colors.white,
    this.sprite, // Added sprite to constructor
  });

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      density: 1000.0, // Very heavy - effectively immovable
      restitution: 0.4, // Reduced bounciness
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
      // Center the sprite on the body
      sprite!.render(
        canvas,
        position: Vector2(-radius, -radius),
        size: Vector2.all(radius * 2),
      );
    } else {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset.zero, radius, paint);
    }
  }
}
