import 'package:flutter/material.dart';
import 'core/config/app_environment.dart';
import 'core/routing/app_router.dart';

class RamezTunnelApp extends StatelessWidget {
  const RamezTunnelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.instance.appName,
      debugShowCheckedModeBanner: !AppConfig.instance.isProduction,
      routerConfig: AppRouter.router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6EFD), // Ocean Blue base
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6EFD),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
