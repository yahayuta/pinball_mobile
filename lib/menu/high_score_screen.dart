import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/game_provider.dart';

class HighScoreScreen extends StatefulWidget {
  const HighScoreScreen({super.key});

  @override
  State<HighScoreScreen> createState() => _HighScoreScreenState();
}

class _HighScoreScreenState extends State<HighScoreScreen> {
  late HighScoreManager _highScoreManager;
  List<ScoreEntry> _highScores = []; // Changed to a list

  @override
  void initState() {
    super.initState();
    _highScoreManager = Provider.of<GameProvider>(context, listen: false).highScoreManager;
    _loadHighScores(); // Changed method name
  }

  Future<void> _loadHighScores() async {
    final highScores = _highScoreManager.getHighScores();
    setState(() {
      _highScores = highScores;
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
              'Top Scores',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _highScores.isEmpty
                  ? const Text(
                      'No high scores yet!',
                      style: TextStyle(fontSize: 20, color: Colors.white70),
                    )
                  : ListView.builder(
                      itemCount: _highScores.length,
                      itemBuilder: (context, index) {
                        final scoreEntry = _highScores[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${index + 1}. ${scoreEntry.playerName}',
                                style: const TextStyle(
                                    fontSize: 24, color: Colors.white),
                              ),
                              Text(
                                scoreEntry.score.toString(),
                                style: const TextStyle(
                                    fontSize: 24, color: Colors.yellow),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
