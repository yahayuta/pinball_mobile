import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:provider/provider.dart'; // Added
import 'package:pinball_mobile/game/game_provider.dart'; // Added

class HighScoreScreen extends StatefulWidget {
  const HighScoreScreen({super.key});

  @override
  State<HighScoreScreen> createState() => _HighScoreScreenState();
}

class _HighScoreScreenState extends State<HighScoreScreen> {
  late HighScoreManager _highScoreManager; // Changed to late

  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _highScoreManager = Provider.of<GameProvider>(context, listen: false).highScoreManager; // Initialized from Provider
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final highScores = _highScoreManager.getHighScores(); // Changed to getHighScores
    setState(() {
      _highScore = highScores.isNotEmpty ? highScores.first.score : 0; // Get the top score
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('High Scores'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'High Score',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$_highScore',
              style: const TextStyle(
                fontSize: 60,
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
