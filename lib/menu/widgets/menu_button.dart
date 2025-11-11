import 'package:flutter/material.dart';

class MenuButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        width: 200,
        height: 50,
        child: ElevatedButton(
          onPressed: () {}, // Handled by GestureDetector
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
