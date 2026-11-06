import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/device_identity_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbitController;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _ringAnimation = Tween<double>(begin: 0, end: 2 * pi)
        .animate(
          CurvedAnimation(parent: _orbitController, curve: Curves.linear),
        );

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
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Background follows the selected theme preset (seed color)
    final brandColor = colorScheme.primary;
    final surfaceColor = colorScheme.surface;

    final textColor = isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [surfaceColor, colorScheme.surfaceContainerHighest]
                : [brandColor, brandColor.withValues(alpha: 0.8)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative glow blobs that follow the theme color
              Positioned(
                top: -120,
                left: -60,
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        brandColor.withValues(alpha: isDark ? 0.25 : 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -130,
                right: -70,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        brandColor.withValues(alpha: isDark ? 0.15 : 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Central animated universe: ring + orbiting planets around logo
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated ring + planets container
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer rotating ring
                          AnimatedBuilder(
                            animation: _ringAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _ringAnimation.value,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: brandColor.withValues(
                                        alpha: isDark ? 0.5 : 0.35,
                                      ),
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Orbiting planets
                          ...List.generate(3, (index) {
                            final double angleOffset =
                                (index / 3) * 2 * pi;
                            final double orbitRadius = 60 + (index * 14);
                            final planetColors = [
                              brandColor.withValues(alpha: 0.9),
                              brandColor.withValues(alpha: 0.65),
                              brandColor.withValues(alpha: 0.45),
                            ];

                            final double planetSize = 10 + (index * 3);

                            return AnimatedBuilder(
                              animation: _ringAnimation,
                              builder: (context, child) {
                                final double angle =
                                    _ringAnimation.value + angleOffset;
                                // Elliptical orbit around the center (100, 100)
                                final double x =
                                    100 + orbitRadius * cos(angle) - planetSize / 2;
                                final double y =
                                    100 + orbitRadius * 0.62 * sin(angle) -
                                        planetSize / 2;
                                return Positioned(
                                  left: x,
                                  top: y,
                                  child: Container(
                                    width: planetSize,
                                    height: planetSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: planetColors[index],
                                      boxShadow: [
                                        BoxShadow(
                                          color: planetColors[index]
                                              .withValues(alpha: 0.6),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),

                          // Logo in glass card at center
                          Container(
                            margin: const EdgeInsets.all(26),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: surfaceColor.withValues(
                                alpha: isDark ? 0.14 : 0.17,
                              ),
                              border: Border.all(
                                color: textColor.withValues(
                                  alpha: isDark ? 0.18 : 0.22,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: brandColor.withValues(alpha: 0.28),
                                  blurRadius: 36,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 96,
                              height: 96,
                            ),
                          )
                              .animate()
                              .scale(
                                duration: 1100.ms,
                                curve: Curves.elasticOut,
                                begin: const Offset(0.6, 0.6),
                              )
                              .shimmer(
                                duration: 2200.ms,
                                color: textColor.withValues(alpha: 0.3),
                              ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 100.ms),

                    const SizedBox(height: 8),

                    // App name with strong solid color
                    Text(
                      'Ramez Tunnel Plus',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.6,
                        color: isDark ? brandColor : Colors.white,
                        height: 1.05,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 300.ms),

                    const SizedBox(height: 12),

                    // Tagline
                    Text(
                      'Secure, High-Speed VPN & Tunneling',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor.withValues(alpha: 0.9),
                        letterSpacing: 0.7,
                        height: 1.5,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 550.ms),

                    const SizedBox(height: 66),

                    // Modern loading animation (loading_animation_widget)
                    SizedBox(
                      height: 72,
                      width: 72,
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: textColor,
                        size: 46,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 800.ms)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          duration: 800.ms,
                          delay: 800.ms,
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: 22),

                    // Subtle status text
                    Text(
                      'Initializing secure connection...',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 1000.ms),
                  ],
                ),
              ),

              // Bottom version badge
              Positioned(
                bottom: 36,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: textColor.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'v1.0.0',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: textColor.withValues(alpha: 0.85),
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 1100.ms),
            ],
          ),
        ),
      ),
    );
  }
}
