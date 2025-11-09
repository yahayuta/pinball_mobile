import 'dart:async';
import 'dart:math';
import 'package:flame/input.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart'; // For @visibleForTesting
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
import 'package:pinball_mobile/game/components/target.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';
import 'package:pinball_mobile/game/game_mode_manager.dart'; // Added
import 'components/launcher.dart';
import 'components/visual_effects.dart';
import 'components/power_up.dart';

import 'forge2d/pinball_body.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'components/wall_body.dart';
import 'components/launcher_ramp.dart'; // Import the new LauncherRamp component

class PinballGame extends Forge2DGame with KeyboardEvents implements ContactListener {
  final List<PinballBall> balls = [];
  late final PinballFlipper leftFlipper;
  late final PinballFlipper rightFlipper;
  late final Launcher launcher;

  @visibleForTesting
  late HighScoreManager _highScoreManager;
  @visibleForTesting
  set highScoreManager(HighScoreManager value) => _highScoreManager = value;
  late final AudioManager audioManager;
  late final AchievementManager achievementManager;

  int score = 0;
  int combo = 0;
  double maxHeightReached = 0;

  bool _ballSaveActive = false;
  DateTime? _ballSaveEndTime;
  Timer? _ballSaveTimer;

  bool _tilted = false;
  int _tiltWarnings = 0;

  bool get isBallSaveActive => _ballSaveActive;
  int get tiltWarnings => _tiltWarnings;
  bool get isTilted => _tilted;
  Duration get ballSaveTimeRemaining {
    if (_ballSaveActive && _ballSaveEndTime != null) {
      final remaining = _ballSaveEndTime!.difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    }
    return Duration.zero;
  }
  final double _tiltThreshold = 15.0; // Example value, adjust as needed
  final double _warningThreshold = 10.0; // Example value, adjust as needed

  Timer? _powerUpTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  bool _spacebarWasPressed = false; // Flag for spacebar KeyUp workaround
  DateTime? _lastNudgeTime;

  double calculatePan(double xPosition) {
    return (xPosition / size.x) * 2 - 1;
  }

  PinballGame({
    required SharedPreferences prefs,
    required HighScoreManager highScoreManager,
    required this.gameModeManager, // Added
    String currentPlayerName = 'Player 1', // Added
  }) : _highScoreManager = highScoreManager,
       audioManager = AudioManager(),
       achievementManager = AchievementManager(prefs),
       super(gravity: Vector2(0, 40.0)) {
    debugMode = true;
    this.currentPlayerName = currentPlayerName; // Set the player name
  }

  final GameModeManager gameModeManager; // Declared here

  late String currentPlayerName; // Removed default initialization

