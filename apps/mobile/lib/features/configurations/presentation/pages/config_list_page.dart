import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_button.dart';

class ConfigListPage extends StatefulWidget {
  const ConfigListPage({super.key});

  @override
  State<ConfigListPage> createState() => _ConfigListPageState();
}

class _ConfigListPageState extends State<ConfigListPage> {
  final List<Map<String, dynamic>> _mockConfigs = [
    {
      'id': 1,
      'name': 'My Corporate OpenVPN Profile',
      'country': 'Germany',
      'flag': '🇩🇪',
      'protocol': 'OpenVPN',
      'server': 'vpn.mycompany.com',
      'port': 1194,
      'is_locked': false,
      'is_favorite': true,
      'created': '2026-11-05',
      'speed': '45 Mbps',
    },
    {
      'id': 2,
      'name': 'RTP Fast Streaming Reality',
      'country': 'Netherlands',
      'flag': '🇳🇱',
      'protocol': 'VLESS Reality',
      'server': 'stream.de.nodes.net',
      'port': 443,
      'is_locked': true,
      'is_favorite': false,
      'created': '2026-11-06',
      'speed': '120 Mbps',
    },
    {
      'id': 3,
      'name': 'London Express 01',
      'country': 'United Kingdom',
      'flag': '🇬🇧',
      'protocol': 'OpenVPN UDP',
      'server': 'uk-east.nodes.net',
      'port': 443,
      'is_locked': false,
      'is_favorite': false,
      'created': '2026-11-07',
      'speed': '88 Mbps',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: ModernAppBar(
        title: isArabic ? 'ملفات التكوين' : 'Tunnel Configs',
        subtitle: 'Manage your VPN connection profiles',
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push(AppRouter.configEditorPath),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.add, size: 24),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: RamezButton(
                    label: isArabic ? 'استيراد ملف جديد' : 'Import Profile',
                    icon: Icons.file_download_outlined,
                    onPressed: () => context.push(AppRouter.importConfigPath),
                    variant: RamezButtonVariant.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _mockConfigs.length,
              itemBuilder: (context, index) {
                final cfg = _mockConfigs[index];
                return _ConfigCard(
                  config: cfg,
                  isArabic: isArabic,
                  onFavorite: () {
                    setState(() {
                      cfg['is_favorite'] = !(cfg['is_favorite'] as bool);
                    });
                  },
                  onTap: () {
                    context.push(AppRouter.configEditorPath, extra: cfg);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  final Map<String, dynamic> config;
  final bool isArabic;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _ConfigCard({
    required this.config,
    required this.isArabic,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLocked = config['is_locked'] == true;
    final isFavorite = config['is_favorite'] == true;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    config['flag'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            config['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LOCKED',
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.amber),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${config['country']}',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${config['speed']}',
                          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${config['protocol']} • ${config['server']}:${config['port']}',
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.amber : Colors.grey,
                    ),
                    onPressed: onFavorite,
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
