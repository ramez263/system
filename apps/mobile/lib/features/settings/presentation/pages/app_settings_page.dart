import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  void _showDiagnosticLogsModal(BuildContext context, String logs, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'سجلات التشخيص المنقحة' : 'Redacted Diagnostic Logs',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
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
                      child: const Icon(Icons.copy, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isArabic
                      ? 'تم تنقيح جميع المعرفات وعناوين IP والمفاتيح الحساسة تلقائياً وفقاً لسياسة الخصوصية.'
                      : 'All user IPs, tokens, and hardware identifiers are automatically redacted for privacy.',
                  style: TextStyle(fontSize: 12, color: Theme.of(ctx).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(ctx).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<SettingsCubit>>() != null;

    if (!hasCubit) {
      return _buildStaticFallback(context, isArabic);
    }

    return Scaffold(
      appBar: const ModernAppBar(title: 'App Settings', subtitle: 'Connection automation & diagnostics'),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded && state.feedbackMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.feedbackMessage!),
                backgroundColor: colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // 1. Auto-Connect Automation Rules
                _sectionHeader(context, isArabic ? 'قواعد الاتصال التلقائي' : 'Auto-Connect Automation'),
                const SizedBox(height: 10),
                RamezGlassCard(
                  child: Column(
                    children: [
                      _modernSwitchTile(
                        context: context,
                        isArabic: isArabic,
                        value: app.autoConnectOnBoot,
                        leading: const Icon(Icons.power_settings_new, color: Colors.deepPurple),
                        title: 'اتصال تلقائي عند بدء التشغيل',
                        subtitle: 'Connect on Device Startup',
                        arSubtitle: 'بدء تشغيل نفق VPN تلقائياً بعد إعادة التشغيل',
                        enSubtitle: 'Automatically initiate tunnel on system boot',
                        onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(autoConnectOnBoot: v),
                      ),
                      const Divider(height: 1),
                      _modernSwitchTile(
                        context: context,
                        isArabic: isArabic,
                        value: app.autoConnectOnWifi,
                        leading: const Icon(Icons.wifi, color: Colors.blue),
                        title: 'اتصال تلقائي عند الواي فاي',
                        subtitle: 'Auto-Connect on Wi-Fi',
                        arSubtitle: 'حماية فورية عند الاتصال بأي شبكة لاسلكية',
                        enSubtitle: 'Protect traffic automatically on wireless networks',
                        onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(autoConnectOnWifi: v),
                      ),
                      const Divider(height: 1),
                      _modernSwitchTile(
                        context: context,
                        isArabic: isArabic,
                        value: app.autoConnectOnCellular,
                        leading: const Icon(Icons.network_cell, color: Colors.teal),
                        title: 'اتصال تلقائي على بيانات الهاتف',
                        subtitle: 'Auto-Connect on Cellular',
                        arSubtitle: 'تأمين الاتصال أثناء التنقل',
                        enSubtitle: 'Ensure VPN active on mobile data networks',
                        onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(autoConnectOnCellular: v),
                      ),
                      const Divider(height: 1),
                      _modernSwitchTile(
                        context: context,
                        isArabic: isArabic,
                        value: app.excludeTrustedWifi,
                        leading: const Icon(Icons.home, color: Colors.green),
                        title: 'تجاوز الشبكات المنزلية الموثوقة',
                        subtitle: 'Bypass Trusted Home Networks',
                        arSubtitle: 'إيقاف VPN مؤقتاً عند الاتصال بشبكة المنزل',
                        enSubtitle: 'Pause tunnel when connected to verified Wi-Fi',
                        onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(excludeTrustedWifi: v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Data Usage Quota Alerts
                _sectionHeader(context, isArabic ? 'تنبيهات استهلاك البيانات' : 'Data Usage & Soft Cap Alerts'),
                const SizedBox(height: 10),
                RamezGlassCard(
                  child: Column(
                    children: [
                      _modernSwitchTile(
                        context: context,
                        isArabic: isArabic,
                        value: app.dataLimitAlertEnabled,
                        leading: const Icon(Icons.notifications, color: Colors.amber),
                        title: 'تنبيه حد الاستهلاك اليومي',
                        subtitle: 'Daily Bandwidth Alert',
                        arSubtitle: 'تنبيه عند اقتراب انتهاء حصة البيانات',
                        enSubtitle: 'Notify when session approaches soft cap',
                        onChanged: (v) => context.read<SettingsCubit>().updateAppSettings(dataLimitAlertEnabled: v),
                      ),
                      if (app.dataLimitAlertEnabled) ...[
                        const Divider(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isArabic ? 'حد التنبيه' : 'Alert Threshold',
                                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                              ),
                              Text(
                                '${app.dataLimitThresholdMb} MB',
                                style: TextStyle(fontWeight: FontWeight.w800, color: colorScheme.primary),
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
                _sectionHeader(context, isArabic ? 'الصيانة والتشخيص' : 'Maintenance & Diagnostics'),
                const SizedBox(height: 10),
                RamezGlassCard(
                  child: Column(
                    children: [
                      _modernListTile(
                        context: context,
                        isArabic: isArabic,
                        leading: const Icon(Icons.cleaning_services_outlined, color: Colors.amber),
                        title: 'تفريغ الذاكرة المؤقتة',
                        subtitle: 'Clear App Cache',
                        arSubtitle: 'مسح الخوادم المؤقتة وسجلات الاختبارات',
                        enSubtitle: 'Clears cached server lists and latency measurements',
                        trailingIcon: Icons.delete_outline,
                        onTap: () => context.read<SettingsCubit>().clearAppCache(),
                      ),
                      const Divider(height: 1),
                      _modernListTile(
                        context: context,
                        isArabic: isArabic,
                        leading: const Icon(Icons.bug_report_outlined, color: Colors.blue),
                        title: 'تصدير تقرير التشخيص',
                        subtitle: 'Export Diagnostic Report',
                        arSubtitle: 'تقرير فني خالٍ من البيانات الشخصية',
                        enSubtitle: 'Privacy-compliant logs without passwords or user IPs',
                        trailingIcon: Icons.chevron_right,
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

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
    );
  }

  Widget _modernSwitchTile({
    required BuildContext context,
    required bool isArabic,
    required bool value,
    required Widget leading,
    required String title,
    required String subtitle,
    required String arSubtitle,
    required String enSubtitle,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwitchListTile(
      value: value,
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        isArabic ? arSubtitle : enSubtitle,
        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
      ),
      secondary: leading,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _modernListTile({
    required BuildContext context,
    required bool isArabic,
    required Widget leading,
    required String title,
    required String subtitle,
    required String arSubtitle,
    required String enSubtitle,
    required IconData trailingIcon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      subtitle: Text(
        isArabic ? arSubtitle : enSubtitle,
        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(trailingIcon, size: 20, color: colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }

  Widget _buildStaticFallback(BuildContext context, bool isArabic) {
    return Scaffold(
      appBar: const ModernAppBar(title: 'App Settings', subtitle: 'Connection automation & diagnostics'),
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
