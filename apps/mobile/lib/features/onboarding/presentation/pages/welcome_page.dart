import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    Icons.vpn_key_outlined,
                    size: 64,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isArabic ? 'مرحباً بك في رامز تنل بلس' : 'Welcome to Ramez Tunnel Plus',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isArabic
                    ? 'تجربة أنفاق مباشرة بدون تعقيد. لا داعي لإنشاء حساب أو تذكر كلمات مرور.'
                    : 'Instant tunneling with zero friction. No account or password required.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              RamezGlassCard(
                child: Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'معرف جهازك جاهز ومحمي بواسطة تشفير الجهاز المحلي.'
                            : 'Your device ID is ready and secured via Keystore.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              RamezButton(
                label: isArabic ? 'دخول فوري كضيف' : 'Continue as Guest',
                onPressed: () => context.go(AppRouter.homePath),
                icon: Icons.flash_on,
              ),
              const SizedBox(height: 12),
              RamezButton(
                label: isArabic ? 'نظرة عامة على هوية الجهاز' : 'View Device Identity',
                variant: RamezButtonVariant.outline,
                onPressed: () => context.push(AppRouter.deviceAuthPath),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
