import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/game_provider.dart';
import 'package:pinball_mobile/menu/table_selection_screen.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  final TextEditingController _player1Controller = TextEditingController(text: 'Player 1');
  final TextEditingController _player2Controller = TextEditingController(text: 'Player 2');

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Multiplayer'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _player1Controller,
                decoration: const InputDecoration(
                  labelText: 'Player 1 Name',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _player2Controller,
                decoration: const InputDecoration(
                  labelText: 'Player 2 Name',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // For simplicity, we'll just use Player 1's name for now
                  // and navigate to table selection.
                  gameProvider.setPlayerName(_player1Controller.text);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TableSelectionScreen(),
                    ),
                  );
                },
                child: const Text('Start Game (Player 1)'),
              ),
              // TODO: Implement actual turn-based multiplayer or score comparison
            ],
          ),
        ),
      ),
    );
  }
}
