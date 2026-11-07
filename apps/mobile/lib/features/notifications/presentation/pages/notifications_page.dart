import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<NotificationCubit>>() != null;

    if (!hasCubit) {
      return _buildStaticFallback(context, theme, isArabic);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الإشعارات والتنبيهات' : 'Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            onPressed: () => context.read<NotificationCubit>().loadNotifications(),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationLoaded) {
            final prefs = state.preferences;
            final announcements = state.announcements;

            return RefreshIndicator(
              onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Permission status banner if not granted
                  if (!state.permissionGranted) ...[
                    RamezGlassCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_off_outlined, color: Colors.amber, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'إشعارات النظام معطلة' : 'System Notifications Disabled',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isArabic
                                      ? 'يرجى تفعيل صلاحية الإشعارات لمتابعة حالة نفق VPN والتنبيهات الأمنية.'
                                      : 'Enable notification permission to track VPN tunnel drops and security alerts.',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.read<NotificationCubit>().grantPermission(true),
                            child: Text(isArabic ? 'تفعيل' : 'Enable'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 2. Notification Categories Section
                  Text(
                    isArabic ? 'فئات الإشعارات والتنبيهات' : 'Notification Categories',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  RamezGlassCard(
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: prefs.notifyConnection,
                          title: Text(isArabic ? 'تنبيه الاتصال الناجح' : 'Connection Established'),
                          subtitle: Text(
                            isArabic ? 'إشعار فوري عند اكتمال نفق VPN' : 'Notify when VPN tunnel connects',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifyConnection: v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: prefs.notifyDisconnection,
                          title: Text(isArabic ? 'تنبيه انقطاع الاتصال' : 'Disconnection Alert'),
                          subtitle: Text(
                            isArabic ? 'تنبيه إذا انقطع النفق أو تم فصله' : 'Notify when tunnel disconnects',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifyDisconnection: v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: prefs.notifyServerFailure,
                          title: Text(isArabic ? 'فشل الخوادم والصيانة' : 'Server Degradation & Maintenance'),
                          subtitle: Text(
                            isArabic ? 'تنبيهات حالة العقد وتراجع السرعة' : 'Node health & maintenance alerts',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifyServerFailure: v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: prefs.notifySubscriptionExpiry,
                          title: Text(isArabic ? 'انتهاء الاشتراك وتجاوز الحصة' : 'Subscription & Quota Alerts'),
                          subtitle: Text(
                            isArabic ? 'تذكير قبل انتهاء باقة VIP أو حد البيانات' : 'Reminders before VIP renewal or bandwidth cap',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifySubscriptionExpiry: v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: prefs.notifySecurityAlerts,
                          title: Text(isArabic ? 'تنبيهات الأمان ومنع التسرب' : 'Security & Leak Protection'),
                          subtitle: Text(
                            isArabic ? 'فحص تلقائي لتسرب DNS وحظر الاختراق' : 'Warnings if DNS leaks or insecure Wi-Fi detected',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifySecurityAlerts: v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: prefs.notifyUpdates,
                          title: Text(isArabic ? 'تحديثات التطبيق والميزات' : 'App Releases & Features'),
                          subtitle: Text(
                            isArabic ? 'إشعار عند توفر إصدار جديد أو خوادم جديدة' : 'Get notified on new app versions and protocols',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifyUpdates: v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: prefs.notifyPromotions,
                          title: Text(isArabic ? 'العروض الترويجية والخصومات' : 'Promotions & Discounts'),
                          subtitle: Text(
                            isArabic ? 'أكواد القسائم المجانية وهدايا VIP' : 'Voucher gifts and special seasonal offers',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onChanged: (v) => context.read<NotificationCubit>().togglePreference(notifyPromotions: v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Recent Broadcast Alerts & Announcements
                  Text(
                    isArabic ? 'آخر التنبيهات وإعلانات النظام' : 'Recent Announcements & Alerts',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (announcements.isEmpty)
                    RamezGlassCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            isArabic ? 'لا توجد إعلانات نشطة حالياً' : 'No active announcements',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      ),
                    )
                  else
                    ...announcements.map((item) {
                      final icon = _resolveIcon(item.icon, item.category);

                      return RamezGlassCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, size: 20, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      if (item.time.isNotEmpty)
                                        Text(
                                          item.time,
                                          style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.body,
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  IconData _resolveIcon(String iconName, String category) {
    switch (iconName.toLowerCase()) {
      case 'dns':
        return Icons.dns_outlined;
      case 'security':
        return Icons.security;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return category == 'promotions'
            ? Icons.card_giftcard
            : (category == 'security_alerts' ? Icons.shield_outlined : Icons.notifications_active_outlined);
    }
  }

  Widget _buildStaticFallback(BuildContext context, ThemeData theme, bool isArabic) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الإشعارات والتنبيهات' : 'Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RamezGlassCard(
            child: SwitchListTile(
              value: true,
              title: Text(isArabic ? 'تنبيهات الاتصال' : 'Connection Alerts'),
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}
