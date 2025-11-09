import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

class GameScreen extends StatelessWidget {
  final PinballGame game;

  const GameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: game),
    );
  }
}