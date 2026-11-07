import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLocale = context.watch<LocaleCubit>().state;
    final isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'اختيار اللغة' : 'Language'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            isArabic
                ? 'يتم تغيير اتجاه الواجهة (RTL/LTR) فوراً'
                : 'Interface direction (RTL/LTR) adapts instantly',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _LanguageTile(
            context: context,
            isArabic: isArabic,
            flag: '🇸🇦',
            name: 'العربية',
            sub: 'Arabic (RTL)',
            active: isArabic,
            onTap: () => context.read<LocaleCubit>().setLocale(const Locale('ar')),
          ),
          const SizedBox(height: 12),
          _LanguageTile(
            context: context,
            isArabic: isArabic,
            flag: '🇺🇸',
            name: 'English',
            sub: 'English (LTR)',
            active: !isArabic,
            onTap: () => context.read<LocaleCubit>().setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final BuildContext context;
  final bool isArabic;
  final String flag;
  final String name;
  final String sub;
  final bool active;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.context,
    required this.isArabic,
    required this.flag,
    required this.name,
    required this.sub,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RamezGlassCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? colorScheme.primary.withValues(alpha: 0.15) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(flag, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    if (active) ...[
                      const Spacer(),
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
