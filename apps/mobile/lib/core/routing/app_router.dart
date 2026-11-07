import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/auth/presentation/pages/device_auth_page.dart';
import '../../features/configurations/presentation/pages/config_editor_page.dart';
import '../../features/configurations/presentation/pages/config_list_page.dart';
import '../../features/configurations/presentation/pages/import_config_page.dart';
import '../../features/dashboard/presentation/pages/changelog_page.dart';
import '../../features/dashboard/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/profile/presentation/pages/devices_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/servers/presentation/pages/server_details_page.dart';
import '../../features/servers/presentation/pages/server_list_page.dart';
import '../../features/settings/presentation/pages/advanced_network_settings_page.dart';
import '../../features/settings/presentation/pages/app_settings_page.dart';
import '../../features/settings/presentation/pages/appearance_page.dart';
import '../../features/settings/presentation/pages/language_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/statistics/presentation/pages/history_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/subscriptions/presentation/pages/payment_history_page.dart';
import '../../features/subscriptions/presentation/pages/plans_page.dart';
import '../../features/support/presentation/pages/about_page.dart';
import '../../features/support/presentation/pages/faq_page.dart';
import '../../features/support/presentation/pages/support_center_page.dart';
import '../../features/vpn_connection/presentation/pages/connection_details_page.dart';

class AppRouter {
  static const String splashPath = '/';
  static const String onboardingPath = '/onboarding';
  static const String welcomePath = '/welcome';
  static const String deviceAuthPath = '/device-auth';
  static const String homePath = '/home';
  static const String changelogPath = '/changelog';
  static const String adminDashboardPath = '/admin-dashboard';
  static const String serversPath = '/servers';
  static const String serverDetailsPath = '/servers/details';
  static const String configsPath = '/configs';
  static const String configEditorPath = '/configs/editor';
  static const String importConfigPath = '/configs/import';
  static const String connectionDetailsPath = '/connection/details';
  static const String statisticsPath = '/statistics';
  static const String historyPath = '/history';
  static const String plansPath = '/plans';
  static const String paymentHistoryPath = '/payments/history';
  static const String profilePath = '/profile';
  static const String devicesPath = '/devices';
  static const String appearancePath = '/settings/appearance';
  static const String languagePath = '/settings/language';
  static const String notificationsPath = '/notifications';
  static const String advancedNetworkPath = '/settings/advanced';
  static const String appSettingsPath = '/settings/app';
  static const String supportPath = '/support';
  static const String faqPath = '/support/faq';
  static const String aboutPath = '/about';

  static final GoRouter router = GoRouter(
    initialLocation: splashPath,
    routes: [
      GoRoute(
        path: splashPath,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: onboardingPath,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: welcomePath,
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: deviceAuthPath,
        name: 'deviceAuth',
        builder: (context, state) => const DeviceAuthPage(),
      ),
      GoRoute(
        path: homePath,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: changelogPath,
        name: 'changelog',
        builder: (context, state) => const ChangelogPage(),
      ),
      GoRoute(
        path: serversPath,
        name: 'servers',
        builder: (context, state) => const ServerListPage(),
      ),
      GoRoute(
        path: serverDetailsPath,
        name: 'serverDetails',
        builder: (context, state) {
          final server = state.extra as Map<String, dynamic>?;
          return ServerDetailsPage(serverData: server);
        },
      ),
      GoRoute(
        path: configsPath,
        name: 'configs',
        builder: (context, state) => const ConfigListPage(),
      ),
      GoRoute(
        path: configEditorPath,
        name: 'configEditor',
        builder: (context, state) => const ConfigEditorPage(),
      ),
      GoRoute(
        path: importConfigPath,
        name: 'importConfig',
        builder: (context, state) => const ImportConfigPage(),
      ),
      GoRoute(
        path: connectionDetailsPath,
        name: 'connectionDetails',
        builder: (context, state) => const ConnectionDetailsPage(),
      ),
      GoRoute(
        path: statisticsPath,
        name: 'statistics',
        builder: (context, state) => const StatisticsPage(),
      ),
      GoRoute(
        path: historyPath,
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: plansPath,
        name: 'plans',
        builder: (context, state) => const PlansPage(),
      ),
      GoRoute(
        path: paymentHistoryPath,
        name: 'paymentHistory',
        builder: (context, state) => const PaymentHistoryPage(),
      ),
      GoRoute(
        path: profilePath,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: devicesPath,
        name: 'devices',
        builder: (context, state) => const DevicesPage(),
      ),
      GoRoute(
        path: appearancePath,
        name: 'appearance',
        builder: (context, state) => const AppearancePage(),
      ),
      GoRoute(
        path: languagePath,
        name: 'language',
        builder: (context, state) => const LanguagePage(),
      ),
      GoRoute(
        path: notificationsPath,
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: advancedNetworkPath,
        name: 'advancedNetwork',
        builder: (context, state) => const AdvancedNetworkSettingsPage(),
      ),
      GoRoute(
        path: appSettingsPath,
        name: 'appSettings',
        builder: (context, state) => const AppSettingsPage(),
      ),
      GoRoute(
        path: supportPath,
        name: 'support',
        builder: (context, state) => const SupportCenterPage(),
      ),
      GoRoute(
        path: faqPath,
        name: 'faq',
        builder: (context, state) => const FaqPage(),
      ),
      GoRoute(
        path: aboutPath,
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: adminDashboardPath,
        name: 'adminDashboard',
        builder: (context, state) {
          final isAuth = state.extra is bool ? state.extra as bool : false;
          return AdminDashboardPage(initialAuthenticated: isAuth);
        },
      ),
    ],
  );
}
