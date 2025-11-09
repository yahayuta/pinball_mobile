import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import '../pinball_game.dart';

class Hud extends Component with HasGameReference<PinballGame> {
  late final TextPaint _tp;
  int highScore;

  Hud({required this.highScore}) {
    _tp = TextPaint(
      style: const TextStyle(
        color: Colors.white,
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
    final balls = game.balls;
    final charge = launcher.charge;
    final maxCharge = launcher.maxCharge;
    final score = game.score;
    final combo = game.combo;
    final maxHeight = game.maxHeightReached;
    final ballSaveActive = game.isBallSaveActive;
    final tiltWarnings = game.tiltWarnings;
    final isTilted = game.isTilted;

    // Build display lines
    final lines = <String>[
      'Score: $score${combo > 0 ? ' (${combo}x combo!)' : ''}',
      'High Score: $highScore',
      'Max Height: ${maxHeight.toStringAsFixed(0)}',
      'Balls: ${balls.length}',
      if (ballSaveActive)
        'Ball Save: ${(game.ballSaveTimeRemaining.inMilliseconds / 1000.0).toStringAsFixed(1)}s',
      if (isTilted) 'TILT!',
      if (!isTilted && tiltWarnings > 0) 'Tilt Warnings: $tiltWarnings',
      '', // spacer
      'Charge: ${charge.toStringAsFixed(2)} / ${maxCharge.toStringAsFixed(2)}',
    ];

    var y = 4.0;
    for (final l in lines) {
      _tp.render(canvas, l, Vector2(8, y));
      y += 18;
    }
  }
}
