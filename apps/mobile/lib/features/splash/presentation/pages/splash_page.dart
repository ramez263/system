import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Ensure device UUID is generated and ready in secure storage
    final deviceService = sl<DeviceIdentityService>();
    await deviceService.getOrCreateDeviceUuid();

    // Small delay for smooth splash transition
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      context.go(AppRouter.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final brandColor = colorScheme.primary;

    // Dynamically adapts the vertical background gradient to the selected app color theme
    final splashGradient = AppColors.getSplashGradient(brandColor);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: splashGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 1. Top-Right subtle decorative circle (from screenshot)
              Positioned(
                top: -110,
                right: -90,
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // 2. Top-Left rounded squircle border outline (from screenshot)
              Positioned(
                top: 85,
                left: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(42),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // 3. Bottom-Right rounded squircle border outline (from screenshot)
              Positioned(
                bottom: 120,
                right: -45,
                child: Container(
                  width: 155,
                  height: 155,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(46),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // 4. Bottom-Left subtle decorative circle (from screenshot)
              Positioned(
                bottom: -110,
                left: -100,
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                ),
              ),

              // Center Brand & Logo Identity (matching screenshot)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular Emblem badge (from screenshot)
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.20),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 96,
                          height: 96,
                        ),
                      ),
                    )
                        .animate()
                        .scale(
                          duration: 900.ms,
                          curve: Curves.elasticOut,
                          begin: const Offset(0.7, 0.7),
                        )
                        .fadeIn(duration: 600.ms),

                    const SizedBox(height: 28),

                    // App Name (bold white calligraphy/modern typography)
                    Text(
                      isArabic ? 'رامز تنل بلس' : 'Ramez Tunnel Plus',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 250.ms),

                    const SizedBox(height: 8),

                    // Tagline (from screenshot)
                    Text(
                      isArabic
                          ? 'نفقك الآمن لتشفير البيانات وتخطي القيود'
                          : 'Secure, High-Speed VPN & Tunneling',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 450.ms),
                  ],
                ),
              ),

              // Bottom Loading Section (from screenshot)
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.fourRotatingDots(
                      color: Colors.white,
                      size: 34,
                    ),
                    const SizedBox(height: 14),

                    // Status text
                    Text(
                      isArabic ? '...جاري تجهيز التطبيق' : 'Initializing application...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
