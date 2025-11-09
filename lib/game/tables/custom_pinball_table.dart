import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
import 'package:pinball_mobile/game/components/drop_target.dart';
import 'package:pinball_mobile/game/components/guide_wall.dart';
import 'package:pinball_mobile/game/components/hole.dart';
import 'package:pinball_mobile/game/components/launcher.dart';
import 'package:pinball_mobile/game/components/pop_bumper.dart';
import 'package:pinball_mobile/game/components/ramp.dart';
import 'package:pinball_mobile/game/components/spinner.dart';
// import 'package:pinball_mobile/game/components/target.dart';
import 'package:pinball_mobile/game/components/wall_body.dart';
// import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:pinball_mobile/game/table_config_manager.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pinball_mobile/game/game_mode_manager.dart'; // Added
import 'package:pinball_mobile/game/forge2d/pinball_body.dart'; // Added

class CustomPinballTable extends PinballGame {
  final TableConfig tableConfig;
  CustomPinballTable({
    required this.tableConfig,
    required super.prefs,
    required super.highScoreManager,
    required super.gameModeManager,
    super.currentPlayerName = 'Player 1',
  });

  @override
  Future<void> loadTableElements() async {
    // Add flippers and launcher (common to all tables)
    final flipperLength = size.x / 8;
    leftFlipper = PinballFlipper(
      position: Vector2(size.x * 0.3, size.y * 0.9),
      isLeft: true,
      length: flipperLength,
      audioManager: audioManager,
      sprite: flipperLeftSprite,
    );
    await add(leftFlipper);

    rightFlipper = PinballFlipper(
      position: Vector2(size.x * 0.7, size.y * 0.9),
      isLeft: false,
      length: flipperLength,
      audioManager: audioManager,
      sprite: flipperRightSprite,
    );
    await add(rightFlipper);

    launcher = Launcher(position: Vector2(size.x * 0.95, size.y * 0.8));
    await add(launcher);

    // Add walls (common to all tables)
    final wallThickness = size.x * 0.075;
    await add(
      WallBody(position: Vector2(size.x / 2, 0), size: Vector2(size.x, wallThickness), sprite: wallSprite),
    ); // Top wall
    await add(
      WallBody(position: Vector2(size.x / 2, size.y), size: Vector2(size.x, wallThickness), sprite: wallSprite),
    ); // Bottom wall
    await add(
      WallBody(position: Vector2(0, size.y / 2), size: Vector2(wallThickness, size.y), sprite: wallSprite),
    ); // Left wall
    await add(
      WallBody(position: Vector2(size.x, size.y / 2), size: Vector2(wallThickness, size.y), sprite: wallSprite),
    ); // Right wall

    // Spawn initial ball
    spawnBall();

    // Dynamically add components from tableConfig
    for (final componentData in tableConfig.components) {
      final type = componentData['type'] as String;
      final positionData = componentData['position'] as Map<String, dynamic>;
      final position = Vector2(positionData['x'] as double, positionData['y'] as double);

      switch (type) {
        case 'PopBumper':
          await add(
            PopBumper(
              position: position,
              radius: (componentData['radius'] as double?) ?? 2.0,
              onHit: (ball) => addScore(50, ball.body.position),
              audioManager: audioManager,
              sprite: bumperSprite,
            ),
          );
          break;
        case 'DropTarget':
          await add(
            DropTarget(
              position: position,
              size: Vector2(
                (componentData['size']['x'] as double?) ?? 2.0,
                (componentData['size']['y'] as double?) ?? 4.0,
              ),
              onHit: (ball) => addScore(100, ball.body.position),
              audioManager: audioManager,
              sprite: dropTargetSprite,
            ),
          );
          break;
        case 'PinballTarget':
          await add(
            PinballTarget(
              position: position,
              width: (componentData['width'] as double?) ?? 2.0,
              height: (componentData['height'] as double?) ?? 1.0,
              onHit: (ball) => addScore(100, ball.body.position),
              sprite: targetSprite,
            ),
          );
          break;
        case 'PinballHole':
          await add(
            PinballHole(
              position: position,
              exitPosition: Vector2(
                (componentData['exitPosition']['x'] as double?) ?? size.x * 0.95,
                (componentData['exitPosition']['y'] as double?) ?? size.y * 0.75,
              ),
              exitVelocity: Vector2(
                (componentData['exitVelocity']['x'] as double?) ?? 0,
                (componentData['exitVelocity']['y'] as double?) ?? 0,
              ),
            ),
          );
          break;
        case 'PinballSpinner':
          await add(
            PinballSpinner(
              position: position,
              width: (componentData['width'] as double?) ?? 1.0,
              height: (componentData['height'] as double?) ?? 5.0,
              onSpin: (score) => addScore(score, position),
            ),
          );
          break;
        case 'GuideWall':
          final verticesData = componentData['vertices'] as List<dynamic>;
          final vertices = verticesData
              .map((v) => Vector2(v['x'] as double, v['y'] as double))
              .toList();
          await add(GuideWall(vertices));
          break;
        case 'PinballRamp':
          final verticesData = componentData['vertices'] as List<dynamic>;
          final vertices = verticesData
              .map((v) => Vector2(v['x'] as double, v['y'] as double))
              .toList();
          await add(PinballRamp(vertices: vertices));
          break;
        // Add other component types as needed
      }
    }
  }
}
