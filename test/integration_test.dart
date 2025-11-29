import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pinball_mobile/main.dart' as app;
import 'package:pinball_mobile/menu/main_menu.dart';
import 'package:pinball_mobile/menu/table_selection_screen.dart';
import 'package:pinball_mobile/menu/high_score_screen.dart';
import 'package:pinball_mobile/menu/tutorial_screen.dart';
import 'package:pinball_mobile/menu/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';

class MockAudioManager extends Mock implements AudioManager {}
class MockAchievementManager extends Mock implements AchievementManager {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end app test', () {
    late MockAudioManager mockAudioManager;
    late MockAchievementManager mockAchievementManager;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
      
      mockAudioManager = MockAudioManager();
      when(() => mockAudioManager.init()).thenAnswer((_) async {});
      when(() => mockAudioManager.playBackgroundMusic(any())).thenAnswer((_) async {});
      when(() => mockAudioManager.playSoundEffect(any(), impactForce: any(named: 'impactForce'))).thenAnswer((_) async {});
      when(() => mockAudioManager.dispose()).thenAnswer((_) async {});
      when(() => mockAudioManager.musicVolume).thenReturn(0.5);
      when(() => mockAudioManager.sfxVolume).thenReturn(0.7);
      when(() => mockAudioManager.setMusicVolume(any())).thenAnswer((_) {});
      when(() => mockAudioManager.setSfxVolume(any())).thenAnswer((_) {});

      mockAchievementManager = MockAchievementManager();
      when(() => mockAchievementManager.updateProgress(any(), any())).thenAnswer((_) {});
      when(() => mockAchievementManager.setProgress(any(), any())).thenAnswer((_) {});
      when(() => mockAchievementManager.allAchievements).thenReturn([]);
    });

    testWidgets('App starts and navigates through main menu options', (WidgetTester tester) async {
      app.main(audioManager: mockAudioManager, achievementManager: mockAchievementManager);
      await tester.pumpAndSettle();

      // Verify MainMenu is displayed
      expect(find.byType(MainMenu), findsOneWidget);
      expect(find.text('Pinball'), findsOneWidget);

      // Navigate to Table Selection (Play button)
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      expect(find.byType(TableSelectionScreen), findsOneWidget);
      expect(find.text('Select a Table'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MainMenu), findsOneWidget);

      // Navigate to High Scores (includes Achievements tab)
      await tester.tap(find.text('High Scores'));
      await tester.pumpAndSettle();
      expect(find.byType(HighScoreScreen), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MainMenu), findsOneWidget);

      // Navigate to How to Play
      await tester.tap(find.text('How to Play'));
      await tester.pumpAndSettle();
      expect(find.byType(TutorialScreen), findsOneWidget);
      expect(find.text('How to Play'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MainMenu), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MainMenu), findsOneWidget);
    });

    // testWidgets('Can select a default table and start game', (WidgetTester tester) async {
    //   app.main();
    //   await tester.pumpAndSettle();

    //   await tester.tap(find.text('Default Table'));
    //   await tester.pumpAndSettle();

    //   // Verify game screen is displayed (assuming GameScreen is the widget that hosts the PinballGame)
    //   expect(find.byType(GameScreen), findsOneWidget);
    //   // You might want to add more specific checks here, e.g., for game elements
    // });

    // Add more integration tests for other features like:
    // - Saving/loading custom tables
    // - Playing a game and checking score updates
    // - Triggering achievements
  });
}
