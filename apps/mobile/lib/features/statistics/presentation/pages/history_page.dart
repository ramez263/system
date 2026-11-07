import 'package:flutter/material.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_button.dart';

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
    {
      'server': 'Singapore Hub 01',
      'flag': '🇸🇬',
      'date': '2026-11-03 08:40',
      'duration': '3h 05m',
      'data': '2.1 GB',
      'status': 'Success',
    },
    {
      'server': 'New York East 01',
      'flag': '🇺🇸',
      'date': '2026-11-02 22:10',
      'duration': '55m',
      'data': '890 MB',
      'status': 'Success',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: ModernAppBar(
        title: 'Session History',
        subtitle: 'Past connections & data usage',
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.file_download_outlined, size: 24),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _mockHistory.length,
              itemBuilder: (context, index) {
                final item = _mockHistory[index];
                final isSuccess = item['status'] == 'Success';
                return _HistoryRow(
                  flag: item['flag'] as String,
                  server: item['server'] as String,
                  date: item['date'] as String,
                  duration: item['duration'] as String,
                  data: item['data'] as String,
                  status: item['status'] as String,
                  isSuccess: isSuccess,
                  colorScheme: colorScheme,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: RamezButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isArabic ? 'تم حفظ ملف history.csv' : 'Saved history.csv to device',
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: Icons.download_rounded,
              label: isArabic ? 'تصدير السجل إلى ملف CSV' : 'Export History (CSV)',
              height: 54,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String flag;
  final String server;
  final String date;
  final String duration;
  final String data;
  final String status;
  final bool isSuccess;
  final ColorScheme colorScheme;

  const _HistoryRow({
    required this.flag,
    required this.server,
    required this.date,
    required this.duration,
    required this.data,
    required this.status,
    required this.isSuccess,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 26)),
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
                          server,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.timer,
                        size: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        duration,
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSuccess ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
