import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ramez_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.shield_outlined,
      'title': 'High-Speed Tunneling',
      'title_ar': 'أنفاق شبكية فائقة السرعة',
      'desc': 'Connect through optimized OpenVPN & modern proxy protocols with one tap.',
      'desc_ar': 'اتصل عبر خوادم OpenVPN وبروتوكولات الأنفاق الحديثة بضغطة زر واحدة.',
    },
    {
      'icon': Icons.lock_clock_outlined,
      'title': 'Zero-Logs & Privacy First',
      'title_ar': 'خصوصية تامة بدون سجلات',
      'desc': 'No registration, no personal credentials required. Your device ID is your key.',
      'desc_ar': 'بدون تسجيل وبدون بيانات شخصية. معرف جهازك هو مفتاح وصولك المباشر.',
    },
    {
      'icon': Icons.speed_outlined,
      'title': 'Full Protocol Control',
      'title_ar': 'تحكم متكامل في البروتوكولات',
      'desc': 'Import custom .ovpn and .rtp profiles, inspect latency, and customize DNS.',
      'desc_ar': 'استورد ملفات .ovpn و .rtp وافحص زمن الاستجابة وتحكم في إعدادات DNS.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: TextButton(
                  onPressed: () => context.go(AppRouter.homePath),
                  child: Text(isArabic ? 'تخطي' : 'Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          isArabic ? slide['title_ar'] : slide['title'],
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isArabic ? slide['desc_ar'] : slide['desc'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              RamezButton(
                label: _currentPage == _slides.length - 1
                    ? (isArabic ? 'ابدأ الآن' : 'Get Started')
                    : (isArabic ? 'التالي' : 'Next'),
                onPressed: () {
                  if (_currentPage == _slides.length - 1) {
                    context.go(AppRouter.welcomePath);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
