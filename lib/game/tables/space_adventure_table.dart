import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:pinball_mobile/game/forge2d/pinball_body.dart';
import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:pinball_mobile/game/components/guide_wall.dart';
import 'package:pinball_mobile/game/components/pop_bumper.dart';
import 'package:pinball_mobile/game/components/drop_target.dart';
import 'package:pinball_mobile/game/components/spinner.dart';
import 'package:pinball_mobile/game/components/target.dart';
import 'package:pinball_mobile/game/components/rollover_switch.dart';
import 'package:pinball_mobile/game/components/slingshot.dart';
import 'package:pinball_mobile/game/components/kickback.dart';
import 'package:pinball_mobile/game/scoring_manager.dart';
import 'package:pinball_mobile/game/components/pinball_light.dart';
import 'package:pinball_mobile/game/mission_manager.dart';

class SpaceAdventureTable extends PinballGame {
  late final ScoringManager scoringManager;
  
  SpaceAdventureTable({
    required super.prefs,
    required super.highScoreManager,
    required super.gameModeManager,
    required super.audioManager,
    required super.achievementManager,
  }) {
    scoringManager = ScoringManager(this);
  }

  @override
  Future<void> loadTableElements() async {
    await super.loadTableElements(); // Call super to load common elements

    // ============================================================
    // UPPER PLAYFIELD (0-35%) - Bumpers, Spinners, Drop Targets
    // ============================================================
    
    // Top Rollover Lanes (spell bonus)
    await add(RolloverSwitch(
      id: 'lane_1',
      position: Vector2(size.x * 0.25, size.y * 0.08),
      onActivate: (ball) {
        scoringManager.hitTopLane(0);
        addScore(500, ball.body.position);
        lightManager.blink('light_lane_1', color: Colors.amber);
      },
      color: Colors.amber,
      audioManager: audioManager,
    ));
    await add(PinballLight(id: 'light_lane_1', position: Vector2(size.x * 0.25, size.y * 0.05), size: Vector2.all(2.0)));

    await add(RolloverSwitch(
      id: 'lane_2',
      position: Vector2(size.x * 0.40, size.y * 0.08),
      onActivate: (ball) {
        scoringManager.hitTopLane(1);
        addScore(500, ball.body.position);
        lightManager.blink('light_lane_2', color: Colors.amber);
      },
      color: Colors.amber,
      audioManager: audioManager,
    ));
    await add(PinballLight(id: 'light_lane_2', position: Vector2(size.x * 0.40, size.y * 0.05), size: Vector2.all(2.0)));

    await add(RolloverSwitch(
      id: 'lane_3',
      position: Vector2(size.x * 0.55, size.y * 0.08),
      onActivate: (ball) {
        scoringManager.hitTopLane(2);
        addScore(500, ball.body.position);
        lightManager.blink('light_lane_3', color: Colors.amber);
      },
      color: Colors.amber,
      audioManager: audioManager,
    ));
    await add(PinballLight(id: 'light_lane_3', position: Vector2(size.x * 0.55, size.y * 0.05), size: Vector2.all(2.0)));

    await add(RolloverSwitch(
      id: 'lane_4',
      position: Vector2(size.x * 0.70, size.y * 0.08),
      onActivate: (ball) {
        scoringManager.hitTopLane(3);
        addScore(500, ball.body.position);
        lightManager.blink('light_lane_4', color: Colors.amber);
      },
      color: Colors.amber,
      audioManager: audioManager,
    ));
    await add(PinballLight(id: 'light_lane_4', position: Vector2(size.x * 0.70, size.y * 0.05), size: Vector2.all(2.0)));

    // Pop Bumpers - Triangle formation
    await add(PopBumper(
      position: Vector2(size.x * 0.35, size.y * 0.25),
      radius: 2.5,
      onHit: (ball) => addScore(100, ball.body.position),
      color: Colors.red,
      audioManager: audioManager,
      sprite: bumperSprite,
    ));
    await add(PopBumper(
      position: Vector2(size.x * 0.65, size.y * 0.25),
      radius: 2.5,
      onHit: (ball) => addScore(100, ball.body.position),
      color: Colors.blue,
      audioManager: audioManager,
      sprite: bumperSprite,
    ));
    await add(PopBumper(
      position: Vector2(size.x * 0.50, size.y * 0.15),
      radius: 2.5,
      onHit: (ball) => addScore(100, ball.body.position),
      color: Colors.green,
      audioManager: audioManager,
      sprite: bumperSprite,
    ));

    // Spinners on sides
    await add(PinballSpinner(
      position: Vector2(size.x * 0.20, size.y * 0.20),
      width: 0.5,
      height: 4.0,
      onSpin: (score) => addScore(score, Vector2(size.x * 0.20, size.y * 0.20)),
    ));
    await add(PinballSpinner(
      position: Vector2(size.x * 0.80, size.y * 0.20),
      width: 0.5,
      height: 4.0,
      onSpin: (score) => addScore(score, Vector2(size.x * 0.80, size.y * 0.20)),
    ));

    // Drop Target Bank - 5 targets
    for (int i = 0; i < 5; i++) {
      final xPos = size.x * (0.30 + i * 0.10);
      final id = 'drop_target_$i';
      await add(DropTarget(
        id: id,
        position: Vector2(xPos, size.y * 0.40),
        onHit: (ball) {
          scoringManager.hitDropTarget(i);
          addScore(200, ball.body.position);
          lightManager.turnOn('light_$id', color: Colors.pink);
        },
        color: Colors.pink,
        audioManager: audioManager,
        sprite: dropTargetSprite,
      ));
      await add(PinballLight(id: 'light_$id', position: Vector2(xPos, size.y * 0.43), size: Vector2.all(1.5), shape: LightShape.rect));
    }

    // ============================================================
    // MID PLAYFIELD (35-70%) - Targets, Lanes, Guide Walls
    // ============================================================

    // Static Targets
    await add(PinballTarget(
      id: 'multiball_target',
      position: Vector2(size.x * 0.25, size.y * 0.55),
      hitsToTrigger: 3,
      onHit: (ball) {
        addScore(1000, Vector2(size.x * 0.25, size.y * 0.55));
        spawnBall(); // Multi-ball reward
        lightManager.pulse('light_multiball', color: Colors.red);
      },
      sprite: targetSprite,
    ));
    await add(PinballLight(id: 'light_multiball', position: Vector2(size.x * 0.25, size.y * 0.58), size: Vector2.all(2.0), shape: LightShape.triangle));

    await add(PinballTarget(
      id: 'target_left',
      position: Vector2(size.x * 0.50, size.y * 0.60),
      onHit: (ball) => addScore(300, ball.body.position),
      sprite: targetSprite,
    ));
    
    await add(PinballTarget(
      id: 'target_right',
      position: Vector2(size.x * 0.75, size.y * 0.55),
      onHit: (ball) => addScore(300, ball.body.position),
      sprite: targetSprite,
    ));

    // Guide walls to create lanes
    await add(GuideWall([
      Vector2(size.x * 0.30, size.y * 0.50),
      Vector2(size.x * 0.35, size.y * 0.65),
    ], color: Colors.cyan, restitution: 0.4));
    
    await add(GuideWall([
      Vector2(size.x * 0.70, size.y * 0.50),
      Vector2(size.x * 0.65, size.y * 0.65),
    ], color: Colors.cyan, restitution: 0.4));

    // ============================================================
    // LOWER PLAYFIELD (70-95%) - Slingshots, Inlanes, Outlanes
    // ============================================================

    // Slingshots near flippers
    await add(Slingshot(
      position: Vector2(size.x * 0.20, size.y * 0.88),
      size: Vector2(4.0, 1.0),
      angle: -0.5,
      onHit: (ball) => addScore(50, ball.body.position),
      color: Colors.red,
      audioManager: audioManager,
    ));
    await add(Slingshot(
      position: Vector2(size.x * 0.80, size.y * 0.88),
      size: Vector2(4.0, 1.0),
      angle: 0.5,
      onHit: (ball) => addScore(50, ball.body.position),
      color: Colors.red,
      audioManager: audioManager,
    ));

    // Inlane Rollover Switches
    await add(RolloverSwitch(
      id: 'inlane_left',
      position: Vector2(size.x * 0.28, size.y * 0.85),
      onActivate: (ball) => addScore(250, ball.body.position),
      color: Colors.green,
      audioManager: audioManager,
    ));
    await add(RolloverSwitch(
      id: 'inlane_right',
      position: Vector2(size.x * 0.72, size.y * 0.85),
      onActivate: (ball) => addScore(250, ball.body.position),
      color: Colors.green,
      audioManager: audioManager,
    ));

    // Kickback mechanisms in outlanes
    await add(Kickback(
      position: Vector2(size.x * 0.10, size.y * 0.85),
      isLeftSide: true,
      onActivate: (ball) => addScore(500, ball.body.position),
      audioManager: audioManager,
      cooldownSeconds: 15.0,
    ));
    await add(Kickback(
      position: Vector2(size.x * 0.90, size.y * 0.85),
      isLeftSide: false,
      onActivate: (ball) => addScore(500, ball.body.position),
      audioManager: audioManager,
      cooldownSeconds: 15.0,
    ));

    // ============================================================
    // LAUNCHER LANE - Rollover at exit
    // ============================================================
    
    await add(RolloverSwitch(
      id: 'launcher_exit',
      position: Vector2(size.x * 0.92, size.y * 0.50),
      onActivate: (ball) {
        scoringManager.awardSkillShot();
        addScore(1000, ball.body.position); // Base skill shot bonus
      },
      color: Colors.yellow,
      audioManager: audioManager,
    ));

    // Register Lights
    lightManager.registerLight('light_lane_1', children.whereType<PinballLight>().firstWhere((l) => l.id == 'light_lane_1'));
    lightManager.registerLight('light_lane_2', children.whereType<PinballLight>().firstWhere((l) => l.id == 'light_lane_2'));
    lightManager.registerLight('light_lane_3', children.whereType<PinballLight>().firstWhere((l) => l.id == 'light_lane_3'));
    lightManager.registerLight('light_lane_4', children.whereType<PinballLight>().firstWhere((l) => l.id == 'light_lane_4'));
    for (int i = 0; i < 5; i++) {
      lightManager.registerLight('light_drop_target_$i', children.whereType<PinballLight>().firstWhere((l) => l.id == 'light_drop_target_$i'));
    }
    lightManager.registerLight('light_multiball', children.whereType<PinballLight>().firstWhere((l) => l.id == 'light_multiball'));

    // Setup Missions
    _setupMissions();
  }

  void _setupMissions() {
    missionManager.addMission(Mission(
      id: 'launch_readiness',
      title: 'Launch Readiness',
      description: 'Hit all 5 drop targets to prepare for launch.',
      type: MissionType.collection,
      scoreReward: 5000,
      requiredTargetIds: ['drop_target_0', 'drop_target_1', 'drop_target_2', 'drop_target_3', 'drop_target_4'],
    ));

    missionManager.addMission(Mission(
      id: 'orbit_master',
      title: 'Orbit Master',
      description: 'Complete the top lanes sequence.',
      type: MissionType.sequence,
      scoreReward: 10000,
      requiredTargetIds: ['lane_1', 'lane_2', 'lane_3', 'lane_4'],
    ));

    // Start first mission automatically for now
    missionManager.startMission('launch_readiness');
  }
}
