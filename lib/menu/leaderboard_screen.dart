import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final highScoreManager = context.watch<HighScoreManager>();
    final highScores = highScoreManager.getHighScores();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.black,
      ),
      body: highScores.isEmpty
          ? const Center(
              child: Text(
                'No scores yet. Play a game!',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: highScores.length,
              itemBuilder: (context, index) {
                final scoreEntry = highScores[index];
                return ListTile(
                  leading: Text(
                    '${index + 1}.',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  title: Text(
                    scoreEntry.playerName,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  trailing: Text(
                    '${scoreEntry.score}',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              },
            ),
    );
  }
}
