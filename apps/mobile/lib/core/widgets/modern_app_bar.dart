import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Modern app bar inspired by alahisan's CustomAnimatedContainer design.
/// Features gradient background, flipped back button, centered title with height: 2,
/// rounded bottom corners, and box shadow.
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final double height;
  final Widget? leadingWidget;

  const ModernAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.height = 80.0,
    this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final seedColor = Theme.of(context).colorScheme.primary;

    return AppBar(
      toolbarHeight: height,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              seedColor,
              seedColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: seedColor.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
      leading: leadingWidget ??
          (showBack
              ? InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onBack ?? () => context.pop(),
                  child: Transform.flip(
                    flipX: true,
                    child: Container(
                      margin: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.forward_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                )
              : null),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              height: 2,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
