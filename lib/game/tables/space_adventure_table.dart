import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
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

class SpaceAdventureTable extends PinballGame {
  SpaceAdventureTable({
    required super.prefs,
    required super.highScoreManager,
    required super.gameModeManager,
    required super.audioManager,
    required super.achievementManager,
  });

  @override
  Future<void> loadTableElements() async {
    await super.loadTableElements(); // Call super to load common elements

    // Spawn initial ball
    spawnBall();

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
        color: Colors.cyan,
        audioManager: audioManager,
        sprite: bumperSprite,
      ),
    );
    await add(
      PopBumper(
        position: Vector2(size.x * 0.5, size.y * 0.2),
        onHit: (ball) => addScore(50, ball.body.position),
        color: Colors.cyan,
        audioManager: audioManager,
        sprite: bumperSprite,
      ),
    );
    await add(
      PopBumper(
        position: Vector2(size.x * 0.7, size.y * 0.3),
        onHit: (ball) => addScore(50, ball.body.position),
        color: Colors.cyan,
        audioManager: audioManager,
        sprite: bumperSprite,
      ),
    );

    // Add Drop Targets
    await add(
      DropTarget(
        position: Vector2(size.x * 0.4, size.y * 0.5),
        onHit: (ball) => addScore(100, ball.body.position),
        color: Colors.pink,
        audioManager: audioManager,
        sprite: dropTargetSprite,
      ),
    );
    await add(
      DropTarget(
        position: Vector2(size.x * 0.5, size.y * 0.5),
        onHit: (ball) => addScore(100, ball.body.position),
        color: Colors.pink,
        audioManager: audioManager,
        sprite: dropTargetSprite,
      ),
    );
    await add(
      DropTarget(
        position: Vector2(size.x * 0.6, size.y * 0.5),
        onHit: (ball) => addScore(100, ball.body.position),
        color: Colors.pink,
        audioManager: audioManager,
        sprite: dropTargetSprite,
      ),
    );
  }
}
