import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameMenuTheme {
  static const Color primaryColor = Color(0xFF00FFFF); // Cyan
  static const Color secondaryColor = Color(0xFFFF00FF); // Magenta
  static const Color accentColor = Color(0xFF9D00FF); // Purple
  static const Color backgroundColor = Colors.black;
  static const Color surfaceColor = Color(0xFF1A1A1A);

  static TextStyle get titleStyle => GoogleFonts.orbitron(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        shadows: [
          const Shadow(
            blurRadius: 10.0,
            color: primaryColor,
            offset: Offset(0, 0),
          ),
        ],
      );

  static TextStyle get buttonTextStyle => GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle get bodyTextStyle => GoogleFonts.roboto(
        fontSize: 16,
        color: Colors.white70,
      );

  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        shadowColor: primaryColor,
        elevation: 10,
        side: const BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: secondaryColor,
        shadowColor: secondaryColor,
        elevation: 5,
        side: const BorderSide(color: secondaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      );
}
