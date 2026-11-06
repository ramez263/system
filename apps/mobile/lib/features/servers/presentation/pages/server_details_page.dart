import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class ServerDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? serverData;

  const ServerDetailsPage({super.key, this.serverData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final name = serverData?['name']?.toString() ?? 'Frankfurt OpenVPN 01';
    final flag = serverData?['flag']?.toString() ?? '🇩🇪';
    final country = serverData?['country_name']?.toString() ?? 'Germany';
    final city = serverData?['city']?.toString() ?? 'Frankfurt';
    final ping = serverData?['ping_ms']?.toString() ?? '28';
    final load = serverData?['load']?.toString() ?? '24';
    final protocol = serverData?['protocol']?.toString() ?? 'OpenVPN UDP';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تفاصيل الخادم' : 'Server Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Text(flag, style: const TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$city, $country',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: RamezGlassCard(
                  child: Column(
                    children: [
                      const Icon(Icons.network_ping, color: Colors.green),
                      const SizedBox(height: 6),
                      Text(isArabic ? 'زمن الاستجابة' : 'Ping', style: const TextStyle(fontSize: 12)),
                      Text('$ping ms', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RamezGlassCard(
                  child: Column(
                    children: [
                      const Icon(Icons.pie_chart_outline, color: Colors.amber),
                      const SizedBox(height: 6),
                      Text(isArabic ? 'نسبة الحمل' : 'Server Load', style: const TextStyle(fontSize: 12)),
                      Text('$load%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RamezGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'المواصفات الفنية للأنفاق' : 'Tunnel Specifications',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                _buildRow(isArabic ? 'البروتوكول الأساسي' : 'Protocol', protocol),
                _buildRow(isArabic ? 'نوع النقل' : 'Transport', 'UDP / TLS 1.3'),
                _buildRow(isArabic ? 'خوارزمية التشفير' : 'Cipher', 'AES-256-GCM'),
                _buildRow(isArabic ? 'حماية تسرب DNS' : 'DNS Leak Shield', 'Enabled (1.1.1.1)'),
                _buildRow(isArabic ? 'توجيه حركة المرور' : 'Routing', 'All Traffic (0.0.0.0/0)'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          RamezButton(
            label: isArabic ? 'اختيار هذا الخادم وتعيينه' : 'Select This Server',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isArabic ? 'تم اختيار $name' : '$name selected')),
              );
            },
            icon: Icons.check,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
