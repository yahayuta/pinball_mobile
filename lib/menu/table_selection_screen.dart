import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/tables/default_pinball_table.dart';
import 'package:pinball_mobile/game/tables/space_adventure_table.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/game_provider.dart';
import 'package:pinball_mobile/game/pinball_game_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/menu/widgets/menu_button.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Select a Table'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              text: 'Default Table',
              onPressed: () {
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
            MenuButton(
              text: 'Space Adventure',
              onPressed: () {
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
    );
  }
}
