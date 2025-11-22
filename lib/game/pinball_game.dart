import 'dart:async';
import 'dart:math';
import 'package:flame/input.dart';
import 'package:flame/components.dart' hide Timer, FixedResolutionViewport;
import 'package:flame/camera.dart';
import 'package:flame/components.dart' show FixedResolutionViewport;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Added
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
// import 'package:pinball_mobile/game/components/target.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';
import 'package:pinball_mobile/game/game_mode_manager.dart'; // Added
import 'components/hud.dart';
import 'components/launcher.dart';
import 'components/visual_effects.dart';
import 'components/power_up.dart';
import 'package:flame/flame.dart'; // Added Flame import

import 'forge2d/pinball_body.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'components/wall_body.dart';
import 'components/guide_wall.dart';
import 'components/out_hole.dart'; // Added import
// import 'components/launcher_ramp.dart'; // Import the new LauncherRamp component

class PinballGame extends Forge2DGame with KeyboardEvents implements ContactListener {
  final List<PinballBall> balls = [];
  final Set<PinballBall> _ballsBeingRemoved = {}; // Set to track balls being removed
  late final PinballFlipper leftFlipper;
  late final PinballFlipper rightFlipper;
  late final Launcher launcher;

  late Sprite playfieldSprite; // Declared
  late Sprite wallSprite; // Declared
  late Sprite ballSprite; // Declared
  late Sprite bumperSprite; // Declared
  late Sprite flipperLeftSprite; // Declared
  late Sprite flipperRightSprite; // Declared
  late Sprite postSprite; // Declared
  late Sprite targetSprite; // Declared
  late Sprite dropTargetSprite; // Declared

  late HighScoreManager _highScoreManager;
  @visibleForTesting
  set highScoreManager(HighScoreManager value) => _highScoreManager = value;
  late final AudioManager audioManager;
  late final AchievementManager achievementManager;

  int score = 0;
  int lives = 3; // Added lives counter
  int combo = 0;
  double maxHeightReached = 0;

  bool _ballSaveActive = false;
  DateTime? _ballSaveEndTime;
  Timer? _ballSaveTimer;

  DateTime? _gameStartTime;
  Duration? _gameDuration;

  Duration get gameTimeRemaining {
    if (_gameStartTime != null && _gameDuration != null) {
      final elapsed = DateTime.now().difference(_gameStartTime!);
      final remaining = _gameDuration! - elapsed;
      return remaining.isNegative ? Duration.zero : remaining;
    }
    return Duration.zero;
  }

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



  PinballGame({
    required SharedPreferences prefs,
    required HighScoreManager highScoreManager,
    required this.gameModeManager,
    required this.audioManager,
    required this.achievementManager,
    this.currentPlayerName = 'Player 1',
  }) : _highScoreManager = highScoreManager,
       super(gravity: Vector2(0, 18.0)) { // Reduced from 25.0 for better balance with heavier ball
    debugMode = true;
  }

  final GameModeManager gameModeManager; // Declared here

  late String currentPlayerName; // Removed default initialization

  void addScore(int points, Vector2 position) {
    score += points * (combo + 1);
    audioManager.playSoundEffect('audio/score.mp3', impactForce: 1.0);
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
    if (_ballsBeingRemoved.contains(ball)) return;
    _ballsBeingRemoved.add(ball);
    
    debugPrint('Ball lost: $ball');

    // Remove from game logic immediately
    balls.remove(ball);

    // Handle game rules (lives, spawning)
    if (_ballSaveActive) {
      debugPrint('Ball save active, spawning new ball');
      spawnBall();
    } else if (balls.isEmpty) {
      lives--; // Decrement lives
      debugPrint('Lives remaining: $lives');
      
      if (lives > 0) {
        // Still have lives, spawn new ball
        spawnBall();
      } else {
        // Game Over
        debugPrint('Game Over');
        if (!_tilted) {
          _highScoreManager.updateHighScore(currentPlayerName, score);
          audioManager.playSoundEffect('audio/game_over.mp3', impactForce: 1.0);
          achievementManager.updateProgress('first_game', 1);
        }
        combo = 0;
        maxHeightReached = 0;
        _tilted = false;
        _tiltWarnings = 0;
        lives = 3; // Reset lives
        score = 0; // Reset score
        leftFlipper.body.setAwake(true);
        rightFlipper.body.setAwake(true);
        spawnBall();
      }
    }

    // Schedule physical removal for the next frame using a TimerComponent
    add(TimerComponent(
      period: 0.05,
      removeOnFinish: true,
      onTick: () {
        if (ball.isMounted) {
          debugPrint('Removing ball body: $ball');
          remove(ball);
          _ballsBeingRemoved.remove(ball);
        }
      },
    ));
  }

