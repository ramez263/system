import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/app_environment.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.initialize(
    flavor: AppFlavor.dev,
    appName: 'Ramez Tunnel [DEV]',
    apiBaseUrl: 'http://10.0.2.2:8000/api/v1',
    wsBaseUrl: 'ws://10.0.2.2:8080',
    enableLogging: true,
  );

  await configureDependencies();

  runApp(const RamezTunnelApp());
}
