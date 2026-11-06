import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/app_environment.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.initialize(
    flavor: AppFlavor.stage,
    appName: 'Ramez Tunnel [STAGE]',
    apiBaseUrl: 'https://staging-api.rameztunnel.com/api/v1',
    wsBaseUrl: 'wss://staging-ws.rameztunnel.com',
    enableLogging: true,
  );

  await configureDependencies();

  runApp(const RamezTunnelApp());
}
