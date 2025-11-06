import 'package:shared_preferences/shared_preferences.dart';

class HighScoreManager {
  static const String _highScoreKey = 'high_score';

  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  Future<void> updateHighScore(int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = prefs.getInt(_highScoreKey) ?? 0;
    if (newScore > currentHighScore) {
      await prefs.setInt(_highScoreKey, newScore);
    }
  }
}