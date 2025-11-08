import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

class PinballGameWidget extends StatelessWidget {
  final PinballGame game;
  const PinballGameWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Focus(autofocus: true, child: GameWidget(game: game));
  }
}
