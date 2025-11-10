import 'package:flutter/material.dart';
import 'package:pinball_mobile/menu/high_score_screen.dart';
import 'package:pinball_mobile/menu/settings_screen.dart';
import 'package:pinball_mobile/menu/tutorial_screen.dart';
import 'package:pinball_mobile/menu/leaderboard_screen.dart';
import 'package:pinball_mobile/menu/multiplayer_screen.dart';
import 'package:pinball_mobile/menu/table_editor_screen.dart';
import 'package:pinball_mobile/menu/achievements_screen.dart';
import 'package:pinball_mobile/menu/social_screen.dart';
import 'package:pinball_mobile/menu/table_selection_screen.dart';
import 'package:pinball_mobile/menu/widgets/menu_button.dart'; // Import the new MenuButton

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
                  MenuButton(
                    text: 'Select Table',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TableSelectionScreen(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    text: 'High Scores',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HighScoreScreen(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    text: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    text: 'How to Play',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TutorialScreen(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    text: 'Leaderboard',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardScreen(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    text: 'Multiplayer',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MultiplayerScreen(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    text: 'Table Editor',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TableEditorScreen(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    text: 'Achievements',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    text: 'Social',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SocialScreen(),
                        ),
                      );
                    },
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

