import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/menu/widgets/menu_button.dart'; // Import MenuButton

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  Future<void> _shareScore(BuildContext context) async {
    final highScoreManager = Provider.of<HighScoreManager>(context, listen: false);
    final highScores = highScoreManager.getHighScores();
    String message = 'Check out my Pinball high scores!\n\n';
    if (highScores.isEmpty) {
      message += 'No scores yet. Play a game!';
    } else {
      for (int i = 0; i < highScores.length; i++) {
        message += '${i + 1}. ${highScores[i].playerName}: ${highScores[i].score}\n';
      }
    }
    await Share.share(message, subject: 'Pinball High Scores');
  }

  void _inviteFriends(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite friends feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Social'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              text: 'Share Score',
              onPressed: () => _shareScore(context),
            ),
            const SizedBox(height: 20),
            MenuButton(
              text: 'Invite Friends',
              onPressed: () => _inviteFriends(context),
            ),
          ],
        ),
      ),
    );
  }
}