  void addScore(int points, Vector2 position) {
    score += points * (combo + 1);
    audioManager.playSoundEffect('audio/score.mp3', impactForce: 1.0, pan: 0.0);
    add(ScorePopup(position: position, score: points, combo: combo));
    achievementManager.setProgress('score_1000', score); // Update score achievement
    if (combo > 0) {
      add(
        ComboEffect(
          position: Vector2(size.x / 2, size.y / 4), // Top center of the screen
          combo: combo,
        ),
      );
      achievementManager.setProgress('combo_5', combo); // Update combo achievement
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
        _highScoreManager.updateHighScore(currentPlayerName, score); // Pass player name
        audioManager.playSoundEffect('audio/game_over.mp3', impactForce: 1.0, pan: 0.0); // New sound effect
        achievementManager.updateProgress('first_game', 1); // Update first game achievement
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
    final ballSpawnPosition = position ?? Vector2(size.x * 0.95, size.y * 0.85);
    final ball = PinballBall(
      initialPosition: ballSpawnPosition,
      radius: size.x * 0.0125,
    );
    balls.add(ball);
    add(ball);
    audioManager.playSoundEffect(
      'audio/ball_spawn.mp3',
      impactForce: 1.0,
      pan: calculatePan(ballSpawnPosition.x),
    ); // New sound effect
    if (velocity != null) {
      ball.body.linearVelocity = velocity;
    }
  }

  void activateBallSave() {
    _ballSaveActive = true;
    _ballSaveEndTime = DateTime.now().add(const Duration(seconds: 5));
    _ballSaveTimer?.cancel();
    audioManager.playSoundEffect('audio/ball_save.mp3', impactForce: 1.0, pan: 0.0); // New sound effect
    _ballSaveTimer = Timer(const Duration(seconds: 5), () {
      _ballSaveActive = false;
    });
  }

  @override
  void onRemove() {
    _ballSaveTimer?.cancel();
    _powerUpTimer?.cancel();
    _accelerometerSubscription?.cancel();
    audioManager.dispose();
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
    await audioManager.init();
    audioManager.playBackgroundMusic('audio/background.mp3');
    _initPowerUpTimer();
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      // Simple tilt detection: if acceleration in any direction is too high
      // or if the device is tilted significantly.
      if (event.x.abs() > _tiltThreshold ||
          event.y.abs() > _tiltThreshold ||
          event.z.abs() > _tiltThreshold) {
        _tilt();
      } else if (event.x.abs() > _warningThreshold ||
                 event.y.abs() > _warningThreshold ||
                 event.z.abs() > _warningThreshold) {
        _tiltWarnings++;
        if (_tiltWarnings >= 3) { // 3 warnings lead to a tilt
          _tilt();
        }
      }
    });
  }

  Future<void> initGameElements() async {
    // Initialize flippers
    final flipperLength = size.x / 8;
    leftFlipper = PinballFlipper(
      position: Vector2(size.x * 0.3, size.y * 0.9),
      isLeft: true,
      length: flipperLength,
      audioManager: audioManager,
    );
    rightFlipper = PinballFlipper(
      position: Vector2(size.x * 0.7, size.y * 0.9),
      isLeft: false,
      length: flipperLength,
      audioManager: audioManager,
    );
    add(leftFlipper);
    add(rightFlipper);

    // Add a post between the flippers
    add(
      PinballPost(
        position: Vector2(size.x * 0.5, size.y * 0.95),
      ),
    );

    // Initialize launcher
    launcher = Launcher(position: Vector2(size.x * 0.95, size.y * 0.8));
    add(launcher);

    // Add walls
    add(
      WallBody(position: Vector2(size.x / 2, 0), size: Vector2(size.x, 1)),
    ); // Top wall
    add(
      WallBody(position: Vector2(size.x / 2, size.y), size: Vector2(size.x, 1)),
    ); // Bottom wall
    add(
      WallBody(position: Vector2(0, size.y / 2), size: Vector2(1, size.y)),
    ); // Left wall
    // Dedicated launcher channel
    add(
      WallBody(position: Vector2(size.x * 0.975, size.y * 0.95), size: Vector2(size.x * 0.05, size.y * 0.1)),
    ); // Small wall at the bottom right to contain the ball
    /*
    add(
      LauncherRamp(
        position: Vector2(size.x, size.y * 0.8), // Bottom-right corner of the ramp
        size: Vector2(size.x * 0.15, size.y * 0.6), // Width and height of the ramp
      ),
    );
    */

    // Spawn initial ball
    spawnBall(velocity: Vector2(0, -50));

  }

  @override
  void beginContact(Contact contact) {
    // Handle contact start events if needed
  }

  @override
  void endContact(Contact contact) {
    // Handle contact end events if needed
  }

  @override
  void preSolve(Contact contact, Manifold oldManifold) {
    // Handle pre-solve events if needed
  }

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {
    final Object? objectA = contact.fixtureA.userData;
    final Object? objectB = contact.fixtureB.userData;

    PinballBall? ball;
    Object? otherBody;

    if (objectA is PinballBall) {
      ball = objectA;
      otherBody = objectB;
    } else if (objectB is PinballBall) {
      ball = objectB;
      otherBody = objectA;
    }

    if (ball != null && otherBody != null) {
      final double impact = impulse.normalImpulses.reduce(max);
      final double impactForce = (impact / 100.0).clamp(0.0, 1.0); // Normalize impact to 0-1 range

      if (otherBody is PinballBumper) {
        otherBody.activate();
        audioManager.playSoundEffect(
          ['audio/bumper.mp3', 'audio/score.mp3'],
          impactForce: impactForce,
          pan: calculatePan(otherBody.position.x),
        );
        addScore(10, otherBody.position);
      } else if (otherBody is PinballTarget) {
        audioManager.playSoundEffect(
          'audio/target_hit.mp3',
          impactForce: impactForce,
          pan: calculatePan(otherBody.position.x),
        );
        addScore(5, otherBody.position);
      } else if (otherBody is PinballPost) {
        audioManager.playSoundEffect(
          'audio/spinner.mp3', // Using spinner for post hit
          impactForce: impactForce,
          pan: calculatePan(otherBody.position.x),
        );
      } else if (otherBody is PinballFlipper) {
        // Flipper sounds are handled by press/release, but we can add a subtle hit sound
        audioManager.playSoundEffect(
          'audio/flipper_press.mp3',
          impactForce: impactForce * 0.5,
          pan: calculatePan(otherBody.position.x),
        );
      } else {
        // Generic collision sound for other objects
        audioManager.playSoundEffect(
          'audio/score.mp3',
          impactForce: impactForce * 0.2,
          pan: calculatePan(ball.position.x),
        );
      }
    }
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
      audioManager.playSoundEffect('audio/power_up_spawn.mp3', impactForce: 1.0, pan: calculatePan(x)); // New sound effect
    });
  }

  @visibleForTesting
  void _tilt() {
    _triggerTilt();
  }

  void _triggerTilt() {
    if (!_tilted) {
      _tilted = true;
      audioManager.playSoundEffect('audio/tilt.mp3', impactForce: 1.0, pan: 0.0); // Assuming a tilt sound
      // Optionally, add a visual "TILT" message
      add(
        TextComponent(
          text: 'TILT!',
          position: Vector2(size.x / 2, size.y / 2),
          anchor: Anchor.center,
          priority: 10,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 24.0,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      // Stop all balls and flippers
      for (final ball in balls) {
        ball.body.linearVelocity = Vector2.zero();
        ball.body.angularVelocity = 0;
      }
      leftFlipper.body.setAwake(false);
      rightFlipper.body.setAwake(false);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Workaround for spacebar KeyUp not being registered on web
    if (_spacebarWasPressed && !RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.space)) {
      launcher.releaseCharge();
      activateBallSave();
      _spacebarWasPressed = false;
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
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

  void _nudge(bool isLeft) {
    if (_tilted) return;

    _tiltWarnings++;
    if (_tiltWarnings >= 3) {
      _tilt();
      return;
    }

    final now = DateTime.now();
    if (_lastNudgeTime != null && now.difference(_lastNudgeTime!).inSeconds > 2) {
      _tiltWarnings = 1;
    }
    _lastNudgeTime = now;


    final strength = 20000.0;
    final x = isLeft ? strength : -strength;
    final impulse = Vector2(x, 0);
    for (final ball in balls) {
      ball.body.applyLinearImpulse(impulse);
    }

    audioManager.playSoundEffect('audio/target_hit.mp3', impactForce: 1.0, pan: 0.0); // Placeholder sound
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
      _spacebarWasPressed = true; // Set flag for workaround
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.shiftLeft) {
      _nudge(true);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.shiftRight) {
      _nudge(false);
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
      _spacebarWasPressed = false; // Reset flag
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
