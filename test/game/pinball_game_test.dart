import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
import 'package:pinball_mobile/game/game_mode_manager.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinball_mobile/game/achievement_manager.dart'; // Import AchievementManager

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockHighScoreManager extends Mock implements HighScoreManager {}
class MockGameModeManager extends Mock implements GameModeManager {}
class MockAudioManager extends Mock implements AudioManager {}
class MockAchievementManager extends Mock implements AchievementManager {} // Mock AchievementManager

class TestPinballGame extends PinballGame {
  TestPinballGame({
    required super.prefs,
    required super.highScoreManager,
    required super.gameModeManager,
    required super.audioManager,
    required super.achievementManager, // Added
  });

  @override
  Future<void> loadTableElements() async {
    // Do nothing for testing purposes
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PinballGame', () {
    late MockSharedPreferences mockPrefs;
    late MockHighScoreManager mockHighScoreManager;
    late MockGameModeManager mockGameModeManager;
    late MockAudioManager mockAudioManager;
    late MockAchievementManager mockAchievementManager; // Declare mockAchievementManager

    setUp(() {
      mockPrefs = MockSharedPreferences();
      mockHighScoreManager = MockHighScoreManager();
      mockGameModeManager = MockGameModeManager();
      mockAudioManager = MockAudioManager();
      mockAchievementManager = MockAchievementManager(); // Initialize mockAchievementManager

      when(() => mockGameModeManager.currentGameMode)
          .thenReturn(GameMode(type: GameModeType.classic, name: 'Classic', description: ''));
      when(() => mockAudioManager.init()).thenAnswer((_) async => {});
      when(() => mockAudioManager.playBackgroundMusic(any())).thenAnswer((_) async => {});
      when(() => mockAudioManager.playSoundEffect(any(), impactForce: any(named: 'impactForce')))
          .thenAnswer((_) async => {});
      when(() => mockAudioManager.dispose()).thenAnswer((_) async => {});
      when(() => mockAchievementManager.setProgress(any(), any())).thenAnswer((_) {}); // Mock setProgress
      when(() => mockAchievementManager.updateProgress(any(), any())).thenAnswer((_) {}); // Mock updateProgress
    });

    test('game initializes correctly', () {
      final game = TestPinballGame(
        prefs: mockPrefs,
        highScoreManager: mockHighScoreManager,
        gameModeManager: mockGameModeManager,
        audioManager: mockAudioManager,
        achievementManager: mockAchievementManager, // Added
      );

      expect(game.score, 0);
      expect(game.combo, 0);
      expect(game.maxHeightReached, 0);
      expect(game.isBallSaveActive, false);
      expect(game.tiltWarnings, 0);
      expect(game.isTilted, false);
    });
  });
}