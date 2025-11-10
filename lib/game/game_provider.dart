import 'package:pinball_mobile/game/tables/default_pinball_table.dart'; // Added
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/table_config_manager.dart'; // Added
import 'package:pinball_mobile/game/game_mode_manager.dart'; // Added

class GameProvider extends ChangeNotifier {
  late PinballGame _game; // Changed to late, not late final
  late final TableConfigManager tableConfigManager; // Added
  late final GameModeManager gameModeManager; // Added

  GameProvider({
    required SharedPreferences prefs,
    required HighScoreManager highScoreManager,
  }) {
    tableConfigManager = TableConfigManager(prefs); // Initialized
    gameModeManager = GameModeManager(); // Initialized
    _game = DefaultPinballTable(
      prefs: prefs,
      highScoreManager: highScoreManager,
      gameModeManager: gameModeManager, // Added
    );
    _highScoreManager = highScoreManager; // Initialize _highScoreManager
  }

  late final HighScoreManager _highScoreManager; // Declare _highScoreManager
  HighScoreManager get highScoreManager => _highScoreManager; // Add getter

  PinballGame get game => _game;

  void loadTable(PinballGame newGame) {
    _game = newGame;
    notifyListeners();
  }

  void setPlayerName(String name) {
    _game.currentPlayerName = name;
    notifyListeners();
  }
}
