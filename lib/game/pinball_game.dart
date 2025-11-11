import 'package:flame/flame.dart'; // Added
import 'dart:async';
import 'dart:math';
import 'package:flame/input.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Added
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
// import 'package:pinball_mobile/game/components/target.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';
import 'package:pinball_mobile/game/game_mode_manager.dart'; // Added
import 'components/launcher.dart';
import 'components/visual_effects.dart';
import 'components/power_up.dart';

import 'forge2d/pinball_body.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'components/wall_body.dart';
// import 'components/launcher_ramp.dart'; // Import the new LauncherRamp component

abstract class PinballGame extends Forge2DGame with KeyboardEvents implements ContactListener {
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

    rightFlipper = PinballFlipper(
      position: Vector2(size.x / 2 + size.x / 8, size.y * 0.8),
      isLeft: false,
      length: flipperLength,
      audioManager: audioManager,
      sprite: flipperRightSprite,
    );
    await add(rightFlipper);

    // Add launcher sensor
    launcher = Launcher(position: Vector2(size.x * 0.9, size.y * 0.8));
    await add(launcher);

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
  }

  // Helper: try loading an asset sprite, otherwise create a simple colored
  // placeholder image at runtime in case image files are missing from assets/images/.
  Future<Sprite> _loadSpriteOrPlaceholder(String path,
      {Color color = Colors.grey, int sizePx = 128}) async {
    try {
      final image = await Flame.images.load(path);
      return Sprite(image);
    } catch (_) {
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

  Timer? _gameModeTimer;
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
  final double _tiltThreshold = 15.0; // Example value, adjust as needed
  final double _warningThreshold = 10.0; // Example value, adjust as needed

  Timer? _powerUpTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  bool _spacebarWasPressed = false; // Flag for spacebar KeyUp workaround
  DateTime? _lastNudgeTime;



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
    await super.onLoad();
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

    if (gameModeManager.currentGameMode.type == GameModeType.timed) {
      remainingTime = gameModeManager.currentGameMode.timeLimitSeconds;
      _gameModeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        remainingTime--;
        if (remainingTime <= 0) {
          gameOver();
        }
      });
    }

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
    await loadTableElements();
  }