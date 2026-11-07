import 'package:flutter/material.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: const ModernAppBar(title: 'About Ramez Tunnel Plus', subtitle: 'Premium VPN & tunneling'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
              ),
              child: Icon(Icons.shield_outlined, size: 60, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ramez Tunnel Plus',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Version 1.0.0 (Build 100) • Production Ready',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          RamezGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'محركات التشفير والأنفاق' : 'Core Tunneling Engines',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                _buildInfoRow('OpenVPN Native Engine', 'v2.6.8 (ICS-OpenVPN Core)'),
                _buildInfoRow('sing-box Core', 'v1.11.0 (libbox Android AAR)'),
                _buildInfoRow('Cipher Suite', 'AES-256-GCM / ChaCha20-Poly1305'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RamezGlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(isArabic ? 'سياسة الخصوصية وعدم حفظ السجلات' : 'Privacy Policy (Zero Logs)'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('https://rameztunnel.com/privacy')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(isArabic ? 'شروط الخدمة والاستخدام القانوني' : 'Terms of Service'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('https://rameztunnel.com/terms')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '© 2026 Ramez Tunnel Plus. All rights reserved.\nCompliant with Google Play VPN Service Policy.',
            style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
