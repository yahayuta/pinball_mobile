import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/game_provider.dart';
import 'package:pinball_mobile/menu/main_menu.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'package:pinball_mobile/game/high_score_manager.dart'; // Added

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final highScoreManager = HighScoreManager(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),
        Provider<HighScoreManager>.value(value: highScoreManager),
        ChangeNotifierProvider(
          create: (context) => GameProvider(
            prefs: prefs,
            highScoreManager: highScoreManager,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinball Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainMenu(),
    );
  }
}
