import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'theme_extension.dart';

class AppTheme {
  // App colors often look pale because Material 3 generates tonal palettes.
  // Override primary with the raw preset seed color so buttons and accents
  // render with the exact strong brand color.
  static ColorScheme _strongColorScheme(Color seedColor, Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ).copyWith(
      primary: seedColor,
      onPrimary: Colors.white,
    );
  }

  static ThemeData lightTheme(Color seedColor) {
    final colorScheme = _strongColorScheme(seedColor, Brightness.light);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      extensions: [
        RamezThemeExtension(
          glassBackground: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          glassBorder: colorScheme.outlineVariant.withValues(alpha: 0.3),
          connectedColor: AppColors.success,
          connectingColor: AppColors.warning,
          disconnectedColor: colorScheme.outline,
          buttonGlowGradient: LinearGradient(
            colors: [seedColor, seedColor.withValues(alpha: 0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          cardElevation: 1.0,
        ),
      ],
    );
  }

  static ThemeData darkTheme(Color seedColor) {
    final colorScheme = _strongColorScheme(seedColor, Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Alahisan-style dark background (deep navy/charcoal)
      scaffoldBackgroundColor: AppColors.darkColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Color(0xFFF8FAFC),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E293B).withValues(alpha: 0.8), // Slate 800
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      extensions: [
        RamezThemeExtension(
          glassBackground: const Color(0xFF1E293B).withValues(alpha: 0.6),
          glassBorder: Colors.white.withValues(alpha: 0.1),
          connectedColor: AppColors.success,
          connectingColor: AppColors.warning,
          disconnectedColor: Colors.white38,
          buttonGlowGradient: LinearGradient(
            colors: [seedColor, seedColor.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          cardElevation: 2.0,
        ),
      ],
    );
  }
}
