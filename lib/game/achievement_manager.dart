import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final int targetValue;
  final String iconPath;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.targetValue,
    required this.iconPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'targetValue': targetValue,
        'iconPath': iconPath,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        targetValue: json['targetValue'] as int,
        iconPath: json['iconPath'] as String,
      );
}

class AchievementManager extends ChangeNotifier {
  final SharedPreferences _prefs;
  final List<Achievement> _allAchievements = [
    Achievement(
      id: 'first_game',
      name: 'First Game',
      description: 'Play your first game of pinball.',
      targetValue: 1,
      iconPath: 'assets/icons/achievement_first_game.png',
    ),
    Achievement(
      id: 'score_1000',
      name: 'Score 1000',
      description: 'Achieve a score of 1000 points.',
      targetValue: 1000,
      iconPath: 'assets/icons/achievement_score_1000.png',
    ),
    Achievement(
      id: 'combo_5',
      name: 'Combo Master',
      description: 'Achieve a 5x combo.',
      targetValue: 5,
      iconPath: 'assets/icons/achievement_combo_5.png',
    ),
    // Add more achievements here
  ];

  final Map<String, int> _achievementProgress = {};
  final Set<String> _unlockedAchievements = {};

  AchievementManager(this._prefs) {
    _loadAchievements();
  }

  List<Achievement> get allAchievements => List.unmodifiable(_allAchievements);
  Set<String> get unlockedAchievements => Set.unmodifiable(_unlockedAchievements);

  int getProgress(String achievementId) {
    return _achievementProgress[achievementId] ?? 0;
  }

  bool isUnlocked(String achievementId) {
    return _unlockedAchievements.contains(achievementId);
  }

  void _loadAchievements() {
    for (final achievement in _allAchievements) {
      _achievementProgress[achievement.id] = _prefs.getInt('${achievement.id}_progress') ?? 0;
      if (_prefs.getBool('${achievement.id}_unlocked') ?? false) {
        _unlockedAchievements.add(achievement.id);
      }
    }
    notifyListeners();
  }

  Future<void> _saveAchievements() async {
    for (final achievement in _allAchievements) {
      await _prefs.setInt('${achievement.id}_progress', _achievementProgress[achievement.id] ?? 0);
      await _prefs.setBool('${achievement.id}_unlocked', _unlockedAchievements.contains(achievement.id));
    }
  }

  void updateProgress(String achievementId, int value) {
    if (!isUnlocked(achievementId)) {
      final achievement = _allAchievements.firstWhere((a) => a.id == achievementId);
      _achievementProgress[achievementId] = (_achievementProgress[achievementId] ?? 0) + value;

      if (_achievementProgress[achievementId]! >= achievement.targetValue) {
        _unlockedAchievements.add(achievementId);
        // TODO: Trigger achievement notification
        debugPrint('Achievement Unlocked: ${achievement.name}');
      }
      _saveAchievements();
      notifyListeners();
    }
  }

  void setProgress(String achievementId, int value) {
    if (!isUnlocked(achievementId)) {
      final achievement = _allAchievements.firstWhere((a) => a.id == achievementId);
      _achievementProgress[achievementId] = value;

      if (_achievementProgress[achievementId]! >= achievement.targetValue) {
        _unlockedAchievements.add(achievementId);
        // TODO: Trigger achievement notification
        debugPrint('Achievement Unlocked: ${achievement.name}');
      }
      _saveAchievements();
      notifyListeners();
    }
  }

  // Method to reset all achievements (for testing/development)
  Future<void> resetAchievements() async {
    _achievementProgress.clear();
    _unlockedAchievements.clear();
    for (final achievement in _allAchievements) {
      await _prefs.remove('${achievement.id}_progress');
      await _prefs.remove('${achievement.id}_unlocked');
    }
    notifyListeners();
  }
}
