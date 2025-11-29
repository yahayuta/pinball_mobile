import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/tables/default_pinball_table.dart';
import 'package:pinball_mobile/game/tables/space_adventure_table.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/game_provider.dart';
import 'package:pinball_mobile/game/pinball_game_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';

import 'package:pinball_mobile/menu/menu_theme.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';

class TableSelectionScreen extends StatelessWidget {
  const TableSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final prefs = context.read<SharedPreferences>();
    final highScoreManager = context.read<HighScoreManager>();

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/menu_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
          Column(
            children: [
              AppBar(
                title: Text('SELECT TABLE', style: GameMenuTheme.titleStyle.copyWith(fontSize: 28)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: GameMenuTheme.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildTableCard(
                      context,
                      'DEFAULT TABLE',
                      'Classic pinball experience',
                      () {
                        final game = DefaultPinballTable(
                          prefs: prefs,
                          highScoreManager: highScoreManager,
                          gameModeManager: gameProvider.gameModeManager,
                          audioManager: context.read<AudioManager>(),
                          achievementManager: context.read<AchievementManager>(),
                        );
                        gameProvider.loadTable(game);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(game: game),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTableCard(
                      context,
                      'SPACE ADVENTURE',
                      'Explore the galaxy!',
                      () {
                        final game = SpaceAdventureTable(
                          prefs: prefs,
                          highScoreManager: highScoreManager,
                          gameModeManager: gameProvider.gameModeManager,
                          audioManager: context.read<AudioManager>(),
                          achievementManager: context.read<AchievementManager>(),
                        );
                        gameProvider.loadTable(game);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(game: game),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(BuildContext context, String title, String description, VoidCallback onTap) {
    return Card(
      color: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: GameMenuTheme.primaryColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GameMenuTheme.buttonTextStyle.copyWith(color: GameMenuTheme.primaryColor),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: GameMenuTheme.bodyTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
