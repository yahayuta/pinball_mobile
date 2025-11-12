import 'package:flame/flame.dart'; // Added
import 'dart:async';

import 'package:flame/input.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for LogicalKeyboardKey, KeyDownEvent, KeyUpEvent

import 'dart:ui'; // Added
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
// import 'package:pinball_mobile/game/components/target.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';
import 'package:pinball_mobile/game/game_mode_manager.dart'; // Added
import 'components/launcher.dart';




import 'forge2d/pinball_body.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'components/wall_body.dart';
import 'components/launcher_ramp.dart'; // Import the new LauncherRamp component

class PinballGame extends Forge2DGame with KeyboardEvents implements ContactListener {
  late final List<PinballBall> balls = [];
  late PinballFlipper leftFlipper;
  late PinballFlipper rightFlipper;
  late Launcher launcher;

  late Sprite playfieldSprite; // Declared
  late Sprite wallSprite; // Declared
  late Sprite ballSprite; // Declared
  late Sprite bumperSprite; // Declared
  late Sprite flipperLeftSprite; // Declared
  late Sprite flipperRightSprite; // Declared
  late Sprite postSprite; // Declared
  late Sprite targetSprite; // Declared
  late Sprite dropTargetSprite; // Declared

  @mustCallSuper
  Future<void> loadTableElements() async {
    debugPrint('loadTableElements() START - adding flippers and launcher');
    // Add flippers
    final flipperLength = size.x / 8;
    leftFlipper = PinballFlipper(
      position: Vector2(size.x / 2 - size.x / 8, size.y * 0.8),
      isLeft: true,
      length: flipperLength,
      audioManager: audioManager,
      sprite: flipperLeftSprite,
    );
    await add(leftFlipper);
    debugPrint('Left flipper added at ${leftFlipper.position}');

    rightFlipper = PinballFlipper(
      position: Vector2(size.x / 2 + size.x / 8, size.y * 0.8),
      isLeft: false,
      length: flipperLength,
      audioManager: audioManager,
      sprite: flipperRightSprite,
    );
    await add(rightFlipper);
    debugPrint('Right flipper added at ${rightFlipper.position}');

    // Add launcher sensor
    launcher = Launcher(position: Vector2(size.x * 0.9, size.y * 0.8));
    await add(launcher);
    debugPrint('Launcher added at ${launcher.position}');

    // Add walls
    final wallThickness = size.x * 0.075;
    await add(
      WallBody(
        position: Vector2(size.x / 2, 0),
        size: Vector2(size.x, wallThickness),
        sprite: wallSprite,
      ),
    );

    await add(
      WallBody(
        position: Vector2(size.x / 2, size.y),
        size: Vector2(size.x, wallThickness),
        sprite: wallSprite,
      ),
    );

    await add(
      WallBody(
        position: Vector2(0, size.y / 2),
        size: Vector2(wallThickness, size.y),
        sprite: wallSprite,
      ),
    );

    // Right wall - split to create launch lane opening
    await add(
      WallBody(
        position: Vector2(size.x, size.y * 0.25),
        size: Vector2(wallThickness, size.y * 0.5),
        sprite: wallSprite,
      ),
    );
    await add(
      WallBody(
        position: Vector2(size.x, size.y * 0.9),
        size: Vector2(wallThickness, size.y * 0.2),
        sprite: wallSprite,
      ),
    );

    // The ramp for the ball to exit the launch lane.
    await add(
      LauncherRamp(
        position: Vector2(size.x * 0.85, size.y * 0.3),
        size: Vector2(size.x * 0.35, size.y * 0.2),
        color: Colors.blueGrey, // Default color
      ),
    );
  }

  @override
  void beginContact(Contact contact) {
    // TODO: Implement contact handling logic
  }

  @override
  void endContact(Contact contact) {
    // TODO: Implement contact handling logic
  }

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {
    // TODO: Implement post-solve logic
  }

