import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:pinball_mobile/game/widgets/game_hud.dart';
import 'package:pinball_mobile/game/widgets/control_buttons.dart';

class GameScreen extends StatefulWidget {
  final PinballGame game;

  const GameScreen({super.key, required this.game});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Aggressively request focus after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          // Re-request focus whenever the screen is tapped
          _focusNode.requestFocus();
        },
        child: Stack(
          children: [
            // Game widget
            Center(
              child: GameWidget(
                game: widget.game,
                autofocus: true,
              ),
            ),
            // HUD positioned at the top left
            Positioned(
              top: 10,
              left: 10,
              child: GameHud(game: widget.game),
            ),
            // Control buttons at the bottom
            Positioned.fill(
              child: ControlButtons(game: widget.game),
            ),
          ],
        ),
      ),
    );
  }
}