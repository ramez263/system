import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class ConnectionDetailsPage extends StatelessWidget {
  const ConnectionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تفاصيل الجلسة النشطة' : 'Active Connection Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.shield, size: 54, color: Colors.green),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'الاتصال محمي ومشفر بالكامل' : 'Connection Fully Encrypted',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Frankfurt OpenVPN 01 (185.120.40.12)',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: RamezGlassCard(
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_downward, color: Colors.blue),
                      const SizedBox(height: 4),
                      Text(isArabic ? 'تم تنزيله' : 'Downloaded', style: const TextStyle(fontSize: 12)),
                      const Text('148.6 MB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RamezGlassCard(
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.purple),
                      const SizedBox(height: 4),
                      Text(isArabic ? 'تم رفعه' : 'Uploaded', style: const TextStyle(fontSize: 12)),
                      const Text('24.2 MB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RamezGlassCard(
            child: Column(
              children: [
                _buildRow(isArabic ? 'مدة الاتصال' : 'Session Duration', '01:42:15'),
                _buildRow(isArabic ? 'عنوان IP المعين' : 'Assigned Virtual IP', '10.8.0.14'),
                _buildRow(isArabic ? 'الخادم البعيد' : 'Gateway Node', '185.120.40.12:1194'),
                _buildRow(isArabic ? 'نوع البروتوكول' : 'Protocol', 'OpenVPN (tun0)'),
                _buildRow(isArabic ? 'خوارزمية التشفير' : 'Encryption', 'AES-256-GCM / SHA256'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          RamezButton(
            label: isArabic ? 'قطع الاتصال الآن' : 'Disconnect Tunnel',
            variant: RamezButtonVariant.danger,
            icon: Icons.power_settings_new,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isArabic ? 'تم قطع الاتصال' : 'Tunnel Disconnected')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
