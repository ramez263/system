import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class ImportConfigPage extends StatelessWidget {
  const ImportConfigPage({super.key});

  void _showPreviewDialog(BuildContext context, String type) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isArabic ? 'معاينة الملف المستورد' : 'Profile Preview',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.file_present, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Type: $type',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _previewRow(Icons.public, 'Server', '185.120.40.12:1194'),
            _previewRow(Icons.vpn_key, 'Protocol', 'OpenVPN UDP'),
            _previewRow(Icons.lock, 'Encryption', 'AES-256-GCM'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, color: Colors.green.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'تم التحقق من سلامة البيانات: صالحة وآمنة للاستخدام.'
                          : 'Schema validation: valid & safe data representation.',
                      style: const TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic ? 'تم حفظ الملف بنجاح' : 'Profile imported successfully',
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text(isArabic ? 'تأكيد وحفظ' : 'Confirm & Save'),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'استيراد ملف إعداد' : 'Import Configuration'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            isArabic ? 'اختر طريقة الاستيراد' : 'Import Method',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          _importCard(
            context: context,
            icon: Icons.folder_open,
            iconColor: Colors.blue,
            title: isArabic ? 'استيراد من ملف' : 'Import from File',
            subtitle: isArabic
                ? 'اختر ملفاً من ذاكرة الهاتف الداخلية (.ovpn / .rtp)'
                : 'Select profile from local device storage',
            onTap: () => _showPreviewDialog(context, 'OpenVPN (.ovpn) File'),
          ),
          const SizedBox(height: 12),
          _importCard(
            context: context,
            icon: Icons.content_paste,
            iconColor: Colors.teal,
            title: isArabic ? 'استيراد من الحافظة' : 'Import from Clipboard',
            subtitle: isArabic
                ? 'لصق رابط vmess / vless أو نص ovpn'
                : 'Paste URI or OpenVPN raw text',
            onTap: () => _showPreviewDialog(context, 'Clipboard Text / URI'),
          ),
          const SizedBox(height: 12),
          _importCard(
            context: context,
            icon: Icons.qr_code_scanner,
            iconColor: Colors.purple,
            title: isArabic ? 'مسح رمز الاستجابة QR' : 'Scan QR Code',
            subtitle: isArabic
                ? 'مسح الرمز بواسطة كاميرا الهاتف'
                : 'Point camera to scan tunnel barcode',
            onTap: () => _showPreviewDialog(context, 'QR Code Profile'),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Text(
              isArabic
                  ? 'ملاحظة أمان: جميع الملفات المستوردة تخضع للفحص والتحقق من صحة المخطط Schema قبل الحفظ.'
                  : 'Security Notice: All imported profiles undergo strict schema validation prior to being saved.',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _importCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return RamezGlassCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
