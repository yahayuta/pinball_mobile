import 'package:pinball_mobile/game/forge2d/custom_world.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/camera.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/launcher.dart';
import 'components/visual_effects.dart';
import 'components/power_up.dart';

import 'forge2d/pinball_body.dart';

class WallBody extends BodyComponent {
  @override
  final Vector2 position;
  final Vector2 size;
  final double angle;

  WallBody({
    required this.position,
    required this.size,
    this.angle = 0.0,
  });

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBox(
      size.x / 2,
      size.y / 2,
      Vector2.zero(),
      0,
    );
    
    final fixtureDef = FixtureDef(
      shape,
      friction: 0.3,
      restitution: 0.5,
    );

    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static,
      angle: angle,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.grey.withAlpha((255 * 0.8).toInt())
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;
    
    // Draw filled rectangle with border and glow
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.x,
      height: size.y,
    );

    // Add subtle glow
    canvas.drawRect(
      rect.inflate(2),
      paint
        ..color = Colors.blue.withAlpha((255 * 0.2).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3),
    );

    // Draw main body
    canvas.drawRect(rect, paint..color = Colors.grey.withAlpha((255 * 0.8).toInt()));
    
    // Draw border
    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.white;
    canvas.drawRect(rect, paint);
  }
}

class PinballGame extends Forge2DGame with KeyboardEvents {
  
  final List<PinballBall> balls = [];
  late final PinballFlipper leftFlipper;
  late final PinballFlipper rightFlipper;
  late final Launcher launcher;

  late HighScoreManager _highScoreManager;
  final int _highScore = 0;
  int get highScore => _highScore;
  
  // Scoring
  int score = 0;
  int combo = 0;
  double lastComboTime = 0.0;
  double maxHeightReached = 0.0;

  bool _ballSaveActive = false;
  Timer? _ballSaveTimer;
  DateTime? _ballSaveEndTime;

  int _tiltWarnings = 0;
  bool _tilted = false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  Timer? _powerUpTimer;

  bool get isBallSaveActive => _ballSaveActive;
  double get ballSaveTimeRemaining {
    if (!_ballSaveActive || _ballSaveEndTime == null) {
      return 0;
    }
    final remaining = _ballSaveEndTime!.difference(DateTime.now());
    return remaining.isNegative ? 0 : remaining.inSeconds.toDouble();
  }
  int get tiltWarnings => _tiltWarnings;
  bool get isTilted => _tilted;



  PinballGame() : super(gravity: Vector2(0, 10.0)) {
    debugMode = true;
  }

  void addScore(int points, Vector2 position) {
    score += points * (combo + 1);
    add(ScorePopup(
      position: position,
      score: points,
      combo: combo,
    ));
    if (combo > 0) {
      add(ComboEffect(
        position: Vector2(size.x / 2, size.y / 4),  // Top center of the screen
        combo: combo,
      ));
    }
  }
  
  void onBallLost(PinballBall ball) {
    balls.remove(ball);
    remove(ball);

    if (_ballSaveActive) {
      spawnBall();
      return;
    }

    if (balls.isEmpty) {
      if (!_tilted) {
        _highScoreManager.updateHighScore(score);
      }
      combo = 0;
      maxHeightReached = 0;
      _tilted = false;
      _tiltWarnings = 0;
      leftFlipper.body.setAwake(true);
      rightFlipper.body.setAwake(true);
      spawnBall();
    }
  }

  void spawnBall({Vector2? position, Vector2? velocity}) {
    final ball = PinballBall(
      initialPosition: position ?? Vector2(size.x * 0.95, size.y * 0.75),
      radius: size.x * 0.0125,
    );
    balls.add(ball);
    add(ball);
    if (velocity != null) {
      ball.body.linearVelocity = velocity;
    }
  }

  void activateBallSave() {
    _ballSaveActive = true;
    _ballSaveEndTime = DateTime.now().add(const Duration(seconds: 5));
    _ballSaveTimer?.cancel();
    _ballSaveTimer = Timer(const Duration(seconds: 5), () {
      _ballSaveActive = false;
    });
  }

  @override
  void onRemove() {
    _ballSaveTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _powerUpTimer?.cancel();
    super.onRemove();
  }



  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // camera.viewport = FixedResolutionViewport(resolution: Vector2(400, 300));
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = 10.0;
    initGameElements();
  }



  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // _initAccelerometer();
    _initPowerUpTimer();
  }

  Future<void> initGameElements() async {
    // Initialize flippers
    final flipperLength = size.x / 8;
    leftFlipper = PinballFlipper(position: Vector2(size.x * 0.3, size.y * 0.9), isLeft: true, length: flipperLength);
    rightFlipper = PinballFlipper(position: Vector2(size.x * 0.7, size.y * 0.9), isLeft: false, length: flipperLength);
    add(leftFlipper);
    add(rightFlipper);

    // Initialize launcher
    launcher = Launcher(position: Vector2(size.x * 0.95, size.y * 0.8));
    add(launcher);

    // Add walls
    add(WallBody(position: Vector2(size.x / 2, 0), size: Vector2(size.x, 1))); // Top wall
    add(WallBody(position: Vector2(size.x / 2, size.y), size: Vector2(size.x, 1))); // Bottom wall
    add(WallBody(position: Vector2(0, size.y / 2), size: Vector2(1, size.y))); // Left wall
    add(WallBody(position: Vector2(size.x, size.y / 2), size: Vector2(1, size.y))); // Right wall

    // Spawn initial ball
    spawnBall();

    // Add a test text component
    add(TextComponent(text: 'Hello Pinball!', position: Vector2(size.x / 2, size.y / 2), anchor: Anchor.center));
  }

  // void _initAccelerometer() {
  //   _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
  //     if (_tilted) {
  //       return;
  //     }
  //     final acceleration = Vector2(event.x, event.y);
  //     if (acceleration.length > 20) {
  //       _tiltWarnings++;
  //       _shakeCamera(2);
  //       if (_tiltWarnings > 2) {
  //         _tilted = true;
  //         // Disable flippers
  //         leftFlipper.body.setAwake(false);
  //         rightFlipper.body.setAwake(false);
  //       }
  //     } else if (acceleration.length > 15) {
  //       _shakeCamera(0.5);
  //     }
  //   });
  // }

  void _shakeCamera(double intensity) {
    camera.viewfinder.add(
      SequenceEffect([
        MoveByEffect(Vector2(intensity, intensity), EffectController(duration: 0.05)),
        MoveByEffect(Vector2(-intensity, -intensity), EffectController(duration: 0.05)),
      ])
    );
  }

  void _initPowerUpTimer() {
    _powerUpTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final x = (Random().nextDouble() * (size.x * 0.75)) + (size.x * 0.125);
      final y = (Random().nextDouble() * (size.y * 0.5)) + (size.y * 0.25);
      final rand = Random().nextInt(3);
      if (rand == 0) {
        add(ScorePowerUp(position: Vector2(x, y)));
      } else if (rand == 1) {
        add(MultiBallPowerUp(position: Vector2(x, y)));
      } else {
        add(BallSavePowerUp(position: Vector2(x, y)));
      }
    });
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_tilted) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      return _handleKeyDown(event.logicalKey);
    } else if (event is KeyUpEvent) {
      return _handleKeyUp(event.logicalKey);
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleKeyDown(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.keyB) {
      spawnBall();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      leftFlipper.press();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      rightFlipper.press();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.space) {
      launcher.startCharging();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleKeyUp(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowLeft) {
      leftFlipper.release();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      rightFlipper.release();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.space) {
      launcher.releaseCharge();
      activateBallSave();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}