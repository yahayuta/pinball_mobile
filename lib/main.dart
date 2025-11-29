import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:pinball_mobile/game/game_provider.dart';
import 'package:pinball_mobile/menu/main_menu.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/audio_manager.dart'; // Import AudioManager
import 'package:pinball_mobile/game/achievement_manager.dart'; // Import AchievementManager

void main({AudioManager? audioManager, AchievementManager? achievementManager}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final highScoreManager = HighScoreManager(prefs);
  final actualAudioManager = audioManager ?? AudioManager(); // Instantiate AudioManager once
  final actualAchievementManager = achievementManager ?? AchievementManager(prefs); // Instantiate AchievementManager once

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),
        Provider<HighScoreManager>.value(value: highScoreManager),
        ChangeNotifierProvider<AudioManager>.value(value: actualAudioManager), // Provide AudioManager
        ChangeNotifierProvider<AchievementManager>.value(value: actualAchievementManager), // Provide AchievementManager
        ChangeNotifierProvider(
          create: (context) => GameProvider(
            prefs: prefs,
            highScoreManager: highScoreManager,
            audioManager: actualAudioManager, // Pass AudioManager
            achievementManager: actualAchievementManager,
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
      builder: (context, child) {
        return Container(
          color: Colors.black, // Background for the empty space
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500, // Max width for mobile-like experience
            ),
            child: ClipRect(
              child: child,
            ),
          ),
        );
      },
      home: const MainMenu(),
    );
  }
}
