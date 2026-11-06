import 'package:get_it/get_it.dart';
import '../config/app_environment.dart';
import '../network/dio_client.dart';
import '../services/device_identity_service.dart';
import '../storage/database/app_database.dart';
import '../storage/hive_storage_service.dart';
import '../storage/secure_storage_service.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Storage: Secure Storage
  final secureStorage = SecureStorageService();
  sl.registerSingleton<ISecureStorageService>(secureStorage);

  // Storage: Hive-CE Cache
  final hiveStorage = HiveStorageService();
  await hiveStorage.init();
  sl.registerSingleton<IHiveStorageService>(hiveStorage);

  // Storage: Drift SQLite Database
  final appDatabase = AppDatabase();
  sl.registerSingleton<AppDatabase>(appDatabase);

  // Core Service: Device Identity (device_uuid)
  final deviceIdentityService = DeviceIdentityService(
    secureStorage: sl<ISecureStorageService>(),
  );
  sl.registerSingleton<DeviceIdentityService>(deviceIdentityService);

  // Network: Dio Client
  final dioClient = DioClient(
    config: AppConfig.instance,
    deviceIdentityService: sl<DeviceIdentityService>(),
  );
  sl.registerSingleton<DioClient>(dioClient);
}
