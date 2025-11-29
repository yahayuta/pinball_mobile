import 'package:flutter/material.dart';
import 'package:pinball_mobile/menu/menu_theme.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle headingStyle = GameMenuTheme.titleStyle.copyWith(fontSize: 24, color: Colors.white);
    final TextStyle bodyStyle = GameMenuTheme.bodyTextStyle.copyWith(fontSize: 16);

    return Scaffold(
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
                title: Text('HOW TO PLAY', style: GameMenuTheme.titleStyle.copyWith(fontSize: 28)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: GameMenuTheme.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONTROLS:',
                          style: headingStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '- Tap Left Side: Left Flipper',
                          style: bodyStyle,
                        ),
                        Text(
                          '- Tap Right Side: Right Flipper',
                          style: bodyStyle,
                        ),
                        Text(
                          '- Drag Down & Release: Launch Ball',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'OBJECTIVE:',
                          style: headingStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Hit the bumpers, targets, and spinners to score points. '
                          'Try to get the highest score!',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'FEATURES:',
                          style: headingStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '- Multi-ball: Hit the target on the top right 3 times to release 2 extra balls.',
                          style: bodyStyle,
                        ),
                        Text(
                          '- Ball Save: After launching a ball, you have 5 seconds of ball save. If you lose a ball during this time, it will be re-launched.',
                          style: bodyStyle,
                        ),
                        Text(
                          '- Tilt: Shaking the device too much will trigger a tilt warning. After 3 warnings, the game will tilt and you will lose your turn.',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
