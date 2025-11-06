import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text(
              '${index + 1}.',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            title: Text(
              'Player ${10 - index}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            trailing: Text(
              '${(10 - index) * 10000}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}