  void spawnBall({Vector2? position, Vector2? velocity}) {
    final ballSpawnPosition = position ?? Vector2(size.x * 0.95, size.y * 0.75);
    final ball = PinballBall(
      initialPosition: ballSpawnPosition,
      radius: size.x * 0.03,
      sprite: ballSprite, // Pass the ball sprite
      initialVelocity: velocity,
    );
    balls.add(ball);
    add(ball);
    audioManager.playSoundEffect(
      'audio/ball_spawn.mp3',
      impactForce: 1.0,
    ); // New sound effect
  }

  void activateBallSave() {
    _ballSaveActive = true;
    _ballSaveEndTime = DateTime.now().add(const Duration(seconds: 5));
    _ballSaveTimer?.cancel();
    audioManager.playSoundEffect('audio/ball_save.mp3', impactForce: 1.0); // New sound effect
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
    
    // Define the desired aspect ratio (e.g., 9:16 for portrait phones)
    const double targetAspectRatio = 9.0 / 16.0;

    // Calculate the effective game size based on the target aspect ratio
    Vector2 newGameSize;
    if (size.x / size.y > targetAspectRatio) {
      // Screen is wider than target, constrain by height
      newGameSize = Vector2(size.y * targetAspectRatio, size.y);
    } else {
      // Screen is taller than target, constrain by width
      newGameSize = Vector2(size.x, size.x / targetAspectRatio);
    }

    // Set the camera's viewport to maintain the fixed aspect ratio
    camera.viewport = FixedResolutionViewport(resolution: newGameSize);
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = 1.0; // Reset zoom to 1.0 as FixedResolutionViewport handles scaling
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await audioManager.init();
    audioManager.playBackgroundMusic('audio/background.mp3');
    
    Flame.images.prefix = '';


    // Load sprites (fall back to simple generated placeholders if images are
    // missing from assets/images/). This keeps the game runnable while the
    // artist-provided images are added later.
    playfieldSprite = await _loadSpriteOrPlaceholder('images/playfield.png', color: Colors.brown, sizePx: 512);
    wallSprite = await _loadSpriteOrPlaceholder('images/wall.png', color: Colors.grey, sizePx: 256);
    ballSprite = await _loadSpriteOrPlaceholder('images/ball.png', color: Colors.white, sizePx: 64); // Load ball sprite
    bumperSprite = await _loadSpriteOrPlaceholder('images/bumper.png', color: Colors.red, sizePx: 96); // Load bumper sprite
    flipperLeftSprite = await _loadSpriteOrPlaceholder('images/flipper_left.png', color: Colors.blue, sizePx: 128); // Load left flipper sprite
    flipperRightSprite = await _loadSpriteOrPlaceholder('images/flipper_right.png', color: Colors.blue, sizePx: 128); // Load right flipper sprite;
    postSprite = await _loadSpriteOrPlaceholder('images/post.png', color: Colors.black, sizePx: 64); // Load post sprite
    targetSprite = await _loadSpriteOrPlaceholder('images/target.png', color: Colors.purple, sizePx: 64); // Load target sprite
    dropTargetSprite = await _loadSpriteOrPlaceholder('images/drop_target.png', color: Colors.orange, sizePx: 64); // Load drop target sprite

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
    await loadTableElements(); // Call initGameElements after all sprites are loaded

    // Initialize game timer for timed modes
    if (gameModeManager.currentGameMode.type == GameModeType.timed) {
      _gameStartTime = DateTime.now();
      _gameDuration = Duration(seconds: gameModeManager.currentGameMode.timeLimitSeconds);
    }
    
    final highScores = _highScoreManager.getHighScores();
    add(Hud(highScore: highScores.isNotEmpty ? highScores.first.score : 0));
  }

