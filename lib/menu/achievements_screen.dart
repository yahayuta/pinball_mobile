import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';
import 'package:provider/provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.black,
      ),
      body: Consumer<AchievementManager>(
        builder: (context, achievementManager, child) {
          final allAchievements = achievementManager.allAchievements;

          if (allAchievements.isEmpty) {
            return const Center(
              child: Text(
                'No achievements defined.',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: allAchievements.length,
            itemBuilder: (context, index) {
              final achievement = allAchievements[index];
              final isUnlocked = achievementManager.isUnlocked(achievement.id);
              final progress = achievementManager.getProgress(achievement.id);

              return Card(
                color: Colors.blueGrey[800],
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Image.asset(
                        achievement.iconPath,
                        width: 60,
                        height: 60,
                        color: isUnlocked ? null : Colors.grey, // Desaturate if locked
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.name,
                              style: TextStyle(
                                fontSize: 20,
                                color: isUnlocked ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              achievement.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isUnlocked ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!isUnlocked)
                              LinearProgressIndicator(
                                value: progress / achievement.targetValue,
                                backgroundColor: Colors.grey[700],
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            if (!isUnlocked)
                              Text(
                                'Progress: $progress / ${achievement.targetValue}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                            if (isUnlocked)
                              const Text(
                                'UNLOCKED!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
