import 'package:get_it/get_it.dart';
import '../config/app_environment.dart';
import '../localization/locale_cubit.dart';
import '../network/dio_client.dart';
import '../services/app_remote_config_service.dart';
import '../services/connectivity_service.dart';
import '../services/device_identity_service.dart';
import '../storage/database/app_database.dart';
import '../storage/hive_storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../theme/theme_cubit.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/device_auth_cubit.dart';
import '../../features/servers/data/repositories/server_repository_impl.dart';
import '../../features/servers/domain/repositories/server_repository.dart';
import '../../features/servers/presentation/cubit/server_list_cubit.dart';
import '../../features/configurations/data/repositories/configuration_repository_impl.dart';
import '../../features/configurations/domain/repositories/configuration_repository.dart';
import '../../features/configurations/presentation/cubit/config_cubit.dart';
import '../../features/statistics/data/repositories/telemetry_repository_impl.dart';
import '../../features/statistics/domain/repositories/telemetry_repository.dart';
import '../../features/statistics/presentation/cubit/statistics_cubit.dart';
import '../vpn/vpn_service.dart';
import '../../features/vpn_connection/presentation/cubit/vpn_connection_cubit.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository.dart';
import '../../features/subscriptions/data/services/billing_service.dart';
import '../../features/subscriptions/presentation/cubit/subscription_cubit.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // 1. Storage: Secure Storage
  final secureStorage = SecureStorageService();
  sl.registerSingleton<ISecureStorageService>(secureStorage);

  // 2. Storage: Hive-CE Cache
  final hiveStorage = HiveStorageService();
  await hiveStorage.init();
  sl.registerSingleton<IHiveStorageService>(hiveStorage);

  // 3. Storage: Drift SQLite Database
  final appDatabase = AppDatabase();
  sl.registerSingleton<AppDatabase>(appDatabase);

  // 4. Core Service: Device Identity (device_uuid)
  final deviceIdentityService = DeviceIdentityService(
    secureStorage: sl<ISecureStorageService>(),
  );
  sl.registerSingleton<DeviceIdentityService>(deviceIdentityService);

  // 5. Network: Dio Client
  final dioClient = DioClient(
    config: AppConfig.instance,
    deviceIdentityService: sl<DeviceIdentityService>(),
  );
  sl.registerSingleton<DioClient>(dioClient);

  // 6. Network: Connectivity & Remote Config Services
  final connectivityService = ConnectivityService();
  sl.registerSingleton<ConnectivityService>(connectivityService);

  final remoteConfigService = AppRemoteConfigService(
    dioClient: sl<DioClient>(),
    hiveStorage: sl<IHiveStorageService>(),
  );
  sl.registerSingleton<AppRemoteConfigService>(remoteConfigService);

  // 7. Repositories
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(
    dioClient: sl<DioClient>(),
    deviceIdentityService: sl<DeviceIdentityService>(),
    hiveStorage: sl<IHiveStorageService>(),
  ));

  sl.registerLazySingleton<IServerRepository>(() => ServerRepositoryImpl(
    dioClient: sl<DioClient>(),
    hiveStorage: sl<IHiveStorageService>(),
  ));

  sl.registerLazySingleton<IConfigurationRepository>(() => ConfigurationRepositoryImpl(
    database: sl<AppDatabase>(),
    dioClient: sl<DioClient>(),
    deviceIdentityService: sl<DeviceIdentityService>(),
  ));

  sl.registerLazySingleton<ITelemetryRepository>(() => TelemetryRepositoryImpl(
    database: sl<AppDatabase>(),
    dioClient: sl<DioClient>(),
  ));

  sl.registerLazySingleton<BillingService>(() => BillingService());

  sl.registerLazySingleton<ISubscriptionRepository>(() => SubscriptionRepositoryImpl(
    dioClient: sl<DioClient>(),
    hiveStorage: sl<IHiveStorageService>(),
  ));

  sl.registerLazySingleton<INotificationRepository>(() => NotificationRepositoryImpl(
    dioClient: sl<DioClient>(),
    hiveStorage: sl<IHiveStorageService>(),
  ));

  sl.registerLazySingleton<ISettingsRepository>(() => SettingsRepositoryImpl(
    hiveStorage: sl<IHiveStorageService>(),
  ));

  // 8. Native VPN Service
  sl.registerLazySingleton<IVpnService>(() => VpnService());

  // 9. State Cubits
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl<IHiveStorageService>()));
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<IHiveStorageService>()));
  sl.registerFactory<DeviceAuthCubit>(() => DeviceAuthCubit(sl<IAuthRepository>()));
  sl.registerLazySingleton<ServerListCubit>(() => ServerListCubit(sl<IServerRepository>()));
  sl.registerLazySingleton<ConfigCubit>(() => ConfigCubit(sl<IConfigurationRepository>()));
  sl.registerFactory<StatisticsCubit>(() => StatisticsCubit(sl<ITelemetryRepository>()));
  sl.registerLazySingleton<SubscriptionCubit>(() => SubscriptionCubit(
    repository: sl<ISubscriptionRepository>(),
    billingService: sl<BillingService>(),
  ));
  sl.registerLazySingleton<NotificationCubit>(() => NotificationCubit(
    repository: sl<INotificationRepository>(),
  ));
  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit(
    repository: sl<ISettingsRepository>(),
  ));
  sl.registerLazySingleton<VpnConnectionCubit>(() => VpnConnectionCubit(
    vpnService: sl<IVpnService>(),
    serverRepository: sl<IServerRepository>(),
    telemetryRepository: sl<ITelemetryRepository>(),
    settingsRepository: sl<ISettingsRepository>(),
  ));
}
