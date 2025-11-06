import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('How to Play'),
        backgroundColor: Colors.black,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Controls:',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '- Left Arrow Key: Left Flipper',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                '- Right Arrow Key: Right Flipper',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                '- Spacebar: Launch Ball',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Objective:',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Hit the bumpers, targets, and spinners to score points. '
                'Try to get the highest score!',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Features:',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '- Multi-ball: Hit the target on the top right 3 times to release 2 extra balls.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                '- Ball Save: After launching a ball, you have 5 seconds of ball save. If you lose a ball during this time, it will be re-launched.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                '- Tilt: Shaking the device too much will trigger a tilt warning. After 3 warnings, the game will tilt and you will lose your turn.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
