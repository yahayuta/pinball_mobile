import 'package:flutter/material.dart';

class StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const StyledTextField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueGrey),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.blueGrey[900],
      ),
      style: const TextStyle(color: Colors.white, fontSize: 18),
      cursorColor: Colors.blueAccent,
    );
  }
}
