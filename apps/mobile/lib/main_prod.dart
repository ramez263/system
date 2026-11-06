import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/app_environment.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.initialize(
    flavor: AppFlavor.prod,
    appName: 'Ramez Tunnel Plus',
    apiBaseUrl: 'https://api.rameztunnel.com/api/v1',
    wsBaseUrl: 'wss://ws.rameztunnel.com',
    enableLogging: false,
  );

  await configureDependencies();

  runApp(const RamezTunnelApp());
}
