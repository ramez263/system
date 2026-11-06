import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  static const String splashPath = '/';
  static const String homePath = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splashPath,
    routes: [
      GoRoute(
        path: splashPath,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) => const SplashPage(),
      ),
      GoRoute(
        path: homePath,
        name: 'home',
        builder: (BuildContext context, GoRouterState state) => const HomePage(),
      ),
    ],
  );
}
