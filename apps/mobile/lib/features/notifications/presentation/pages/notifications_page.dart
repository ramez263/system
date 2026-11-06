import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notifyConnection = true;
  bool _notifySecurity = true;
  bool _notifyPromotions = false;

  final List<Map<String, dynamic>> _mockNotifications = const [
    {
      'title': 'New High-Speed Server in Amsterdam',
      'body': 'Amsterdam Ultra 01 is now live with 1 Gbps port capacity.',
      'time': '2 hours ago',
      'icon': Icons.dns,
    },
    {
      'title': 'Device Handshake Verified',
      'body': 'Hardware ID verified with zero credentials stored.',
      'time': 'Yesterday',
      'icon': Icons.security,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الإشعارات والتنبيهات' : 'Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isArabic ? 'فئات الإشعارات' : 'Notification Categories',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RamezGlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: _notifyConnection,
                  title: Text(isArabic ? 'تنبيهات الاتصال وقطع الاتصال' : 'Connection & Disconnect Alerts'),
                  onChanged: (v) => setState(() => _notifyConnection = v),
                ),
                SwitchListTile(
                  value: _notifySecurity,
                  title: Text(isArabic ? 'تحذيرات الأمان وتسرب DNS' : 'Security & Leak Warnings'),
                  onChanged: (v) => setState(() => _notifySecurity = v),
                ),
                SwitchListTile(
                  value: _notifyPromotions,
                  title: Text(isArabic ? 'تحديثات الخوادم الجديدة' : 'New Server Announcements'),
                  onChanged: (v) => setState(() => _notifyPromotions = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isArabic ? 'التنبيهات الأخيرة' : 'Recent Alerts',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._mockNotifications.map(
            (n) => RamezGlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(n['icon'] as IconData, size: 20, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(n['body'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(n['time'] as String, style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
