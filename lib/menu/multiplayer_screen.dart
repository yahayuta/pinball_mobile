import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/game_provider.dart';
import 'package:pinball_mobile/menu/table_selection_screen.dart';
import 'package:pinball_mobile/menu/widgets/menu_button.dart'; // Import MenuButton
import 'package:pinball_mobile/menu/widgets/styled_text_field.dart'; // Import StyledTextField

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
              StyledTextField(
                controller: _player1Controller,
                labelText: 'Player 1 Name',
              ),
              const SizedBox(height: 20),
              StyledTextField(
                controller: _player2Controller,
                labelText: 'Player 2 Name',
              ),
              const SizedBox(height: 40),
              MenuButton(
                text: 'Start Game (Player 1)',
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
              ),
              // TODO: Implement actual turn-based multiplayer or score comparison
            ],
          ),
        ),
      ),
    );
  }
}
