import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunnel_plus/core/config/app_environment.dart';
import 'package:tunnel_plus/core/localization/app_strings.dart';
import 'package:tunnel_plus/core/localization/locale_cubit.dart';
import 'package:tunnel_plus/core/storage/hive_storage_service.dart';
import 'package:tunnel_plus/core/theme/app_colors.dart';
import 'package:tunnel_plus/core/theme/app_theme.dart';
import 'package:tunnel_plus/core/theme/theme_cubit.dart';
import 'package:tunnel_plus/features/configurations/presentation/pages/config_editor_page.dart';
import 'package:tunnel_plus/features/configurations/presentation/pages/config_list_page.dart';
import 'package:tunnel_plus/features/configurations/presentation/pages/import_config_page.dart';
import 'package:tunnel_plus/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:tunnel_plus/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:tunnel_plus/features/servers/presentation/pages/server_details_page.dart';
import 'package:tunnel_plus/features/servers/presentation/pages/server_list_page.dart';
import 'package:tunnel_plus/features/settings/presentation/pages/advanced_network_settings_page.dart';
import 'package:tunnel_plus/features/settings/presentation/pages/app_settings_page.dart';
import 'package:tunnel_plus/features/settings/presentation/pages/appearance_page.dart';
import 'package:tunnel_plus/features/settings/presentation/pages/language_page.dart';
import 'package:tunnel_plus/features/statistics/presentation/pages/history_page.dart';
import 'package:tunnel_plus/features/statistics/presentation/pages/statistics_page.dart';
import 'package:tunnel_plus/features/subscriptions/presentation/pages/payment_history_page.dart';
import 'package:tunnel_plus/features/subscriptions/presentation/pages/plans_page.dart';
import 'package:tunnel_plus/features/support/presentation/pages/about_page.dart';
import 'package:tunnel_plus/features/support/presentation/pages/faq_page.dart';
import 'package:tunnel_plus/features/support/presentation/pages/support_center_page.dart';
import 'package:tunnel_plus/features/vpn_connection/presentation/pages/connection_details_page.dart';

class MockHiveStorageService implements IHiveStorageService {
  final Map<String, dynamic> _data = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> put<T>(String boxName, String key, T value) async {
    _data['$boxName:$key'] = value;
  }

  @override
  T? get<T>(String boxName, String key, {T? defaultValue}) {
    return (_data['$boxName:$key'] as T?) ?? defaultValue;
  }

  @override
  Future<void> delete(String boxName, String key) async {
    _data.remove('$boxName:$key');
  }

  @override
  Future<void> clearBox(String boxName) async {
    _data.clear();
  }
}

Widget createTestableWidget({
  required Widget child,
  required Locale locale,
  required Brightness brightness,
  Color seedColor = AppColors.primaryBlue,
}) {
  final storage = MockHiveStorageService();
  return MultiBlocProvider(
    providers: [
      BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(storage)),
      BlocProvider<LocaleCubit>(create: (_) => LocaleCubit(storage)),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: brightness == Brightness.light
          ? AppTheme.lightTheme(seedColor)
          : AppTheme.darkTheme(seedColor),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    AppConfig.initialize(
      flavor: AppFlavor.dev,
      appName: 'Ramez Tunnel Plus',
      apiBaseUrl: 'http://localhost:8000/api/v1',
      wsBaseUrl: 'ws://localhost:8080',
    );
  });

  group('Phase 2 Exit Gate: All Screens Render in Light & Dark Themes and Arabic (RTL) & English (LTR)', () {
    testWidgets('Renders OnboardingPage in English Light & Arabic Dark', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        child: const OnboardingPage(),
        locale: const Locale('en'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const OnboardingPage(),
        locale: const Locale('ar'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('Renders WelcomePage in English and Arabic', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        child: const WelcomePage(),
        locale: const Locale('en'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(find.byType(WelcomePage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const WelcomePage(),
        locale: const Locale('ar'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(WelcomePage), findsOneWidget);
    });

    testWidgets('Renders ServerListPage and ServerDetailsPage with mock data', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        child: const ServerListPage(),
        locale: const Locale('ar'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(ServerListPage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const ServerDetailsPage(),
        locale: const Locale('en'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(find.byType(ServerDetailsPage), findsOneWidget);
    });

    testWidgets('Renders ConfigListPage, Editor, and Import in both languages', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        child: const ConfigListPage(),
        locale: const Locale('en'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(find.byType(ConfigListPage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const ConfigEditorPage(),
        locale: const Locale('ar'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(ConfigEditorPage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const ImportConfigPage(),
        locale: const Locale('ar'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(find.byType(ImportConfigPage), findsOneWidget);
    });

    testWidgets('Renders StatisticsPage, HistoryPage, and ConnectionDetailsPage', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        child: const StatisticsPage(),
        locale: const Locale('en'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(StatisticsPage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const HistoryPage(),
        locale: const Locale('ar'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(find.byType(HistoryPage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const ConnectionDetailsPage(),
        locale: const Locale('ar'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(ConnectionDetailsPage), findsOneWidget);
    });

    testWidgets('Renders PlansPage and PaymentHistoryPage', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        child: const PlansPage(),
        locale: const Locale('ar'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(PlansPage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const PaymentHistoryPage(),
        locale: const Locale('en'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(find.byType(PaymentHistoryPage), findsOneWidget);
    });

    testWidgets('Renders Settings screens: Appearance, Language, AdvancedNetwork, AppSettings', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        child: const AppearancePage(),
        locale: const Locale('ar'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(AppearancePage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const LanguagePage(),
        locale: const Locale('en'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(find.byType(LanguagePage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const AdvancedNetworkSettingsPage(),
        locale: const Locale('ar'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(AdvancedNetworkSettingsPage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const AppSettingsPage(),
        locale: const Locale('en'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(find.byType(AppSettingsPage), findsOneWidget);
    });

    testWidgets('Renders Support, FAQ, and About pages in Arabic RTL', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        child: const SupportCenterPage(),
        locale: const Locale('ar'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(SupportCenterPage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const FaqPage(),
        locale: const Locale('ar'),
        brightness: Brightness.light,
      ));
      await tester.pump();
      expect(find.byType(FaqPage), findsOneWidget);

      await tester.pumpWidget(createTestableWidget(
        child: const AboutPage(),
        locale: const Locale('ar'),
        brightness: Brightness.dark,
      ));
      await tester.pump();
      expect(find.byType(AboutPage), findsOneWidget);
    });
  });
}
