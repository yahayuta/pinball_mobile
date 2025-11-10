import 'package:pinball_mobile/game/components/launcher_ramp.dart';
import 'package:flame/components.dart';
import 'package:pinball_mobile/game/components/launcher.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:pinball_mobile/game/components/wall_body.dart'; // Added for WallBody

import 'package:pinball_mobile/game/components/guide_wall.dart';
import 'package:pinball_mobile/game/components/pop_bumper.dart';
import 'package:pinball_mobile/game/components/drop_target.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pinball_mobile/game/high_score_manager.dart';
// import 'package:pinball_mobile/game/game_mode_manager.dart'; // Added

class DefaultPinballTable extends PinballGame {
  DefaultPinballTable({
    required super.prefs,
    required super.highScoreManager,
    required super.gameModeManager,
  });





  @override
  Future<void> loadTableElements() async {
    // Add a platform for the launcher
    await add(
      WallBody(
        position: Vector2(size.x * 0.9, size.y * 0.8 + 3.0),
        size: Vector2(2.0, 0.5),
        sprite: wallSprite,
      ),
    );

    // Add initial ball, positioned just above the launcher platform
    spawnBall(position: Vector2(size.x * 0.9, size.y * 0.8));

    // Add flippers
    final flipperLength = size.x / 8;
    leftFlipper = PinballFlipper(
      position: Vector2(size.x * 0.3, size.y * 0.8),
      isLeft: true,
      length: flipperLength,
      audioManager: audioManager,
      sprite: flipperLeftSprite,
    );
    await add(leftFlipper);

    rightFlipper = PinballFlipper(
      position: Vector2(size.x * 0.7, size.y * 0.8),
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

    // The ramp for the ball to exit the launch lane.
    await add(
      LauncherRamp(
        position: Vector2(size.x * 0.85, size.y * 0.3),
        size: Vector2(size.x * 0.35, size.y * 0.2),
      ),
    );

    // The wall on the left of the launch lane.
    final launchLaneWallVertices = [
      Vector2(size.x * 0.85, size.y), // Straight wall down to the bottom
      Vector2(
        size.x * 0.85,
        size.y * 0.5,
      ), // Wall stops here to leave an opening
    ];
    await add(GuideWall(launchLaneWallVertices));

    // Add a multi-ball target
    await add(
      PinballTarget(
        position: Vector2(size.x * 0.75, size.y * 0.33),
        hitsToTrigger: 3,
        onHit: (ball) {
          addScore(1000, Vector2(size.x * 0.75, size.y * 0.33));
          spawnBall();
          spawnBall();
        },
        sprite: targetSprite,
      ),
    );

    // Add Pop Bumpers
    await add(
      PopBumper(
        position: Vector2(size.x * 0.3, size.y * 0.3),
        onHit: (ball) => addScore(50, ball.body.position),
        audioManager: audioManager,
        sprite: bumperSprite,
      ),
    );
    await add(
      PopBumper(
        position: Vector2(size.x * 0.5, size.y * 0.2),
        onHit: (ball) => addScore(50, ball.body.position),
        audioManager: audioManager,
        sprite: bumperSprite,
      ),
    );
    await add(
      PopBumper(
        position: Vector2(size.x * 0.7, size.y * 0.3),
        onHit: (ball) => addScore(50, ball.body.position),
        audioManager: audioManager,
        sprite: bumperSprite,
      ),
    );

    // Add Drop Targets
    await add(
      DropTarget(
        position: Vector2(size.x * 0.4, size.y * 0.5),
        onHit: (ball) => addScore(100, ball.body.position),
        audioManager: audioManager,
        sprite: dropTargetSprite,
      ),
    );
    await add(
      DropTarget(
        position: Vector2(size.x * 0.5, size.y * 0.5),
        onHit: (ball) => addScore(100, ball.body.position),
        audioManager: audioManager,
        sprite: dropTargetSprite,
      ),
    );
    await add(
      DropTarget(
        position: Vector2(size.x * 0.6, size.y * 0.5),
        onHit: (ball) => addScore(100, ball.body.position),
        audioManager: audioManager,
        sprite: dropTargetSprite,
      ),
    );
  }
}
