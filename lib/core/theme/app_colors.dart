import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Updated Visual Identity
  static const Color primary = Color(0xFF3A0051);
  static const Color accent = Color(0xFF00B4D8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);

  // Legacy/Semantic Colors (Mapped to new identity where possible)
  static const Color primaryDark = primary; 
  static const Color secondaryDark = Color(0xFF0B1033);
  static const Color vibrantPurple = Color(0xFF7B39FD);
  static const Color accentCyan = accent;
  static const Color primaryBlue = Color(0xFF185ADB);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primary,
      secondaryDark,
    ],
  );

  // Backgrounds
  static const Color backgroundAlt = Color(0xFFF8F9FE);
  static const Color fieldBackground = Color(0xFFF7F7FB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1B0330);
  static const Color textSecondary = Color(0xFF7D7D9E);
  static const Color textHint = Color(0xFFB0B0C5);
  static const Color white = Colors.white;

  // Feedback & Action
  static const Color error = Color(0xFFFF4D4D);
  static const Color logoutRed = Color(0xFFF14336);
  static const Color successGreen = Color(0xFF4CAF50);

  // Components
  static const Color chipUnselected = Color(0xFFEFECF8);
  static const Color progressBackground = Color(0xFFF0F0F7);
  static const Color indicatorActive = primary;
  static const Color indicatorInactive = Color(0xFFD9D9E3);
  static const Color logoBackground = Color(0xFF324A86);
  static const Color buttonLightPurple = Color(0xFFF0E6FF);
}
