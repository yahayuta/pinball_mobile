import 'package:flutter/material.dart';
import 'package:pinball_mobile/menu/high_score_screen.dart';
import 'package:pinball_mobile/menu/settings_screen.dart';
import 'package:pinball_mobile/menu/tutorial_screen.dart';
import 'package:pinball_mobile/menu/table_selection_screen.dart';
import 'package:pinball_mobile/menu/menu_theme.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/menu_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay for better text readability
          Container(
            color: Colors.black.withValues(alpha: 0.6),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PINBALL',
                  style: GameMenuTheme.titleStyle,
                ),
                Text(
                  'ARCADE',
                  style: GameMenuTheme.titleStyle.copyWith(
                    fontSize: 32,
                    color: GameMenuTheme.secondaryColor,
                    shadows: [
                      const Shadow(
                        blurRadius: 10.0,
                        color: GameMenuTheme.secondaryColor,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                // Primary action
                SizedBox(
                  width: 280,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TableSelectionScreen(),
                        ),
                      );
                    },
                    style: GameMenuTheme.primaryButtonStyle,
                    child: Text(
                      'PLAY',
                      style: GameMenuTheme.buttonTextStyle,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Secondary actions
                SizedBox(
                  width: 240,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HighScoreScreen(),
                            ),
                          );
                        },
                        style: GameMenuTheme.secondaryButtonStyle,
                        child: Text(
                          'HIGH SCORES',
                          style: GameMenuTheme.buttonTextStyle.copyWith(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TutorialScreen(),
                            ),
                          );
                        },
                        style: GameMenuTheme.secondaryButtonStyle,
                        child: Text(
                          'HOW TO PLAY',
                          style: GameMenuTheme.buttonTextStyle.copyWith(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        style: GameMenuTheme.secondaryButtonStyle,
                        child: Text(
                          'SETTINGS',
                          style: GameMenuTheme.buttonTextStyle.copyWith(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

