import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

class ControlButtons extends StatelessWidget {
  final PinballGame game;

  const ControlButtons({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Expanded(child: SizedBox()), // Fill space at the top
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Flipper Button
              _ControlButton(
                icon: Icons.keyboard_arrow_left,
                label: 'LEFT',
                color: Colors.blue.withOpacity(0.6),
                onPress: () => game.leftFlipper.press(),
                onRelease: () => game.leftFlipper.release(),
              ),
              
              const Spacer(), // Spacer between flipper buttons

              // Right Flipper Button
              _ControlButton(
                icon: Icons.keyboard_arrow_right,
                label: 'RIGHT',
                color: Colors.blue.withOpacity(0.6),
                onPress: () => game.rightFlipper.press(),
                onRelease: () => game.rightFlipper.release(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPress;
  final VoidCallback onRelease;
  final double width;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPress,
    required this.onRelease,
    this.width = 80,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() => _isPressed = true);
        widget.onPress();
      },
      onPointerUp: (_) {
        setState(() => _isPressed = false);
        widget.onRelease();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: 80,
        decoration: BoxDecoration(
          color: _isPressed ? widget.color.withOpacity(0.9) : widget.color.withOpacity(0.4),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white, size: 30),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
