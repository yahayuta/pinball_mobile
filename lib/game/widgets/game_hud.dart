import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

class GameHud extends StatefulWidget {
  final PinballGame game;

  const GameHud({super.key, required this.game});

  @override
  State<GameHud> createState() => _GameHudState();
}

class _GameHudState extends State<GameHud> {
  @override
  void initState() {
    super.initState();
    // Update HUD periodically
    Future.delayed(const Duration(milliseconds: 500), _startUpdating);
  }

  void _startUpdating() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
        _startUpdating();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Don't render until game is initialized
    if (!_isGameReady()) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 90,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3), // More transparent
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF00FFFF).withValues(alpha: 0.6), // Semi-transparent border
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatText('SCORE', '${widget.game.score}', const Color(0xFF00FFFF)),
          const SizedBox(height: 4),
          _buildStatText('HIGH', '${_getHighScore()}', const Color(0xFFFF00FF)),
          const SizedBox(height: 4),
          _buildStatText('BALLS', '${widget.game.lives}', Colors.white),
          const SizedBox(height: 4),
          _buildStatText('COMBO', '${widget.game.combo}x', const Color(0xFF9D00FF)),
          const SizedBox(height: 6),
          _buildChargeBar(),
          if (widget.game.isBallSaveActive) ...[
            const SizedBox(height: 6),
            _buildBallSaveIndicator(),
          ],
          if (widget.game.isTilted) ...[
            const SizedBox(height: 6),
            _buildTiltWarning(),
          ],
        ],
      ),
    );
  }

  bool _isGameReady() {
    try {
      // Check if critical game components are initialized
      final _ = widget.game.launcher;
      return true;
    } catch (e) {
      return false;
    }
  }

  int _getHighScore() {
    try {
      final scores = widget.game.highScoreManager.getHighScores();
      return scores.isNotEmpty ? scores.first.score : 0;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildStatText(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 6,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _buildChargeBar() {
    try {
      final chargePercent = (widget.game.launcher.charge / widget.game.launcher.maxCharge).clamp(0.0, 1.0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'POWER',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 6,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 10,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00FFFF), width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: LinearProgressIndicator(
                value: chargePercent,
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FFFF)),
              ),
            ),
          ),
          Text(
            '${(chargePercent * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 7,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBallSaveIndicator() {
    final remaining = widget.game.ballSaveTimeRemaining.inMilliseconds / 1000.0;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF00FF00).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF00FF00).withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        'SAVE: ${remaining.toStringAsFixed(1)}s',
        style: const TextStyle(
          color: Color(0xFF00FF00),
          fontSize: 6,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
        ),
      ),
    );
  }

  Widget _buildTiltWarning() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withValues(alpha: 0.6), width: 1),
      ),
      child: const Text(
        'TILT!',
        style: TextStyle(
          color: Colors.red,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
        ),
      ),
    );
  }
}
