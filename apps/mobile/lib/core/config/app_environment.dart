enum AppFlavor {
  dev,
  stage,
  prod,
}

class AppConfig {
  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final bool enableLogging;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    this.enableLogging = true,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
  });

  static late final AppConfig instance;

  static void initialize({
    required AppFlavor flavor,
    required String appName,
    required String apiBaseUrl,
    required String wsBaseUrl,
    bool enableLogging = true,
  }) {
    instance = AppConfig(
      flavor: flavor,
      appName: appName,
      apiBaseUrl: apiBaseUrl,
      wsBaseUrl: wsBaseUrl,
      enableLogging: enableLogging,
    );
  }

  bool get isDevelopment => flavor == AppFlavor.dev;
  bool get isStaging => flavor == AppFlavor.stage;
  bool get isProduction => flavor == AppFlavor.prod;
}
