import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/tables/default_pinball_table.dart';
import 'package:pinball_mobile/game/tables/space_adventure_table.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/game_provider.dart';
import 'package:pinball_mobile/game/pinball_game_widget.dart'; // Import GameScreen
import 'package:shared_preferences/shared_preferences.dart'; // For creating PinballGame
import 'package:pinball_mobile/game/high_score_manager.dart'; // For creating PinballGame
import 'package:pinball_mobile/game/table_config_manager.dart'; // Added
import 'package:pinball_mobile/game/tables/custom_pinball_table.dart'; // Added
import 'package:pinball_mobile/menu/widgets/menu_button.dart'; // Import MenuButton
import 'package:pinball_mobile/game/audio_manager.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';

class TableSelectionScreen extends StatefulWidget { // Changed to StatefulWidget
  const TableSelectionScreen({super.key});

  @override
  State<TableSelectionScreen> createState() => _TableSelectionScreenState();
}

class _TableSelectionScreenState extends State<TableSelectionScreen> {
  List<TableConfig> _customTables = [];

  @override
  void initState() {
    super.initState();
    _loadCustomTables();
  }

  Future<void> _loadCustomTables() async {
    final tableConfigManager = Provider.of<GameProvider>(context, listen: false).tableConfigManager;
    _customTables = tableConfigManager.getCustomTables();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final prefs = context.read<SharedPreferences>(); // Access SharedPreferences
    final highScoreManager = context.read<HighScoreManager>(); // Access HighScoreManager

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Select a Table'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView( // Added SingleChildScrollView
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuButton(
                text: 'Default Table',
                onPressed: () {
                  final game = DefaultPinballTable(
                    prefs: prefs,
                    highScoreManager: highScoreManager,
                    gameModeManager: gameProvider.gameModeManager, // Added
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
                    gameModeManager: gameProvider.gameModeManager, // Added
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
              const SizedBox(height: 40),
              const Text(
                'Custom Tables:',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              _customTables.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'No custom tables saved.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true, // Added shrinkWrap
                      physics: const NeverScrollableScrollPhysics(), // Added NeverScrollableScrollPhysics
                      itemCount: _customTables.length,
                      itemBuilder: (context, index) {
                        final table = _customTables[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: MenuButton(
                            text: table.name,
                            onPressed: () {
                              final game = CustomPinballTable(
                                tableConfig: table,
                                prefs: prefs,
                                highScoreManager: highScoreManager,
                                gameModeManager: gameProvider.gameModeManager, // Added
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
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