  // Helper: try loading an asset sprite, otherwise create a simple colored
  // placeholder image at runtime in case image files are missing from assets/images/.
  Future<Sprite> _loadSpriteOrPlaceholder(String path,
      {Color color = Colors.grey, int sizePx = 128}) async {
    try {
      final image = await Flame.images.load(path);
      return Sprite(image);
    } catch (e) {
      debugPrint('Failed to load asset: $path, error: $e');
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

  @mustCallSuper
  Future<void> loadTableElements() async {
    // Initialize flippers
    final flipperLength = size.x / 5;
    leftFlipper = PinballFlipper(
      position: Vector2(size.x * 0.25, size.y * 0.9),
      isLeft: false,
      length: flipperLength,
      audioManager: audioManager,
      sprite: flipperLeftSprite, // Pass left flipper sprite
    );
    rightFlipper = PinballFlipper(
      position: Vector2(size.x * 0.75, size.y * 0.9),
      isLeft: true,
      length: flipperLength,
      audioManager: audioManager,
      sprite: flipperRightSprite, // Pass right flipper sprite
    );
    add(leftFlipper);
    add(rightFlipper);

    // Add a post between the flippers
    add(
      PinballPost(
        position: Vector2(size.x * 0.5, size.y * 0.95),
        sprite: postSprite, // Pass post sprite
      ),
    );

    // Initialize launcher
    launcher = Launcher(position: Vector2(size.x * 0.95, size.y * 0.8));
    add(launcher);

    // Create realistic wall layout
    _createMainPlayfieldWalls();
    _createInlaneOutlaneWalls();
    _createSlingshotWalls();
    _createLauncherLaneWalls();

    // Add bumpers with sprites
    add(
      PinballBumper(position: Vector2(size.x * 0.25, size.y * 0.25), radius: 0.5, sprite: bumperSprite),
    );
    add(
      PinballBumper(position: Vector2(size.x * 0.75, size.y * 0.25), radius: 0.5, sprite: bumperSprite),
    );
    add(
      PinballBumper(position: Vector2(size.x * 0.5, size.y * 0.15), radius: 0.5, sprite: bumperSprite),
    );
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

  // Helper method: Create main playfield boundary walls
  void _createMainPlayfieldWalls() {
    // Top wall
    add(WallBody(
      position: Vector2(size.x / 2, 0),
      size: Vector2(size.x, 1),
      restitution: 0.6,
    ));

    // Bottom wall (drain area)
    // Bottom wall (drain area) - REPLACED with OutHole
    add(OutHole(
      position: Vector2(size.x / 2, size.y + 1.0), // Slightly below visible area
      size: Vector2(size.x, 2.0), // Wide enough to catch everything
    ));

    // Left wall (full height)
    add(WallBody(
      position: Vector2(0, size.y / 2),
      size: Vector2(1, size.y),
      restitution: 0.6,
    ));

    // Left angled wall (upper section) - creates classic pinball shape
    add(GuideWall([
      Vector2(size.x * 0.05, size.y * 0.1),
      Vector2(size.x * 0.15, size.y * 0.5),
      Vector2(size.x * 0.15, size.y * 0.7),
    ], color: Colors.cyan, restitution: 0.5));

    // Right upper angled wall REMOVED to allow clear launcher lane exit path
  }

  // Helper method: Create inlane and outlane walls
  void _createInlaneOutlaneWalls() {
    // Left outlane wall (outer channel leading to drain)
    add(GuideWall([
      Vector2(size.x * 0.05, size.y * 0.7),
      Vector2(size.x * 0.08, size.y * 0.85),
      Vector2(size.x * 0.12, size.y * 0.95),
    ], color: Colors.orange, restitution: 0.4));

    // Left inlane wall (inner channel returning to flipper)
    add(GuideWall([
      Vector2(size.x * 0.15, size.y * 0.7),
      Vector2(size.x * 0.18, size.y * 0.85),
      Vector2(size.x * 0.22, size.y * 0.92),
    ], color: Colors.green, restitution: 0.3));

    // Right inlane wall (inner channel returning to flipper)
    add(GuideWall([
      Vector2(size.x * 0.85, size.y * 0.7),
      Vector2(size.x * 0.82, size.y * 0.85),
      Vector2(size.x * 0.78, size.y * 0.92),
    ], color: Colors.green, restitution: 0.3));

    // Right outlane wall (outer channel leading to drain)
    add(GuideWall([
      Vector2(size.x * 0.88, size.y * 0.7),
      Vector2(size.x * 0.88, size.y * 0.85),
      Vector2(size.x * 0.88, size.y * 0.95),
    ], color: Colors.orange, restitution: 0.4));
  }

  // Helper method: Create slingshot walls near flippers
  void _createSlingshotWalls() {
    // Left slingshot (angled wall that kicks ball energetically)
    add(WallBody(
      position: Vector2(size.x * 0.2, size.y * 0.88),
      size: Vector2(size.x * 0.08, 1),
      angle: -0.5, // Angled toward center
      color: Colors.red,
      restitution: 0.9, // Very bouncy for slingshot effect
      friction: 0.1,
    ));

    // Right slingshot (angled wall that kicks ball energetically)
    add(WallBody(
      position: Vector2(size.x * 0.8, size.y * 0.88),
      size: Vector2(size.x * 0.08, 1),
      angle: 0.5, // Angled toward center
      color: Colors.red,
      restitution: 0.9, // Very bouncy for slingshot effect
      friction: 0.1,
    ));
  }

  // Helper method: Create launcher lane walls
  void _createLauncherLaneWalls() {
    // Restore ORIGINAL working launcher lane configuration
    
    // Left wall of launcher channel (half height, allows ball exit at top)
    add(WallBody(
      position: Vector2(size.x * 0.9, size.y * 0.75),
      size: Vector2(1, size.y * 0.5),
      restitution: 0.5,
    ));
    
    // Right wall of launcher channel (full height outer boundary)
    add(WallBody(
      position: Vector2(size.x * 0.98, size.y / 2),
      size: Vector2(1, size.y),
      restitution: 0.5,
    ));
    
    // Angled wall at top of launcher lane (guides ball into playfield)
    add(WallBody(
      position: Vector2(size.x * 0.94, size.y * 0.01),
      size: Vector2(size.x * 0.08, 1),
      angle: 0.4,
      color: Colors.yellow,
      restitution: 0.6,
    ));
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
        );
        addScore(10, otherBody.position);
      } else if (otherBody is PinballTarget) {
        audioManager.playSoundEffect(
          'audio/target_hit.mp3',
          impactForce: impactForce,
        );
        addScore(5, otherBody.position);
      } else if (otherBody is PinballPost) {
        audioManager.playSoundEffect(
          'audio/spinner.mp3', // Using spinner for post hit
          impactForce: impactForce,
        );
      } else if (otherBody is PinballFlipper) {
        // Flipper sounds are handled by press/release, but we can add a subtle hit sound
        audioManager.playSoundEffect(
          'audio/flipper_press.mp3',
          impactForce: impactForce * 0.5,
        );
      } else {
        // Generic collision sound for other objects
        audioManager.playSoundEffect(
          'audio/score.mp3',
          impactForce: impactForce * 0.2,
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
      } else {
        add(BallSavePowerUp(position: Vector2(x, y)));
      }
      audioManager.playSoundEffect('audio/power_up_spawn.mp3', impactForce: 1.0); // New sound effect
    });
  }

