import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Modern app bar matching the exact design from Screenshot_٢٠٢٦١١٠٧-١٢٤٨٢٤.png:
/// - Rich deep-to-vibrant horizontal blue gradient ([#07336E] to [#0F5EA8])
/// - 32dp smooth bottom corner radii
/// - Translucent squircle (rounded rectangle) leading/back and trailing action buttons
/// - Centered bold white title with soft white subtitle
/// - Direction-aware back arrow (points right in Arabic RTL, left in English LTR)
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final double? height;
  final Widget? leadingWidget;
  final LinearGradient? customGradient;

  const ModernAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.height,
    this.leadingWidget,
    this.customGradient,
  });

  double get effectiveHeight =>
      height ?? (subtitle != null && subtitle!.isNotEmpty ? 105.0 : 88.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seedColor = theme.colorScheme.primary;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Use custom gradient if passed, otherwise use screenshot-matched gradient or theme-derived gradient
    final effectiveGradient = customGradient ??
        ((seedColor == AppColors.primaryBlue || seedColor == const Color(0xFF1864ab))
            ? AppColors.appBarGradient
            : AppColors.getThemeGradient(seedColor));

    return AppBar(
      toolbarHeight: effectiveHeight,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      leadingWidth: 72,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.appBarGradientStart.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      ),
      leading: leadingWidget != null
          ? Center(
              child: Container(
                width: 46,
                height: 46,
                margin: const EdgeInsetsDirectional.only(start: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: leadingWidget),
              ),
            )
          : (showBack
              ? Center(
                  child: Container(
                    width: 46,
                    height: 46,
                    margin: const EdgeInsetsDirectional.only(start: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: onBack ??
                            () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                        child: Center(
                          child: Icon(
                            isRtl
                                ? Icons.arrow_forward_rounded
                                : Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: -0.2,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      centerTitle: true,
      actions: actions != null && actions!.isNotEmpty
          ? actions!.map((action) {
              return Center(
                child: Container(
                  width: 46,
                  height: 46,
                  margin: const EdgeInsetsDirectional.only(end: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: action),
                ),
              );
            }).toList()
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(effectiveHeight);
}
