import 'package:flutter/material.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  final List<Map<String, dynamic>> _mockDevices = const [
    {
      'name': 'Google Pixel 8 Pro',
      'os': 'Android 14',
      'is_current': true,
      'last_seen': 'Online Now',
    },
    {
      'name': 'Samsung Galaxy Tab S9',
      'os': 'Android 13',
      'is_current': false,
      'last_seen': '2 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: const ModernAppBar(title: 'Active Devices', subtitle: 'Trusted devices list'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockDevices.length,
        itemBuilder: (context, index) {
          final device = _mockDevices[index];
          final isCurrent = device['is_current'] == true;

          return RamezGlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  device['name'].toString().contains('Tab') ? Icons.tablet_android : Icons.phone_android,
                  size: 32,
                  color: isCurrent ? theme.colorScheme.primary : Colors.grey,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            device['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isArabic ? 'هذا الجهاز' : 'THIS DEVICE',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${device['os']} • ${device['last_seen']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (!isCurrent)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic ? 'تم إلغاء ترخيص الجهاز' : 'Device session revoked',
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
