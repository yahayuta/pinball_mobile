import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:pinball_mobile/game/widgets/game_hud.dart';

class GameScreen extends StatelessWidget {
  final PinballGame game;

  const GameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Game widget (centered with max width 500px)
          Center(
            child: GameWidget(game: game),
          ),
          // HUD positioned at the top left, outside the game area
          Positioned(
            top: 10,
            left: 10,
            child: GameHud(game: game),
          ),
        ],
      ),
    );
  }
}