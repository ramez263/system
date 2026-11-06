import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class DeviceAuthPage extends StatefulWidget {
  const DeviceAuthPage({super.key});

  @override
  State<DeviceAuthPage> createState() => _DeviceAuthPageState();
}

class _DeviceAuthPageState extends State<DeviceAuthPage> {
  Map<String, dynamic> _meta = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  Future<void> _loadDevice() async {
    final service = sl<DeviceIdentityService>();
    final meta = await service.getDeviceMetadata();
    if (mounted) {
      setState(() {
        _meta = meta;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'هوية الجهاز الموثوقة' : 'Device Authentication'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                RamezGlassCard(
                  child: Column(
                    children: [
                      Icon(Icons.fingerprint, size: 48, color: theme.colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        isArabic ? 'معرف الجهاز المعتمد' : 'Hardware Bound Identifier',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _meta['device_uuid']?.toString() ?? '--',
                        style: theme.textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoTile(
                  isArabic ? 'طراز الجهاز' : 'Device Model',
                  _meta['device_name']?.toString() ?? '--',
                  Icons.phone_android,
                ),
                _buildInfoTile(
                  isArabic ? 'نظام التشغيل' : 'OS Version',
                  _meta['os_version']?.toString() ?? '--',
                  Icons.info_outline,
                ),
                _buildInfoTile(
                  isArabic ? 'إصدار التطبيق' : 'App Version',
                  _meta['app_version']?.toString() ?? '--',
                  Icons.code,
                ),
                _buildInfoTile(
                  isArabic ? 'حالة الحساب' : 'Account Tier',
                  isArabic ? 'ضيف (غير محدود)' : 'Guest (Free Unlimited)',
                  Icons.check_circle_outline,
                ),
                const SizedBox(height: 24),
                RamezButton(
                  label: isArabic ? 'إعادة مزامنة المعرف' : 'Sync Device Handshake',
                  variant: RamezButtonVariant.outline,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isArabic ? 'تمت مزامنة المعرف بنجاح' : 'Device synced successfully')),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
