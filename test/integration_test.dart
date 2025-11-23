import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pinball_mobile/main.dart' as app;
import 'package:pinball_mobile/menu/main_menu.dart';
import 'package:pinball_mobile/menu/table_selection_screen.dart';
import 'package:pinball_mobile/menu/high_score_screen.dart';
import 'package:pinball_mobile/menu/tutorial_screen.dart';
import 'package:pinball_mobile/menu/settings_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end app test', () {
    testWidgets('App starts and navigates through main menu options', (WidgetTester tester) async {
      app.main();
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
