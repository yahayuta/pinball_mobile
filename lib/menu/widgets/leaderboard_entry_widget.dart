import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/high_score_manager.dart';

class LeaderboardEntryWidget extends StatelessWidget {
  final int rank;
  final ScoreEntry scoreEntry;

  const LeaderboardEntryWidget({
    super.key,
    required this.rank,
    required this.scoreEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[800],
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$rank.',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  scoreEntry.playerName,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Text(
              scoreEntry.score.toString(),
              style: const TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
