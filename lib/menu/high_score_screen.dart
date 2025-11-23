import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';
import 'package:provider/provider.dart';

class HighScoreScreen extends StatelessWidget {
  const HighScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Progress'),
          backgroundColor: Colors.black,
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'High Scores', icon: Icon(Icons.emoji_events)),
              Tab(text: 'Achievements', icon: Icon(Icons.star)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHighScoresTab(context),
            _buildAchievementsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHighScoresTab(BuildContext context) {
    final highScoreManager = context.watch<HighScoreManager>();
    final highScores = highScoreManager.getHighScores();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Top Scores',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: highScores.isEmpty
                ? const Center(
                    child: Text(
                      'No high scores yet!\nPlay a game to set a record.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: highScores.length,
                    itemBuilder: (context, index) {
                      final scoreEntry = highScores[index];
                      final isTopThree = index < 3;
                      final medalColor = index == 0
                          ? Colors.amber
                          : index == 1
                              ? Colors.grey[400]
                              : Colors.orange[800];

                      return Card(
                        color: isTopThree
                            ? Colors.blueGrey[900]
                            : Colors.grey[900],
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: isTopThree
                                    ? Icon(
                                        Icons.emoji_events,
                                        color: medalColor,
                                        size: 28,
                                      )
                                    : Text(
                                        '${index + 1}.',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  scoreEntry.playerName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: isTopThree
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: isTopThree
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                scoreEntry.score.toString(),
                                style: TextStyle(
                                  fontSize: 22,
                                  color: isTopThree
                                      ? Colors.yellow
                                      : Colors.yellow[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(BuildContext context) {
    final achievementManager = context.watch<AchievementManager>();
    final allAchievements = achievementManager.allAchievements;

    if (allAchievements.isEmpty) {
      return const Center(
        child: Text(
          'No achievements defined.',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white70,
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
                  color: isUnlocked ? null : Colors.grey,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      isUnlocked ? Icons.star : Icons.star_border,
                      size: 60,
                      color: isUnlocked ? Colors.yellow : Colors.grey,
                    );
                  },
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
                      if (!isUnlocked) ...[
                        LinearProgressIndicator(
                          value: progress / achievement.targetValue,
                          backgroundColor: Colors.grey[700],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Progress: $progress / ${achievement.targetValue}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
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
  }
}
