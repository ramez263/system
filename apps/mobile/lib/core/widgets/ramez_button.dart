import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum RamezButtonVariant { primary, secondary, outline, danger }

class RamezButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final RamezButtonVariant variant;
  final double? width;
  final double height;
  final Gradient? customGradient;

  const RamezButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = RamezButtonVariant.primary,
    this.width,
    this.height = 50.0, // Minimum 48dp accessibility touch target
    this.customGradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    // Primary button: render with the signature AppBar gradient
    if (variant == RamezButtonVariant.primary) {
      final effectiveGradient = customGradient ??
          ((theme.colorScheme.primary == AppColors.primaryBlue ||
                  theme.colorScheme.primary == const Color(0xFF1864ab))
              ? AppColors.appBarGradient
              : AppColors.getThemeGradient(theme.colorScheme.primary));

      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? effectiveGradient
              : LinearGradient(
                  colors: [
                    AppColors.appBarGradientStart.withValues(alpha: 0.4),
                    AppColors.appBarGradientEnd.withValues(alpha: 0.4),
                  ],
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.appBarGradientStart.withValues(alpha: 0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isEnabled ? onPressed : null,
            child: Center(
              child: isLoading
                  ? LoadingAnimationWidget.threeArchedCircle(
                      color: Colors.white,
                      size: 22,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: Colors.white),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case RamezButtonVariant.primary:
        backgroundColor = theme.colorScheme.primary;
        foregroundColor = theme.colorScheme.onPrimary;
        break;
      case RamezButtonVariant.secondary:
        backgroundColor = theme.colorScheme.secondaryContainer;
        foregroundColor = theme.colorScheme.onSecondaryContainer;
        break;
      case RamezButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.primary;
        borderSide = BorderSide(color: theme.colorScheme.primary, width: 1.5);
        break;
      case RamezButtonVariant.danger:
        backgroundColor = theme.colorScheme.error;
        foregroundColor = theme.colorScheme.onError;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: variant == RamezButtonVariant.outline ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: borderSide ?? BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? LoadingAnimationWidget.threeArchedCircle(
                color: foregroundColor,
                size: 22,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
      ),
    );
  }
}
