import 'package:flutter/material.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'q_en': 'How do I connect to a VPN server?',
      'a_en': 'Simply open the app and tap the large power button in the center of the home screen. The app will automatically connect you to the fastest available node.',
      'q_ar': 'كيف أتصل بخادم VPN؟',
      'a_ar': 'ببساطة افتح التطبيق واضغط على زر الاتصال الكبير في منتصف الشاشة الرئيسية. سيتولى التطبيق الاتصال تلقائياً بأسرع خادم متاح.',
    },
    {
      'q_en': 'Do I need an account or password to use the app?',
      'a_en': 'No. Ramez Tunnel Plus is device-first. Your device identity is securely authenticated without requiring an email or password.',
      'q_ar': 'هل أحتاج إلى إنشاء حساب أو كلمة مرور؟',
      'a_ar': 'لا. التطبيق يعمل بهوية الجهاز المباشرة. يتم التحقق من جهازك تلقائياً دون الحاجة لإدخال بريد إلكتروني أو كلمة مرور.',
    },
    {
      'q_en': 'How do I import an OpenVPN (.ovpn) file?',
      'a_en': 'Navigate to Configurations, tap "Import Profile", and select your .ovpn file from your device or paste the text from your clipboard.',
      'q_ar': 'كيف أستورد ملف OpenVPN بصيغة .ovpn؟',
      'a_ar': 'انتقل إلى شاشة الإعدادات، ثم اضغط على "استيراد ملف"، وحدد ملف .ovpn من هاتفك أو الصق النص مباشرة من الحافظة.',
    },
    {
      'q_en': 'Does the app log my browsing history?',
      'a_en': 'Strictly NO. We follow a strict zero-logs policy. All DNS queries and web destinations are routed through encrypted tunnels and never stored.',
      'q_ar': 'هل يقوم التطبيق بتسجيل المواقع التي أزورها؟',
      'a_ar': 'قطعاً لا. نحن نلتزم بسياسة صارمة لعدم حفظ السجلات (Zero-Logs). جميع البيانات والاستعلامات مشفرة بالكامل ولا يتم تخزينها أبداً.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: const ModernAppBar(title: 'FAQ & Troubleshooting', subtitle: 'Common questions & answers'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return RamezGlassCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.zero,
            child: ExpansionTile(
              title: Text(
                (isArabic ? faq['q_ar'] : faq['q_en'])!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    (isArabic ? faq['a_ar'] : faq['a_en'])!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
