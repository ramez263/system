import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class AdvancedNetworkSettingsPage extends StatefulWidget {
  const AdvancedNetworkSettingsPage({super.key});

  @override
  State<AdvancedNetworkSettingsPage> createState() => _AdvancedNetworkSettingsPageState();
}

class _AdvancedNetworkSettingsPageState extends State<AdvancedNetworkSettingsPage> {
  bool _killSwitch = true;
  bool _ipv6Protection = true;
  String _selectedDns = 'Cloudflare (1.1.1.1)';
  double _mtu = 1420;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إعدادات الشبكة المتقدمة' : 'Advanced Network'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          RamezGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  value: _killSwitch,
                  title: Text(
                    isArabic ? 'مفتاح الإيقاف التلقائي (Kill Switch)' : 'Kill Switch Protection',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isArabic
                        ? 'حظر جميع حزم البيانات تلقائياً في حال انقطاع نفق VPN فجأة.'
                        : 'Blocks all unencrypted internet traffic if the VPN tunnel drops unexpectedly.',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onChanged: (v) => setState(() => _killSwitch = v),
                ),
                const Divider(),
                SwitchListTile(
                  value: _ipv6Protection,
                  title: Text(
                    isArabic ? 'منع تسرب IPv6' : 'Block IPv6 Traffic Leaks',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isArabic
                        ? 'توجيه كافة حزم IPv6 بأمان داخل النفق أو إسقاطها.'
                        : 'Forces all IPv6 traffic through the encrypted tunnel to prevent ISP leaks.',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onChanged: (v) => setState(() => _ipv6Protection = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RamezGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'خوادم DNS المشفرة' : 'Encrypted DNS Resolvers',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDns,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cloudflare (1.1.1.1)', child: Text('Cloudflare 1.1.1.1 (DoH)')),
                    DropdownMenuItem(value: 'Google (8.8.8.8)', child: Text('Google Public DNS (DoH)')),
                    DropdownMenuItem(value: 'AdGuard Ad-Blocking', child: Text('AdGuard (Blocks Ads & Malware)')),
                    DropdownMenuItem(value: 'Custom DNS', child: Text('Custom DNS Entry')),
                  ],
                  onChanged: (v) => setState(() => _selectedDns = v ?? 'Cloudflare (1.1.1.1)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RamezGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'حجم حزمة MTU للأنفاق' : 'Tunnel MTU Size',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${_mtu.toInt()} bytes', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _mtu,
                  min: 1280,
                  max: 1500,
                  divisions: 22,
                  label: '${_mtu.toInt()}',
                  onChanged: (v) => setState(() => _mtu = v),
                ),
                Text(
                  isArabic
                      ? 'القيمة الافتراضية 1420 مثالية لشبكات 4G/5G وWi-Fi لتفادي تقطيع الحزم.'
                      : 'Default 1420 is optimal for cellular networks to prevent packet fragmentation.',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
