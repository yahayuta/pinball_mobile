import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pinball_mobile/main.dart' as app;
import 'package:pinball_mobile/menu/main_menu.dart';
import 'package:pinball_mobile/menu/table_selection_screen.dart';
import 'package:pinball_mobile/menu/leaderboard_screen.dart';
import 'package:pinball_mobile/menu/achievements_screen.dart';
import 'package:pinball_mobile/menu/multiplayer_screen.dart';
import 'package:pinball_mobile/menu/table_editor_screen.dart';
import 'package:pinball_mobile/menu/social_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end app test', () {
    testWidgets('App starts and navigates through main menu options', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify MainMenu is displayed
      expect(find.byType(MainMenu), findsOneWidget);
      expect(find.text('Pinball'), findsOneWidget);

      // Navigate to Table Selection
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
      expect(find.byType(TableSelectionScreen), findsOneWidget);
      expect(find.text('Select a Table'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MainMenu), findsOneWidget);

      // Navigate to Leaderboard
      await tester.tap(find.text('Leaderboard'));
      await tester.pumpAndSettle();
      expect(find.byType(LeaderboardScreen), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MainMenu), findsOneWidget);

      // Navigate to Achievements
      await tester.tap(find.text('Achievements'));
      await tester.pumpAndSettle();
      expect(find.byType(AchievementsScreen), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MainMenu), findsOneWidget);

      // Navigate to Multiplayer
      await tester.tap(find.text('Multiplayer'));
      await tester.pumpAndSettle();
      expect(find.byType(MultiplayerScreen), findsOneWidget);
      expect(find.text('Multiplayer'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MainMenu), findsOneWidget);

      // Navigate to Table Editor
      await tester.tap(find.text('Table Editor'));
      await tester.pumpAndSettle();
      expect(find.byType(TableEditorScreen), findsOneWidget);
      expect(find.text('Table Editor'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MainMenu), findsOneWidget);

      // Navigate to Social
      await tester.tap(find.text('Social'));
      await tester.pumpAndSettle();
      expect(find.byType(SocialScreen), findsOneWidget);
      expect(find.text('Social'), findsOneWidget);
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
    // - Social sharing (might be harder to test in integration tests)
  });
}
