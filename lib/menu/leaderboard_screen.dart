import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/menu/widgets/leaderboard_entry_widget.dart'; // Import the new widget

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
                return LeaderboardEntryWidget(
                  rank: index + 1,
                  scoreEntry: scoreEntry,
                );
              },
            ),
    );
  }
}
