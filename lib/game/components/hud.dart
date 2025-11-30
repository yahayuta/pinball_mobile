import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import '../pinball_game.dart';

class Hud extends PositionComponent with HasGameReference<PinballGame> {
  late final TextPaint _tp;
  late final TextPaint _missionTitleTp;
  late final TextPaint _missionBodyTp;
  int highScore;

  Hud({required this.highScore}) : super(
    position: Vector2(10, 10),
    anchor: Anchor.topLeft,
  ) {
    _tp = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Courier',
        fontWeight: FontWeight.bold,
      ),
    );
    _missionTitleTp = TextPaint(
      style: const TextStyle(
        color: Colors.yellowAccent,
        fontSize: 18,
        fontFamily: 'Courier',
        fontWeight: FontWeight.bold,
      ),
    );
    _missionBodyTp = TextPaint(
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontFamily: 'Courier',
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Read game state
    final launcher = game.launcher;
    final lives = game.lives;
    final score = game.score;
    final combo = game.combo;
    final charge = launcher.charge;
    final maxCharge = launcher.maxCharge;
    final ballSaveActive = game.isBallSaveActive;
    final tiltWarnings = game.tiltWarnings;
    final isTilted = game.isTilted;
    
    // Draw background for HUD (relative to component position)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, 300, 200),
        Radius.circular(8),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );

    // Build display lines
    final lines = <String>[
      'Score: $score${combo > 0 ? ' (${combo}x)' : ''}',
      'High Score: $highScore',
      'Balls: $lives',
      if (ballSaveActive)
        'Ball Save: ${(game.ballSaveTimeRemaining.inMilliseconds / 1000.0).toStringAsFixed(1)}s',
      if (isTilted) 'TILT!',
      if (!isTilted && tiltWarnings > 0) 'Warnings: $tiltWarnings',
      'Charge: ${(charge / maxCharge * 100).toStringAsFixed(0)}%',
    ];

    var y = 6.0;
    for (final l in lines) {
      _tp.render(canvas, l, Vector2(6, y));
      y += 20;
    }

    // Mission Display (relative to component position)
    if (game.missionManager.currentMission != null) {
      y += 10;
      _missionTitleTp.render(canvas, 'MISSION: ${game.missionManager.currentMission!.title}', Vector2(6, y));
      y += 22;
      _missionBodyTp.render(canvas, game.missionManager.currentMission!.description, Vector2(6, y));
      y += 18;
      _missionBodyTp.render(canvas, 'Progress: ${(game.missionManager.currentMission!.progress * 100).toStringAsFixed(0)}%', Vector2(6, y));
    } else {
      y += 10;
      _missionBodyTp.render(canvas, 'No Active Mission', Vector2(6, y));
    }
  }
}
