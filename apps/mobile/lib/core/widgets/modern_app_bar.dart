import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Modern app bar matching the exact design from Screenshot_٢٠٢٦١١٠٧-١٢٤٨٢٤.png:
/// - Rich deep-to-vibrant horizontal blue gradient ([#07336E] to [#0F5EA8])
/// - 32dp smooth bottom corner radii
/// - Translucent squircle (rounded rectangle) leading/back and trailing action buttons
/// - Shows screen-specific icon in squircle container if no action buttons are present
/// - If action buttons exist (like notification or add button), keeps them in squircle container without duplicate icon
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
  final IconData? screenIcon;
  final bool showScreenIcon;

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
    this.screenIcon,
    this.showScreenIcon = true,
  });

  double get effectiveHeight =>
      height ?? (subtitle != null && subtitle!.isNotEmpty ? 105.0 : 88.0);

  IconData? get effectiveIcon {
    if (screenIcon != null) return screenIcon;
    if (!showScreenIcon) return null;

    final lower = title.toLowerCase();
    if (lower.contains('auth')) return Icons.fingerprint_rounded;
    if (lower.contains('editor') || lower.contains('تعديل')) return Icons.edit_note_rounded;
    if (lower.contains('import') || lower.contains('استيراد')) return Icons.file_download_outlined;
    if (lower.contains('notif') || lower.contains('إشعار')) return Icons.notifications_none_rounded;
    if (lower.contains('device') || lower.contains('أجهز')) return Icons.devices_rounded;
    if (lower.contains('profile') || lower.contains('ملف')) return Icons.account_circle_outlined;
    if (lower.contains('server') || lower.contains('خوادم') || lower.contains('خادم')) return Icons.dns_rounded;
    if (lower.contains('network') || lower.contains('شبك')) return Icons.security_rounded;
    if (lower.contains('setting') || lower.contains('إعداد')) return Icons.settings_suggest_rounded;
    if (lower.contains('lang') || lower.contains('لغ')) return Icons.translate_rounded;
    if (lower.contains('hist') || lower.contains('سجل')) return Icons.history_rounded;
    if (lower.contains('stat') || lower.contains('telemet') || lower.contains('إحصائ') || lower.contains('بيانات')) return Icons.insights_rounded;
    if (lower.contains('pay') || lower.contains('دفع')) return Icons.receipt_long_rounded;
    if (lower.contains('plan') || lower.contains('subscrip') || lower.contains('خطة') || lower.contains('اشتراك')) return Icons.workspace_premium_rounded;
    if (lower.contains('about') || lower.contains('حول')) return Icons.info_outline_rounded;
    if (lower.contains('faq') || lower.contains('أسئل')) return Icons.help_outline_rounded;
    if (lower.contains('support') || lower.contains('دعم')) return Icons.support_agent_rounded;
    if (lower.contains('connect') || lower.contains('اتصال')) return Icons.speed_rounded;
    return Icons.shield_rounded;
  }

  Widget _wrapAction(Widget action) {
    Widget content = action;
    if (action is IconButton) {
      content = IconButton(
        icon: action.icon,
        onPressed: action.onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 46, minHeight: 46),
        color: Colors.white,
        tooltip: action.tooltip,
      );
    }
    return Center(
      child: Container(
        width: 46,
        height: 46,
        margin: const EdgeInsetsDirectional.only(end: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: IconTheme(
            data: const IconThemeData(color: Colors.white, size: 22),
            child: content,
          ),
        ),
      ),
    );
  }

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

    // Determine trailing actions
    final bool hasExplicitActions = actions != null && actions!.isNotEmpty;
    final List<Widget>? trailingWidgets;

    if (hasExplicitActions) {
      // If action buttons exist (e.g. notification, add, etc.), render them in squircles without duplicate icon
      trailingWidgets = actions!.map((action) => _wrapAction(action)).toList();
    } else if (effectiveIcon != null) {
      // If no action buttons exist, render the screen icon in squircle container
      trailingWidgets = [
        Center(
          child: Container(
            width: 46,
            height: 46,
            margin: const EdgeInsetsDirectional.only(end: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                effectiveIcon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ];
    } else {
      trailingWidgets = null;
    }

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
                child: Center(
                  child: IconTheme(
                    data: const IconThemeData(color: Colors.white, size: 22),
                    child: leadingWidget is IconButton
                        ? IconButton(
                            icon: (leadingWidget as IconButton).icon,
                            onPressed: (leadingWidget as IconButton).onPressed,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 46, minHeight: 46),
                            color: Colors.white,
                          )
                        : leadingWidget!,
                  ),
                ),
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
      actions: trailingWidgets,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(effectiveHeight);
}