  void _tilt() {
    _triggerTilt();
  }

  void _triggerTilt() {
    if (!_tilted) {
      _tilted = true;
      audioManager.playSoundEffect('audio/tilt.mp3', impactForce: 1.0); // Assuming a tilt sound
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

    if (balls.isNotEmpty) {
      final ballsToRemove = <PinballBall>[];
      for (final ball in balls) {
        if (ball.body.position.y > size.y + 10.0) {
          ballsToRemove.add(ball);
        }
      }
      for (final ball in ballsToRemove) {
        onBallLost(ball);
      }

      if (balls.isNotEmpty) {
        final targetPosition = balls.first.position;
        camera.viewfinder.position = targetPosition;

        // Dynamic zoom based on ball speed
        const double minZoom = 8.0;
        const double maxZoom = 12.0;
        const double minSpeed = 10.0;
        const double maxSpeed = 100.0;

        final ballSpeed = balls.first.body.linearVelocity.length;
        final zoomFactor = (ballSpeed - minSpeed) / (maxSpeed - minSpeed);
        final newZoom = lerpDouble(maxZoom, minZoom, zoomFactor.clamp(0.0, 1.0))!;
        camera.viewfinder.zoom = newZoom;
      }
    }

    // Workaround for spacebar KeyUp not being registered on web
    if (_spacebarWasPressed) {
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

    audioManager.playSoundEffect('audio/target_hit.mp3', impactForce: 1.0); // Placeholder sound
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
