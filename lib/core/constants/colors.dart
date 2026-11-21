import 'package:flutter/material.dart';

class AppColors {
  // Pastel Palette
  static const Color primaryPink = Color(0xFFFFD1DC);
  static const Color secondaryPeach = Color(0xFFFFDAB9);
  static const Color mintGreen = Color(0xFFB2FBDA);
  static const Color softLavender = Color(0xFFE6E6FA);
  static const Color warmCream = Color(0xFFFFFDD0);
  
  static const Color accentPink = Color(0xFFFF91A4);
  static const Color textDark = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF7D7D7D);
  static const Color white = Colors.white;
  static const Color errorRed = Color(0xFFFF6B6B);
  
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [primaryPink, secondaryPeach],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
