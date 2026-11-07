import 'package:flutter/material.dart';

enum ThemePreset {
  green('أخضر', Color(0xFF087f5b)),
  indigo('نيلي', Color(0xFF364fc7)),
  turquoise('تركوازي', Color(0xFF0b7285)),
  crimson('عنابي', Color(0xFFa61e4d)),
  orange('برتقالي', Color(0xFFc5430f)),
  blue('أزرق', Color(0xFF1864ab)),
  purple('بنفسجي', Color(0xFF7C3AED)),
  sky('سماوي', Color(0xFF0284C7)),
  emerald('زمردي', Color(0xFF059669)),
  lightOrange('برتقالي فاتح', Color(0xFFEA580C)),
  pink('وردي', Color(0xFFE11D48)),
  teal('فيروزي', Color(0xFF0D9488));

  final String label;
  final Color seedColor;

  const ThemePreset(this.label, this.seedColor);
}

class AppColors {
  // Brand Base
  static const Color primaryBlue = Color(0xFF0D6EFD);
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF1E293B);

  // Alahisan-style dark color (deep navy/charcoal for dark mode scaffold)
  static const Color darkColor = Color(0xff0f161e);

  // Status Colors (WCAG AA Compliant)
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B);   // Amber 500
  static const Color error = Color(0xFFEF4444);   // Red 500
  static const Color info = Color(0xFF3B82F6);    // Blue 500

  // Neutral Scales
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Dynamic colors based on dark mode (alahisan style)
  // These are computed at runtime via ThemeCubit
  static Color whiteColor = Colors.white; // dark mode -> black, light -> white
  static Color secendcolor = Colors.white; // dark mode -> white, light -> black54

  static void updateDynamicColors(bool isDark) {
    whiteColor = isDark ? Colors.black : Colors.white;
    secendcolor = isDark ? Colors.white : Colors.black54;
  }

  // Custom color presets (12 colors)
  static const List<Color> colors = [
    Color(0xFF087f5b),
    Color(0xFF364fc7),
    Color(0xFF0b7285),
    Color(0xFFa61e4d),
    Color(0xFFc5430f),
    Color(0xFF1864ab),
    Color(0xFF7C3AED),
    Color(0xFF0284C7),
    Color(0xFF059669),
    Color(0xFFEA580C),
    Color(0xFFE11D48),
    Color(0xFF0D9488),
  ];

  static const List<int> numberColors = [
    0xFF087f5b,
    0xFF364fc7,
    0xFF0b7285,
    0xFFa61e4d,
    0xFFc5430f,
    0xFF1864ab,
    0xFF7C3AED,
    0xFF0284C7,
    0xFF059669,
    0xFFEA580C,
    0xFFE11D48,
    0xFF0D9488,
  ];

  static const List<String> colorNames = [
    "أخضر",
    "نيلي",
    "تركوازي",
    "عنابي",
    "برتقالي",
    "أزرق",
    "بنفسجي",
    "سماوي",
    "زمردي",
    "برتقالي فاتح",
    "وردي",
    "فيروزي",
  ];
}