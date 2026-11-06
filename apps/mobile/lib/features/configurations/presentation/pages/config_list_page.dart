import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

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
      'protocol': 'OpenVPN',
      'server': 'vpn.mycompany.com',
      'port': 1194,
      'is_locked': false,
      'is_favorite': true,
      'created': '2026-11-05',
    },
    {
      'id': 2,
      'name': 'RTP Fast Streaming Reality',
      'protocol': 'VLESS Reality',
      'server': 'stream.de.nodes.net',
      'port': 443,
      'is_locked': true,
      'is_favorite': false,
      'created': '2026-11-06',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'ملفات الإعداد والتكوين' : 'Tunnel Configurations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: isArabic ? 'إنشاء ملف مخصص' : 'New Config',
            onPressed: () => context.push(AppRouter.configEditorPath),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: RamezButton(
                    label: isArabic ? 'استيراد ملف جديد' : 'Import Profile',
                    icon: Icons.file_download_outlined,
                    onPressed: () => context.push(AppRouter.importConfigPath),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mockConfigs.length,
              itemBuilder: (context, index) {
                final cfg = _mockConfigs[index];
                return RamezGlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          cfg['protocol'] == 'OpenVPN' ? Icons.security : Icons.cloud_queue,
                          color: theme.colorScheme.onPrimaryContainer,
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
                                    cfg['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (cfg['is_locked'] == true) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.lock, size: 14, color: Colors.amber),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${cfg['protocol']} • ${cfg['server']}:${cfg['port']}',
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          cfg['is_favorite'] == true ? Icons.star : Icons.star_border,
                          color: cfg['is_favorite'] == true ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            cfg['is_favorite'] = !(cfg['is_favorite'] as bool);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
