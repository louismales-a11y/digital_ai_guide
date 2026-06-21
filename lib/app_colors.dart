import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color bgDark = Color(0xFF0A1929);      // Sky blue main bg
  static const Color bgCard = Color(0xFF0F2440);        // White cards
  static const Color bgCardHover = Color(0xFF162D4A);   // Slightly darker hover
  
  // Neon accents (keep them punchy on light bg)
  static const Color neonBlue = Color(0xFF00B8FF);      // Deeper blue for light bg
  static const Color neonBlueGlow = Color(0xFF0088FF);
  static const Color neonRed = Color(0xFFFF1744);       // Keeping red accent
  static const Color neonRedDim = Color(0xFFCC1133);
  static const Color electricCyan = Color(0xFF00BCD4);
  static const Color electricPurple = Color(0xFF7C4DFF);
  
  // Text (dark for light background)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0CC);
  static const Color textMuted = Color(0xFF8888AA);
  
  // Borders
  static const Color borderSubtle = Color(0xFF1E2D45);
  
  // Gradients
  static const Color gradientStart = Color(0xFF0A0A1A);
  static const Color gradientEnd = Color(0xFF0D0D20);

  AppColors._();
}
