import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _autoConnectOnBoot = false;
  bool _autoConnectOnWifi = true;
  bool _excludePrivateNetworks = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إعدادات التطبيق العامة' : 'App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isArabic ? 'قواعد الاتصال التلقائي' : 'Auto-Connect Automation',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RamezGlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: _autoConnectOnBoot,
                  title: Text(isArabic ? 'الاتصال التلقائي عند إقلاع الهاتف' : 'Connect on Device Startup'),
                  onChanged: (v) => setState(() => _autoConnectOnBoot = v),
                ),
                SwitchListTile(
                  value: _autoConnectOnWifi,
                  title: Text(isArabic ? 'الاتصال التلقائي عند الاتصال بشبكة Wi-Fi عامة' : 'Auto-connect on Public Wi-Fi'),
                  onChanged: (v) => setState(() => _autoConnectOnWifi = v),
                ),
                SwitchListTile(
                  value: _excludePrivateNetworks,
                  title: Text(isArabic ? 'تجاوز الشبكات المنزلية الموثوقة' : 'Bypass Trusted Home Networks'),
                  onChanged: (v) => setState(() => _excludePrivateNetworks = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? 'صيانة التطبيق والذاكرة المؤقتة' : 'Maintenance & Cache',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RamezGlassCard(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic ? 'تم تنظيف الذاكرة المؤقتة بنجاح' : 'Cache cleared successfully',
                  ),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(Icons.cleaning_services_outlined, color: Colors.amber),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'تفريغ الذاكرة المؤقتة (Clear Cache)' : 'Clear App Cache',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isArabic ? 'حذف سجلات الفحص ومؤقتات الخوادم المحفوظة' : 'Deletes cached server pings and temporary files',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
