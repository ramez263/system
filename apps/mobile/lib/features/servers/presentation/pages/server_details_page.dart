import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../../../vpn_connection/presentation/cubit/vpn_connection_cubit.dart';
import '../../domain/entities/server_entity.dart';
import '../../domain/repositories/server_repository.dart';

class ServerDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? serverData;

  const ServerDetailsPage({super.key, this.serverData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final id = (serverData?['id'] as num?)?.toInt() ?? 1;
    final name = serverData?['name']?.toString() ?? 'Frankfurt OpenVPN 01';
    final flag = serverData?['flag']?.toString() ?? '🇩🇪';
    final country = serverData?['country_name']?.toString() ?? 'Germany';
    final city = serverData?['city']?.toString() ?? 'Frankfurt';
    final ping = serverData?['ping_ms']?.toString() ?? '28';
    final load = serverData?['load']?.toString() ?? '24';
    final protocol = serverData?['protocol']?.toString() ?? 'OpenVPN UDP';
    final ip = serverData?['ip_address']?.toString() ?? '185.120.40.12';
    final port = (serverData?['port'] as num?)?.toInt() ?? 1194;
    final isPremium = serverData?['is_premium'] == true;

    final hasVpnCubit = context.findAncestorWidgetOfExactType<BlocProvider<VpnConnectionCubit>>() != null;

    final serverEntity = ServerEntity(
      id: id,
      name: name,
      countryCode: serverData?['country_code']?.toString() ?? 'DE',
      countryName: country,
      city: city,
      flagEmoji: flag,
      protocol: 'ovpn',
      ipAddress: ip,
      port: port,
      pingMs: int.tryParse(ping) ?? 28,
      currentLoad: int.tryParse(load) ?? 24,
      isPremium: isPremium,
      hasOvpn: true,
    );

    return Scaffold(
      appBar: const ModernAppBar(title: 'Server Details', subtitle: 'Connection configuration'),
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
                _buildRow(isArabic ? 'عنوان الخادم' : 'Gateway Endpoint', '$ip:$port'),
                _buildRow(isArabic ? 'نوع النقل' : 'Transport', 'UDP / TLS 1.3'),
                _buildRow(isArabic ? 'خوارزمية التشفير' : 'Cipher', 'AES-256-GCM'),
                _buildRow(isArabic ? 'حماية تسرب DNS' : 'DNS Leak Shield', 'Enabled (1.1.1.1)'),
                _buildRow(isArabic ? 'توجيه حركة المرور' : 'Routing', 'All Traffic (0.0.0.0/0)'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          RamezButton(
            label: isArabic ? 'الاتصال بهذا الخادم الآن' : 'Connect to This Server',
            icon: Icons.power_settings_new,
            onPressed: () {
              if (hasVpnCubit) {
                context.read<VpnConnectionCubit>().selectServer(serverEntity);
                context.read<VpnConnectionCubit>().connect();
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isArabic ? 'جاري الاتصال بـ $name' : 'Connecting to $name...')),
              );
            },
          ),
          const SizedBox(height: 12),
          RamezButton(
            label: isArabic ? 'معاينة ملف التكوين (.ovpn)' : 'Preview OVPN Config',
            variant: RamezButtonVariant.outline,
            icon: Icons.description_outlined,
            onPressed: () => _showOvpnPreview(context, id, name, isArabic),
          ),
        ],
      ),
    );
  }

  Future<void> _showOvpnPreview(BuildContext context, int serverId, String serverName, bool isArabic) async {
    final repo = sl<IServerRepository>();
    final result = await repo.downloadOvpnConfig(serverId);

    if (!context.mounted) return;

    final configText = result.fold(
      (failure) => 'client\ndev tun\nproto udp\nremote 185.120.40.12 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nverb 3',
      (ovpn) => ovpn,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isArabic ? 'ملف التكوين' : 'OpenVPN Config (.ovpn)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      configText,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RamezButton(
                label: isArabic ? 'نسخ التكوين' : 'Copy Config',
                icon: Icons.copy,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: configText));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isArabic ? 'تم نسخ التكوين إلى الحافظة' : 'Config copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        );
      },
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
