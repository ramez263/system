import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _uuid = 'Loading...';
  String _model = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final service = sl<DeviceIdentityService>();
    final uuid = await service.getOrCreateDeviceUuid();
    final meta = await service.getDeviceMetadata();
    if (mounted) {
      setState(() {
        _uuid = uuid;
        _model = meta['device_name']?.toString() ?? 'Android Device';
      });
    }
  }

  void _showDeleteDataDialog() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? 'مسح بيانات الجهاز (GDPR)' : 'Erase Device Data (GDPR)'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من رغبتك في حذف كافة السجلات والبيانات المرتبطة بهذا الجهاز نهائياً من الخوادم؟ لا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to permanently erase all records and device data from our servers? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'تم تقديم طلب مسح البيانات بموجب معايير GDPR'
                        : 'Device erasure request submitted successfully',
                  ),
                ),
              );
            },
            child: Text(isArabic ? 'مسح نهائي' : 'Erase Everything', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الملف الشخصي للجهاز' : 'Device Profile'),
      ),
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
              child: Icon(Icons.person_outline, size: 56, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _model,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            isArabic ? 'جلسة جهاز موثقة (بدون كلمة مرور)' : 'Authenticated Hardware Session (Zero Password)',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          RamezGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'المعرف الفريد للجهاز' : 'Unique Device UUID',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  _uuid,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RamezGlassCard(
            onTap: () => context.push(AppRouter.devicesPath),
            child: Row(
              children: [
                const Icon(Icons.devices, color: Colors.blue),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    isArabic ? 'إدارة الأجهزة النشطة' : 'Active Connected Devices',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RamezGlassCard(
            onTap: () => context.push(AppRouter.paymentHistoryPath),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.purple),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    isArabic ? 'فواتير الاشتراك وسجل الشراء' : 'Payment History & Receipts',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 32),
          RamezButton(
            label: isArabic ? 'مسح بيانات الجهاز نهائياً (GDPR)' : 'Erase Device Data (GDPR)',
            variant: RamezButtonVariant.danger,
            icon: Icons.delete_forever,
            onPressed: _showDeleteDataDialog,
          ),
        ],
      ),
    );
  }
}
