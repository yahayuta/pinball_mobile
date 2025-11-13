import 'package:flutter/material.dart';
// import 'package:pinball_mobile/game/game_provider.dart';
import 'package:pinball_mobile/menu/high_score_screen.dart';
import 'package:pinball_mobile/menu/settings_screen.dart';
import 'package:pinball_mobile/menu/tutorial_screen.dart';
import 'package:pinball_mobile/menu/leaderboard_screen.dart';
import 'package:pinball_mobile/menu/multiplayer_screen.dart';
import 'package:pinball_mobile/menu/table_editor_screen.dart';
import 'package:pinball_mobile/menu/achievements_screen.dart';
import 'package:pinball_mobile/menu/social_screen.dart';
import 'package:pinball_mobile/menu/table_selection_screen.dart';
// import 'package:provider/provider.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pinball',
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TableSelectionScreen(),
                        ),
                      );
                    },
                    child: const Text('Select Table'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HighScoreScreen(), // Removed const
                        ),
                      );
                    },
                    child: const Text('High Scores'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: const Text('Settings'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TutorialScreen(),
                        ),
                      );
                    },
                    child: const Text('How to Play'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardScreen(),
                        ),
                      );
                    },
                    child: const Text('Leaderboard'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MultiplayerScreen(),
                        ),
                      );
                    },
                    child: const Text('Multiplayer'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TableEditorScreen(),
                        ),
                      );
                    },
                    child: const Text('Table Editor'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                    child: const Text('Achievements'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SocialScreen(),
                        ),
                      );
                    },
                    child: const Text('Social'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

