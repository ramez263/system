import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = context.watch<LocaleCubit>().state;
    final isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'اختيار اللغة' : 'Language Selection'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isArabic
                ? 'يتم تغيير اتجاه الواجهة (RTL/LTR) فوراً دون الحاجة لإعادة تشغيل التطبيق.'
                : 'Interface direction (RTL/LTR) adapts instantly without restarting the app.',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 20),
          RamezGlassCard(
            onTap: () => context.read<LocaleCubit>().setLocale(const Locale('ar')),
            child: Row(
              children: [
                const Text('🇸🇦', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('العربية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Arabic (RTL)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                if (isArabic)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RamezGlassCard(
            onTap: () => context.read<LocaleCubit>().setLocale(const Locale('en')),
            child: Row(
              children: [
                const Text('🇺🇸', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('English', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('English (LTR)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                if (!isArabic)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
