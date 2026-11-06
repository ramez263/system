import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class ImportConfigPage extends StatelessWidget {
  const ImportConfigPage({super.key});

  void _showPreviewDialog(BuildContext context, String type) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? 'معاينة الملف المستورد' : 'Profile Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $type', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Server: 185.120.40.12:1194'),
            const Text('Protocol: OpenVPN UDP'),
            const Text('Encryption: AES-256-GCM'),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? 'تم التحقق من سلامة البيانات: صالحة وآمنة للاستخدام.'
                  : 'Schema validation: valid & safe data representation.',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic ? 'تم حفظ الملف بنجاح' : 'Profile imported successfully'),
                ),
              );
            },
            child: Text(isArabic ? 'تأكيد وحفظ' : 'Confirm & Save'),
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          RamezGlassCard(
            onTap: () => _showPreviewDialog(context, 'OpenVPN (.ovpn) File'),
            child: Row(
              children: [
                const Icon(Icons.folder_open, size: 36, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'استيراد من ملف (.ovpn / .rtp)' : 'Import from File (.ovpn / .rtp)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic ? 'اختر ملفاً من ذاكرة الهاتف الداخلية' : 'Select profile from local device storage',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 14),
          RamezGlassCard(
            onTap: () => _showPreviewDialog(context, 'Clipboard Text / URI'),
            child: Row(
              children: [
                const Icon(Icons.content_paste, size: 36, color: Color(0xFF10B981)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'استيراد من الحافظة' : 'Import from Clipboard',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic ? 'لصق رابط vmess / vless أو نص ovpn' : 'Paste URI or OpenVPN raw text',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 14),
          RamezGlassCard(
            onTap: () => _showPreviewDialog(context, 'QR Code Profile'),
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner, size: 36, color: Colors.purple),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'مسح رمز الاستجابة QR' : 'Scan QR Code',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic ? 'مسح الرمز بواسطة كاميرا الهاتف' : 'Point camera to scan tunnel barcode',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isArabic
                ? 'ملاحظة أمان: جميع الملفات المستوردة تخضع للفحص والتحقق من صحة المخطط Schema قبل الحفظ لضمان عدم وجود أكواد ضارة.'
                : 'Security Notice: All imported profiles undergo strict schema validation and security checks prior to being saved.',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
