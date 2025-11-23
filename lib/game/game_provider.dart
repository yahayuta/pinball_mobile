import 'package:pinball_mobile/game/tables/default_pinball_table.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/game_mode_manager.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';

class GameProvider extends ChangeNotifier {
  late PinballGame _game;
  late final GameModeManager gameModeManager;

  GameProvider({
    required SharedPreferences prefs,
    required HighScoreManager highScoreManager,
    required AudioManager audioManager,
    required AchievementManager achievementManager,
  }) {
    gameModeManager = GameModeManager();
    _game = DefaultPinballTable(
      prefs: prefs,
      highScoreManager: highScoreManager,
      gameModeManager: gameModeManager,
      audioManager: audioManager,
      achievementManager: achievementManager,
    );
    _highScoreManager = highScoreManager;
  }

  late final HighScoreManager _highScoreManager;
  HighScoreManager get highScoreManager => _highScoreManager;

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
