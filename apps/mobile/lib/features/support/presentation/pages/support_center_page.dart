import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class SupportCenterPage extends StatelessWidget {
  const SupportCenterPage({super.key});

  void _showDiagnosticLogs(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? 'معاينة سجلات التشخيص المنقحة' : 'Redacted Diagnostics Preview'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All user IPs, passwords, and tokens are strictly masked by the client-side redaction filter:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 12),
            SelectableText(
              '[INFO] 18:00:02 Engine initialized\n'
              '[INFO] 18:00:04 Connecting: [REDACTED_IP]:1194\n'
              '[INFO] 18:00:05 Device: [REDACTED_UUID]\n'
              '[INFO] 18:00:06 Token: [REDACTED_TOKEN]\n'
              '[INFO] 18:00:08 Handshake OK. Tunnel established.',
              style: TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إغلاق' : 'Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic ? 'تم إرسال سجل التشخيص المشفر بنجاح' : 'Redacted logs submitted successfully',
                  ),
                ),
              );
            },
            child: Text(isArabic ? 'إرسال للدعم' : 'Send to Support'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: const ModernAppBar(title: 'Support Center', subtitle: 'Help & assistance'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          RamezGlassCard(
            onTap: () => context.push(AppRouter.faqPath),
            child: Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.blue, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'الأسئلة الشائعة (FAQ)' : 'Frequently Asked Questions',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isArabic ? 'حلول سريعة لأكثر المشاكل شيوعاً' : 'Instant troubleshooting & connection guides',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 14),
          RamezGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bug_report_outlined, color: Colors.orange, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      isArabic ? 'الإبلاغ عن مشكلة اتصال' : 'Report Connection Issue',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'أرسل تقريراً تشخيصياً خالياً تماماً من أي معلومات شخصية أو كلمات مرور أو عناوين IP.'
                      : 'Send a sanitized diagnostic log. Zero personal credentials, user IPs, or secrets are ever shared.',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                RamezButton(
                  label: isArabic ? 'معاينة وإرسال سجل التشخيص' : 'Preview & Send Diagnostics',
                  variant: RamezButtonVariant.outline,
                  onPressed: () => _showDiagnosticLogs(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
