import 'package:flutter/material.dart';

@immutable
class RamezThemeExtension extends ThemeExtension<RamezThemeExtension> {
  final Color glassBackground;
  final Color glassBorder;
  final Color connectedColor;
  final Color connectingColor;
  final Color disconnectedColor;
  final LinearGradient buttonGlowGradient;
  final double cardElevation;

  const RamezThemeExtension({
    required this.glassBackground,
    required this.glassBorder,
    required this.connectedColor,
    required this.connectingColor,
    required this.disconnectedColor,
    required this.buttonGlowGradient,
    this.cardElevation = 0.0,
  });

  @override
  RamezThemeExtension copyWith({
    Color? glassBackground,
    Color? glassBorder,
    Color? connectedColor,
    Color? connectingColor,
    Color? disconnectedColor,
    LinearGradient? buttonGlowGradient,
    double? cardElevation,
  }) {
    return RamezThemeExtension(
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      connectedColor: connectedColor ?? this.connectedColor,
      connectingColor: connectingColor ?? this.connectingColor,
      disconnectedColor: disconnectedColor ?? this.disconnectedColor,
      buttonGlowGradient: buttonGlowGradient ?? this.buttonGlowGradient,
      cardElevation: cardElevation ?? this.cardElevation,
    );
  }

  @override
  RamezThemeExtension lerp(ThemeExtension<RamezThemeExtension>? other, double t) {
    if (other is! RamezThemeExtension) return this;
    return RamezThemeExtension(
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      connectedColor: Color.lerp(connectedColor, other.connectedColor, t)!,
      connectingColor: Color.lerp(connectingColor, other.connectingColor, t)!,
      disconnectedColor: Color.lerp(disconnectedColor, other.disconnectedColor, t)!,
      buttonGlowGradient: LinearGradient.lerp(buttonGlowGradient, other.buttonGlowGradient, t)!,
      cardElevation: (cardElevation + (other.cardElevation - cardElevation) * t),
    );
  }
}
