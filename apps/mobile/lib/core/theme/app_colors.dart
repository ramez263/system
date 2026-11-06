import 'package:flutter/material.dart';

enum ThemePreset {
  oceanBlue('Ocean Blue', Color(0xFF0D6EFD)),
  purple('Royal Purple', Color(0xFF8B5CF6)),
  emerald('Emerald Green', Color(0xFF10B981)),
  midnight('Midnight Slate', Color(0xFF334155)),
  sunset('Sunset Amber', Color(0xFFF97316));

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

  // Status Colors (WCAG AA Compliant)
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444);   // Red 500
  static const Color info = Color(0xFF3B82F6);    // Blue 500

  // Neutral Scales
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}
