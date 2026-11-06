import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';

class RamezGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? customBackground;
  final Border? customBorder;

  const RamezGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
    this.borderRadius = 16.0,
    this.customBackground,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<RamezThemeExtension>();

    final decoration = BoxDecoration(
      color: customBackground ?? ext?.glassBackground ?? Colors.black12,
      borderRadius: BorderRadius.circular(borderRadius),
      border: customBorder ?? Border.all(
        color: ext?.glassBorder ?? Colors.white10,
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );

    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}
