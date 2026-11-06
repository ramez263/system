import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'خطط الترقية والاشتراك' : 'Subscription Plans'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isArabic ? 'اختر الخطة المناسبة لاستخدامك' : 'Choose Your Tunneling Tier',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isArabic
                ? 'استمتع بسرعات غير محدودة وخوادم VIP مخصصة وتشفير معزز'
                : 'Unlock maximum speed, dedicated VIP nodes, and priority streaming.',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Plan 1: Free Starter
          RamezGlassCard(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'الباقة المجانية' : 'Free Starter',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isArabic ? 'الخطة الحالية' : 'Active',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(isArabic ? 'مجاناً مدى الحياة' : 'Free Forever', style: const TextStyle(color: Colors.grey)),
                const Divider(height: 20),
                _buildBullet(isArabic ? 'الوصول إلى الخوادم العامة' : 'Access to public OpenVPN nodes'),
                _buildBullet(isArabic ? 'جهاز واحد فقط' : '1 device connection'),
                _buildBullet(isArabic ? 'سرعة قياسية تصل 10 Mbps' : 'Standard speed up to 10 Mbps'),
              ],
            ),
          ),

          // Plan 2: Premium VIP (Highlighted)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.primary, width: 2),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  theme.colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'باقة VIP الاحترافية' : 'Premium VIP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'BEST VALUE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$4.99 / month',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                _buildBullet(isArabic ? 'سرعات غير محدودة 1 Gbps' : 'Unlimited high-speed 1 Gbps'),
                _buildBullet(isArabic ? 'خوادم VIP مخصصة للتحميل والبث' : 'Dedicated VIP streaming & gaming nodes'),
                _buildBullet(isArabic ? 'استخدام حتى 5 أجهزة معاً' : 'Up to 5 concurrent devices'),
                _buildBullet(isArabic ? 'دعم فني ذو أولوية' : 'Priority 24/7 support response'),
                const SizedBox(height: 16),
                RamezButton(
                  label: isArabic ? 'ترقية عبر Google Play' : 'Subscribe via Google Play',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic ? 'جاري فتح متجر Google Play...' : 'Opening Google Play Billing...',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