  @override
  void preSolve(Contact contact, Manifold oldManifold) {
    // TODO: Implement pre-solve logic
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is KeyDownEvent;
    final isKeyUp = event is KeyUpEvent;

    if (isKeyDown) {
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
        leftFlipper.press();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.shiftRight || event.logicalKey == LogicalKeyboardKey.keyD) {
        rightFlipper.press();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.space) {
        launcher.startCharging();
        return KeyEventResult.handled;
      }
    } else if (isKeyUp) {
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
        leftFlipper.release();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.shiftRight || event.logicalKey == LogicalKeyboardKey.keyD) {
        rightFlipper.release();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.space) {
        launcher.releaseCharge();
        return KeyEventResult.handled;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void gameOver() {
    // Stop the game
    pauseEngine();

    // Save high score
    highScoreManager.updateHighScore(currentPlayerName, score);

    // TODO: Display game over screen or navigate to main menu
    // debugPrint('Game Over! Final Score: $score');
  }

  void _initPowerUpTimer() {
    // _powerUpTimer = Timer.periodic(const Duration(seconds: 10), (_) {
    //   // TODO: Implement power-up spawning logic
    //   // debugPrint('Power-up timer triggered!');
    // });
  }

  // void _tilt() {
  //   _tilted = true;
  //   audioManager.playSoundEffect('audio/tilt.mp3');
  //   // TODO: Implement tilt consequences (e.g., drain all balls, end game)
  //   // debugPrint('TILT! Game is tilted.');
  // }

  void addScore(int points, Vector2 position) {
    score += points;
    // TODO: Implement combo logic
    audioManager.playSoundEffect('audio/score.mp3');
    // TODO: Display score popup
    achievementManager.setProgress('score_1000', score);
  }

  void spawnBall({Vector2? initialPosition}) {
    final pos = initialPosition ?? Vector2(size.x * 0.9, size.y * 0.8);
    debugPrint('SPAWN BALL: position=$pos, ballSprite=$ballSprite');
    final ball = PinballBall(
      initialPosition: pos,
      radius: 4.0, // Very large - 4 meters = 8x bigger than original
      sprite: ballSprite,
    );
    add(ball);
    balls.add(ball);
    debugPrint('Ball added to game. Total balls: ${balls.length}');
    audioManager.playSoundEffect('audio/ball_spawn.mp3');
  }

  void activateBallSave() {
    _ballSaveActive = true;
    _ballSaveEndTime = DateTime.now().add(const Duration(seconds: 10)); // 10-second ball save
    _ballSaveTimer?.cancel(); // Cancel any existing timer
    _ballSaveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (ballSaveTimeRemaining.isNegative) {
        _ballSaveActive = false;
        timer.cancel();
      }
    });
    audioManager.playSoundEffect('audio/ball_save.mp3');
  }

  // Helper: try loading an asset sprite, otherwise create a simple colored
  // placeholder image at runtime in case image files are missing from assets/images/.
  Future<Sprite> _loadSpriteOrPlaceholder(String path,
      {Color color = Colors.grey, int sizePx = 128}) async {
    debugPrint('Attempting to load asset: $path'); // Add this line
    try {
      final image = await Flame.images.load('assets/images/$path');
      return Sprite(image);
    } catch (e) {
      debugPrint('Failed to load asset: $path, error: $e'); // Add this line
      // Create a simple square image using a PictureRecorder.
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..color = color;
      canvas.drawRect(Rect.fromLTWH(0, 0, sizePx.toDouble(), sizePx.toDouble()), paint);
      final picture = recorder.endRecording();
      final image = await picture.toImage(sizePx, sizePx);
      return Sprite(image);
    }
  }

  late final SharedPreferences prefs;
  late final HighScoreManager highScoreManager;
  late final AudioManager audioManager;
  late final AchievementManager achievementManager;
  late final GameModeManager gameModeManager;

  int score = 0;
  int combo = 0;
  double maxHeightReached = 0;

  bool _ballSaveActive = false;
  DateTime? _ballSaveEndTime;
  Timer? _ballSaveTimer;

  bool _tilted = false;
  int _tiltWarnings = 0;

  // Timer? _gameModeTimer;
  int remainingTime = 0;

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
  // final double _tiltThreshold = 15.0; // Example value, adjust as needed
  // final double _warningThreshold = 10.0; // Example value, adjust as needed

  // Timer? _powerUpTimer;
  // StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // bool _spacebarWasPressed = false; // Flag for spacebar KeyUp workaround
  // DateTime? _lastNudgeTime;



  PinballGame({
    required this.prefs,
    required this.highScoreManager,
    required this.gameModeManager,
    required this.audioManager,
    required this.achievementManager,
    this.currentPlayerName = 'Player 1',
  }) : super(gravity: Vector2(0, 40.0)) {
    debugMode = true;
  }

  late String currentPlayerName;

  @override
  Future<void> onLoad() async {
    try {
      debugPrint('=== PinballGame.onLoad() START ===');
      debugPrint('Before super.onLoad()');
      await super.onLoad();
      debugPrint('After super.onLoad() - World: $world, Size: $size');
      
      await audioManager.init();
      audioManager.playBackgroundMusic('assets/audio/background.mp3');
    // Load sprites (fall back to simple generated placeholders if images are
    // missing from assets/images/). This keeps the game runnable while the
    // artist-provided images are added later.
    playfieldSprite = await _loadSpriteOrPlaceholder('assets/images/playfield.png', color: Colors.brown, sizePx: 512);
    wallSprite = await _loadSpriteOrPlaceholder('assets/images/wall.png', color: Colors.grey, sizePx: 256);
    ballSprite = await _loadSpriteOrPlaceholder('assets/images/ball.png', color: Colors.white, sizePx: 64); // Load ball sprite
    bumperSprite = await _loadSpriteOrPlaceholder('assets/images/bumper.png', color: Colors.red, sizePx: 96); // Load bumper sprite
    flipperLeftSprite = await _loadSpriteOrPlaceholder('assets/images/flipper_left.png', color: Colors.blue, sizePx: 128); // Load left flipper sprite
    flipperRightSprite = await _loadSpriteOrPlaceholder('assets/images/flipper_right.png', color: Colors.blue, sizePx: 128); // Load right flipper sprite;
    postSprite = await _loadSpriteOrPlaceholder('assets/images/post.png', color: Colors.black, sizePx: 64); // Load post sprite
    targetSprite = await _loadSpriteOrPlaceholder('assets/images/target.png', color: Colors.purple, sizePx: 64); // Load target sprite
    dropTargetSprite = await _loadSpriteOrPlaceholder('assets/images/drop_target.png', color: Colors.orange, sizePx: 64); // Load drop target sprite

      debugPrint('Sprites loaded');

      if (gameModeManager.currentGameMode.type == GameModeType.timed) {
        remainingTime = gameModeManager.currentGameMode.timeLimitSeconds;
        // _gameModeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        //   remainingTime--;
        //   if (remainingTime <= 0) {
        //     gameOver();
        //   }
        // });
      }

      _initPowerUpTimer();
      // _accelerometerSubscription = accelerometerEventStream().listen((event) {
      //   // Simple tilt detection: if acceleration in any direction is too high
      //   // or if the device is tilted significantly.
      //   if (event.x.abs() > _tiltThreshold ||
      //       event.y.abs() > _tiltThreshold ||
      //       event.z.abs() > _tiltThreshold) {
      //     _tilt();
      //   } else if (event.x.abs() > _warningThreshold ||
      //              event.y.abs() > _warningThreshold ||
      //              event.z.abs() > _warningThreshold) {
      //     _tiltWarnings++;
      //     if (_tiltWarnings >= 3) { // 3 warnings lead to a tilt
      //       _tilt();
      //     }
      //   }
      // });
      debugPrint('About to load table elements');
      await loadTableElements();
      debugPrint('=== PinballGame.onLoad() COMPLETE ===');
    } catch (e, st) {
      debugPrint('ERROR in onLoad: $e');
      debugPrint('Stack trace: $st');
      rethrow;
    }
  }
}