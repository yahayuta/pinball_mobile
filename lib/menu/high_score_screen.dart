import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';
import 'package:pinball_mobile/game/achievement_manager.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/menu/menu_theme.dart';

class HighScoreScreen extends StatelessWidget {
  const HighScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/menu_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.black.withValues(alpha: 0.7),
            ),
            Column(
              children: [
                AppBar(
                  title: Text('PROGRESS', style: GameMenuTheme.titleStyle.copyWith(fontSize: 28)),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: GameMenuTheme.primaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  bottom: const TabBar(
                    indicatorColor: GameMenuTheme.primaryColor,
                    labelColor: GameMenuTheme.primaryColor,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: 'HIGH SCORES', icon: Icon(Icons.emoji_events)),
                      Tab(text: 'ACHIEVEMENTS', icon: Icon(Icons.star)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildHighScoresTab(context),
                      _buildAchievementsTab(context),
                    ],
                  ),
                ),
              ],
            ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'TOP SCORES',
              style: GameMenuTheme.titleStyle.copyWith(fontSize: 24, color: Colors.white),
            ),
          ),
          Expanded(
            child: highScores.isEmpty
                ? Center(
                    child: Text(
                      'No high scores yet!\nPlay a game to set a record.',
                      textAlign: TextAlign.center,
                      style: GameMenuTheme.bodyTextStyle.copyWith(fontSize: 18),
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
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isTopThree ? GameMenuTheme.primaryColor : Colors.grey[800]!,
                            width: 1,
                          ),
                        ),
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
                                        style: GameMenuTheme.bodyTextStyle.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  scoreEntry.playerName,
                                  style: GameMenuTheme.bodyTextStyle.copyWith(
                                    fontSize: 20,
                                    color: isTopThree ? Colors.white : Colors.white70,
                                    fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                scoreEntry.score.toString(),
                                style: GameMenuTheme.bodyTextStyle.copyWith(
                                  fontSize: 22,
                                  color: isTopThree ? GameMenuTheme.secondaryColor : Colors.white70,
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
      return Center(
        child: Text(
          'No achievements defined.',
          style: GameMenuTheme.bodyTextStyle.copyWith(fontSize: 20),
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
          color: Colors.black.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isUnlocked ? GameMenuTheme.secondaryColor : Colors.grey[800]!,
              width: 1,
            ),
          ),
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
                      color: isUnlocked ? GameMenuTheme.secondaryColor : Colors.grey,
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
                        style: GameMenuTheme.bodyTextStyle.copyWith(
                          fontSize: 20,
                          color: isUnlocked ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: GameMenuTheme.bodyTextStyle.copyWith(
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
                              const AlwaysStoppedAnimation<Color>(GameMenuTheme.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Progress: $progress / ${achievement.targetValue}',
                          style: GameMenuTheme.bodyTextStyle.copyWith(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                      if (isUnlocked)
                        Text(
                          'UNLOCKED!',
                          style: GameMenuTheme.bodyTextStyle.copyWith(
                            fontSize: 16,
                            color: GameMenuTheme.primaryColor,
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
