import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/tables/default_pinball_table.dart';
import 'package:pinball_mobile/game/tables/space_adventure_table.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/game_provider.dart';
import 'package:pinball_mobile/menu/main_menu.dart';

class TableSelectionScreen extends StatelessWidget {
  const TableSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Select a Table'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      final game = DefaultPinballTable();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Provider.of<GameProvider>(context, listen: false)
                            .setGame(game);
                      });
                      return GameScreen(game: game);
                    },
                  ),
                );
              },
              child: const Text('Default Table'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      final game = SpaceAdventureTable();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Provider.of<GameProvider>(context, listen: false)
                            .setGame(game);
                      });
                      return GameScreen(game: game);
                    },
                  ),
                );
              },
              child: const Text('Space Adventure'),
            ),
          ],
        ),
      ),
    );
  }
}
