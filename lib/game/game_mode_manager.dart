import 'package:flutter/foundation.dart';

enum GameModeType {
  classic,
  timed,
  challenge,
}

class GameMode {
  final GameModeType type;
  final String name;
  final String description;
  final int timeLimitSeconds; // For timed modes
  final int scoreTarget; // For challenge modes

  GameMode({
    required this.type,
    required this.name,
    required this.description,
    this.timeLimitSeconds = 0,
    this.scoreTarget = 0,
  });
}

class GameModeManager extends ChangeNotifier {
  GameMode _currentGameMode;

  GameModeManager() : _currentGameMode = _defaultGameModes[0]; // Default to Classic

  static final List<GameMode> _defaultGameModes = [
    GameMode(
      type: GameModeType.classic,
      name: 'Classic',
      description: 'Play until you run out of balls. Aim for the highest score!',
    ),
    GameMode(
      type: GameModeType.timed,
      name: 'Timed (3 min)',
      description: 'Score as many points as possible within 3 minutes.',
      timeLimitSeconds: 180,
    ),
    GameMode(
      type: GameModeType.challenge,
      name: 'Score Challenge (5000)',
      description: 'Reach a score of 5000 points with limited balls.',
      scoreTarget: 5000,
    ),
  ];

  List<GameMode> get availableGameModes => _defaultGameModes;

  GameMode get currentGameMode => _currentGameMode;

  void setGameMode(GameMode mode) {
    _currentGameMode = mode;
    notifyListeners();
  }
}
