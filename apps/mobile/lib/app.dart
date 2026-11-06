import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/app_environment.dart';
import 'core/di/injection.dart';
import 'core/localization/app_strings.dart';
import 'core/localization/locale_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

class RamezTunnelApp extends StatelessWidget {
  const RamezTunnelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: sl<ThemeCubit>()),
        BlocProvider<LocaleCubit>.value(value: sl<LocaleCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp.router(
                title: AppConfig.instance.appName,
                debugShowCheckedModeBanner: !AppConfig.instance.isProduction,
                routerConfig: AppRouter.router,
                locale: locale,
                supportedLocales: const [
                  Locale('en'),
                  Locale('ar'),
                ],
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.lightTheme(themeState.activeSeedColor),
                darkTheme: AppTheme.darkTheme(themeState.activeSeedColor),
                themeMode: themeState.mode,
              );
            },
          );
        },
      ),
    );
  }
}
