import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:pinball_mobile/game/components/launcher.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

import 'package:pinball_mobile/game/components/guide_wall.dart';
import 'package:pinball_mobile/game/components/pop_bumper.dart';
import 'package:pinball_mobile/game/components/drop_target.dart';

class DefaultPinballTable extends PinballGame {
  bool _isInitialized = false;

  @override
  Future<void> initGameElements() async {
    // This method is now empty, as the initialization is moved to onGameResize.
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (!_isInitialized) {
      _initializeGameElements(gameSize);
      _isInitialized = true;
    }
  }

  Future<void> _initializeGameElements(Vector2 gameSize) async {
    // Add a platform for the launcher
    await add(WallBody(
      position: Vector2(gameSize.x * 0.9, gameSize.y * 0.8 + 3.0),
      size: Vector2(2.0, 0.5),
    ));

    // Add initial ball, positioned just above the launcher platform
    spawnBall(position: Vector2(gameSize.x * 0.9, gameSize.y * 0.8));

    // Add flippers
    final flipperLength = gameSize.x / 15;
    leftFlipper = PinballFlipper(
      position: Vector2(gameSize.x * 0.3, gameSize.y * 0.8),
      isLeft: false,
      length: flipperLength,
    );
    await add(leftFlipper);

    rightFlipper = PinballFlipper(
      position: Vector2(gameSize.x * 0.7, gameSize.y * 0.8),
      isLeft: true,
      length: flipperLength,
    );
    await add(rightFlipper);

    // Add launcher sensor
    launcher = Launcher(position: Vector2(gameSize.x * 0.9, gameSize.y * 0.8));
    await add(launcher);

    // Add walls
    final wallThickness = gameSize.x * 0.025;
    await add(WallBody(
      position: Vector2(gameSize.x / 2, 0),
      size: Vector2(gameSize.x, wallThickness),
    ));

    await add(WallBody(
      position: Vector2(gameSize.x / 2, gameSize.y),
      size: Vector2(gameSize.x, wallThickness),
    ));

    await add(WallBody(
      position: Vector2(0, gameSize.y / 2),
      size: Vector2(wallThickness, gameSize.y),
    ));

    // Right wall - split to create launch lane opening
    await add(WallBody(
      position: Vector2(gameSize.x, gameSize.y * 0.25),
      size: Vector2(wallThickness, gameSize.y * 0.5),
    ));
    await add(WallBody(
      position: Vector2(gameSize.x, gameSize.y * 0.9),
      size: Vector2(wallThickness, gameSize.y * 0.2),
    ));

    // The ramp for the ball to exit the launch lane.
    final rampVertices = [
      Vector2(gameSize.x * 0.85, gameSize.y * 0.3), // Start point of the ramp, lower on the right
      Vector2(gameSize.x * 0.5, gameSize.y * 0.5),  // End point of the ramp, higher on the left
    ];
    await add(GuideWall(rampVertices));

    // The wall on the left of the launch lane.
    final launchLaneWallVertices = [
      Vector2(gameSize.x * 0.85, gameSize.y),      // Straight wall down to the bottom
      Vector2(gameSize.x * 0.85, gameSize.y * 0.5), // Wall stops here to leave an opening
    ];
    await add(GuideWall(launchLaneWallVertices));

    // Add a multi-ball target
    await add(
      PinballTarget(
        position: Vector2(gameSize.x * 0.75, gameSize.y * 0.33),
        hitsToTrigger: 3,
        onHit: (ball) {
          addScore(1000, Vector2(gameSize.x * 0.75, gameSize.y * 0.33));
          spawnBall();
          spawnBall();
        },
      ),
    );

    // Add Pop Bumpers
    await add(PopBumper(
      position: Vector2(gameSize.x * 0.3, gameSize.y * 0.3),
      onHit: (ball) => addScore(50, ball.body.position),
    ));
    await add(PopBumper(
      position: Vector2(gameSize.x * 0.5, gameSize.y * 0.2),
      onHit: (ball) => addScore(50, ball.body.position),
    ));
    await add(PopBumper(
      position: Vector2(gameSize.x * 0.7, gameSize.y * 0.3),
      onHit: (ball) => addScore(50, ball.body.position),
    ));

    // Add Drop Targets
    await add(DropTarget(
      position: Vector2(gameSize.x * 0.4, gameSize.y * 0.5),
      onHit: (ball) => addScore(100, ball.body.position),
    ));
    await add(DropTarget(
      position: Vector2(gameSize.x * 0.5, gameSize.y * 0.5),
      onHit: (ball) => addScore(100, ball.body.position),
    ));
    await add(DropTarget(
      position: Vector2(gameSize.x * 0.6, gameSize.y * 0.5),
      onHit: (ball) => addScore(100, ball.body.position),
    ));
  }
}
