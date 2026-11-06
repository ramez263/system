import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  final List<Map<String, dynamic>> _mockHistory = const [
    {
      'server': 'Frankfurt OpenVPN 01',
      'flag': '🇩🇪',
      'date': '2026-11-06 14:22',
      'duration': '42m 10s',
      'data': '380 MB',
      'status': 'Success',
    },
    {
      'server': 'Amsterdam Ultra 01',
      'flag': '🇳🇱',
      'date': '2026-11-05 20:15',
      'duration': '1h 12m',
      'data': '1.2 GB',
      'status': 'Success',
    },
    {
      'server': 'London Express 01',
      'flag': '🇬🇧',
      'date': '2026-11-04 11:05',
      'duration': '15m 30s',
      'data': '92 MB',
      'status': 'Disconnected by User',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'سجل الجلسات السابقة' : 'Session History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: isArabic ? 'تصدير كملف CSV' : 'Export CSV',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'تم تصدير سجل الجلسات إلى ملف CSV بنجاح'
                        : 'History successfully exported to CSV',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockHistory.length,
              itemBuilder: (context, index) {
                final item = _mockHistory[index];
                return RamezGlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(item['flag'] as String, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['server'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item['date']} • ${item['duration']}',
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['data'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Completed',
                            style: TextStyle(fontSize: 11, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RamezButton(
              label: isArabic ? 'تصدير السجل إلى ملف CSV' : 'Export History (CSV)',
              variant: RamezButtonVariant.outline,
              icon: Icons.download,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isArabic ? 'تم حفظ ملف history.csv' : 'Saved history.csv to device',
                    ),
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
