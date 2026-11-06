import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'المظهر والألوان' : 'Appearance & Theme'),
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                isArabic ? 'وضع العرض (Theme Mode)' : 'Theme Mode',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              RamezGlassCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        state.mode == ThemeMode.system
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: state.mode == ThemeMode.system
                            ? theme.colorScheme.primary
                            : null,
                      ),
                      title: Text(isArabic ? 'تلقائي حسب نظام الجهاز' : 'System Default'),
                      onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.system),
                    ),
                    ListTile(
                      leading: Icon(
                        state.mode == ThemeMode.light
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: state.mode == ThemeMode.light
                            ? theme.colorScheme.primary
                            : null,
                      ),
                      title: Text(isArabic ? 'الوضع الفاتح (Light)' : 'Light Mode'),
                      onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.light),
                    ),
                    ListTile(
                      leading: Icon(
                        state.mode == ThemeMode.dark
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: state.mode == ThemeMode.dark
                            ? theme.colorScheme.primary
                            : null,
                      ),
                      title: Text(isArabic ? 'الوضع الداكن (Dark)' : 'Dark Mode'),
                      onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isArabic ? 'حزمة الألوان المعتمدة (Color Presets)' : 'Color Preset Seed',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Column(
                children: ThemePreset.values.map((preset) {
                  final isSelected = state.preset == preset;
                  return RamezGlassCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    onTap: () => context.read<ThemeCubit>().setPreset(preset),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: preset.seedColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          preset.label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(Icons.check_circle, color: theme.colorScheme.primary),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
