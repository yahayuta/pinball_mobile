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
    required super.audioManager,
    required super.achievementManager,
    super.currentPlayerName = 'Player 1',
  });

  @override
  Future<void> loadTableElements() async {
    await super.loadTableElements(); // Call super to load common elements

    // Spawn initial ball
    this.spawnBall();

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
              onHit: (ball) => this.addScore(50, ball.body.position),
              audioManager: this.audioManager,
              sprite: this.bumperSprite,
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
              onHit: (ball) => this.addScore(100, ball.body.position),
              audioManager: this.audioManager,
              sprite: this.dropTargetSprite,
            ),
          );
          break;
        case 'PinballTarget':
          await add(
            PinballTarget(
              position: position,
              width: (componentData['width'] as double?) ?? 2.0,
              height: (componentData['height'] as double?) ?? 1.0,
              onHit: (ball) => this.addScore(100, ball.body.position),
              sprite: this.targetSprite,
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
              onSpin: (score) => this.addScore(score, position),
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
