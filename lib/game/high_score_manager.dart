import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScoreEntry {
  final String playerName;
  final int score;

  ScoreEntry({required this.playerName, required this.score});

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'score': score,
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        playerName: json['playerName'] as String,
        score: json['score'] as int,
      );
}

class HighScoreManager {
  static const String _highScoresKey = 'high_scores';
  static const int _maxHighScores = 10;

  final SharedPreferences _prefs;

  HighScoreManager(this._prefs);

  List<ScoreEntry> getHighScores() {
    final String? scoresJson = _prefs.getString(_highScoresKey);
    if (scoresJson == null) {
      return [];
    }
    final List<dynamic> scoresDynamic = json.decode(scoresJson) as List<dynamic>;
    return scoresDynamic
        .map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>))
        .toList()
          ..sort((a, b) => b.score.compareTo(a.score)); // Sort by score descending
  }

  Future<void> updateHighScore(String playerName, int newScore) async {
    List<ScoreEntry> currentHighScores = getHighScores();
    currentHighScores.add(ScoreEntry(playerName: playerName, score: newScore));
    currentHighScores.sort((a, b) => b.score.compareTo(a.score));

    if (currentHighScores.length > _maxHighScores) {
      currentHighScores = currentHighScores.sublist(0, _maxHighScores);
    }

    final String scoresJson = json.encode(currentHighScores.map((e) => e.toJson()).toList());
    await _prefs.setString(_highScoresKey, scoresJson);
  }
}
