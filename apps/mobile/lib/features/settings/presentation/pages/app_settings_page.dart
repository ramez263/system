import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  void _showDiagnosticLogsModal(BuildContext context, String logs, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isArabic ? 'سجلات التشخيص المنقحة' : 'Redacted Diagnostic Logs',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: isArabic ? 'نسخ السجل' : 'Copy Logs',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: logs));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic ? 'تم نسخ سجلات التشخيص للحافظة' : 'Diagnostic logs copied to clipboard',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'تم تنقيح جميع المعرفات وعناوين IP والمفاتيح الحساسة تلقائياً وفقاً لسياسة الخصوصية.'
                    : 'All user IPs, tokens, and hardware identifiers are automatically redacted for privacy.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    logs,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<SettingsCubit>>() != null;

    if (!hasCubit) {
      return _buildStaticFallback(context, isArabic);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إعدادات التطبيق العامة' : 'App Settings'),
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded && state.feedbackMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.feedbackMessage!),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            final app = state.appSettings;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Auto-Connect Automation Rules
                Text(
                  isArabic ? 'قواعد الاتصال التلقائي' : 'Auto-Connect Automation',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                RamezGlassCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: app.autoConnectOnBoot,
                        title: Text(isArabic ? 'الاتصال عند إقلاع الجهاز' : 'Connect on Device Startup'),
                        subtitle: Text(
                          isArabic ? 'بدء تشغيل نفق VPN تلقائياً بعد إعادة التشغيل' : 'Automatically initiate tunnel on system boot',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(autoConnectOnBoot: v),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: app.autoConnectOnWifi,
                        title: Text(isArabic ? 'الاتصال عند استخدام Wi-Fi' : 'Auto-Connect on Wi-Fi'),
                        subtitle: Text(
                          isArabic ? 'حماية فورية عند الاتصال بأي شبكة لاسلكية' : 'Protect traffic automatically on wireless networks',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(autoConnectOnWifi: v),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: app.autoConnectOnCellular,
                        title: Text(isArabic ? 'الاتصال على بيانات الهاتف (4G/5G)' : 'Auto-Connect on Cellular (4G/5G)'),
                        subtitle: Text(
                          isArabic ? 'تأمين الاتصال أثناء التنقل' : 'Ensure VPN active on mobile data networks',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(autoConnectOnCellular: v),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: app.excludeTrustedWifi,
                        title: Text(isArabic ? 'تجاوز الشبكات المنزلية الموثوقة' : 'Bypass Trusted Home Networks'),
                        subtitle: Text(
                          isArabic ? 'إيقاف VPN مؤقتاً عند الاتصال بشبكة المنزل' : 'Pause tunnel when connected to verified Wi-Fi',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(excludeTrustedWifi: v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Data Usage Quota Alerts
                Text(
                  isArabic ? 'تنبيهات استهلاك البيانات' : 'Data Usage & Soft Cap Alerts',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                RamezGlassCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: app.dataLimitAlertEnabled,
                        title: Text(isArabic ? 'تفعيل تنبيه حد الاستهلاك اليومي' : 'Daily Bandwidth Alert'),
                        subtitle: Text(
                          isArabic ? 'تنبيه عند اقتراب انتهاء حصة البيانات' : 'Notify when session approaches soft cap',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(dataLimitAlertEnabled: v),
                      ),
                      if (app.dataLimitAlertEnabled) ...[
                        const Divider(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isArabic ? 'حد التنبيه' : 'Alert Threshold'),
                              Text(
                                '${app.dataLimitThresholdMb} MB',
                                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                        Slider(
                          value: app.dataLimitThresholdMb.toDouble(),
                          min: 500,
                          max: 5000,
                          divisions: 9,
                          label: '${app.dataLimitThresholdMb} MB',
                          onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(dataLimitThresholdMb: v.toInt()),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Maintenance, Cache & Diagnostics
                Text(
                  isArabic ? 'الصيانة والتشخيص والخصوصية' : 'Maintenance & Diagnostics',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                RamezGlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.cleaning_services_outlined, color: Colors.amber),
                        title: Text(
                          isArabic ? 'تفريغ الذاكرة المؤقتة (Clear Cache)' : 'Clear App Cache',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          isArabic ? 'مسح الخوادم المؤقتة وسجلات الاختبارات' : 'Clears cached server lists and latency measurements',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        onTap: () => context.read<SettingsCubit>().clearAppCache(),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.bug_report_outlined, color: Colors.blue),
                        title: Text(
                          isArabic ? 'تصدير تقرير التشخيص المنقح' : 'Export Redacted Diagnostic Report',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          isArabic
                              ? 'تقرير فني خالٍ من البيانات الشخصية وعناوين IP'
                              : 'Privacy-compliant logs without passwords or user IPs',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final logs = await context.read<SettingsCubit>().exportDiagnosticReport();
                          if (context.mounted) {
                            _showDiagnosticLogsModal(context, logs, isArabic);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStaticFallback(BuildContext context, bool isArabic) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إعدادات التطبيق العامة' : 'App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RamezGlassCard(
            child: ListTile(
              title: Text(isArabic ? 'تفريغ الذاكرة المؤقتة' : 'Clear Cache'),
            ),
          ),
        ],
      ),
    );
  }
}
