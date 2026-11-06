import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunnel_plus/core/config/app_environment.dart';
import 'package:tunnel_plus/core/network/interceptors/logging_redaction_interceptor.dart';
import 'package:tunnel_plus/core/services/device_identity_service.dart';
import 'package:tunnel_plus/core/storage/database/app_database.dart';
import 'package:tunnel_plus/core/storage/secure_storage_service.dart';

class MockSecureStorageService implements ISecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _data[key];
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _data.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfig & Flavors Tests', () {
    test('Initializes development environment correctly', () {
      AppConfig.initialize(
        flavor: AppFlavor.dev,
        appName: 'Ramez Tunnel [DEV]',
        apiBaseUrl: 'http://10.0.2.2:8000/api/v1',
        wsBaseUrl: 'ws://10.0.2.2:8080',
        enableLogging: true,
      );

      expect(AppConfig.instance.isDevelopment, isTrue);
      expect(AppConfig.instance.isProduction, isFalse);
      expect(AppConfig.instance.apiBaseUrl, equals('http://10.0.2.2:8000/api/v1'));
    });
  });

  group('DeviceIdentityService Tests', () {
    test('Generates and persists unique device UUID on first launch', () async {
      final mockStorage = MockSecureStorageService();
      final service = DeviceIdentityService(secureStorage: mockStorage);

      final uuid1 = await service.getOrCreateDeviceUuid();
      expect(uuid1, isNotEmpty);
      expect(uuid1.length, equals(36)); // Standard v4 UUID length

      // Reading again should return the exact same cached/persisted UUID
      final uuid2 = await service.getOrCreateDeviceUuid();
      expect(uuid2, equals(uuid1));
    });
  });

  group('LoggingRedactionInterceptor Tests', () {
    test('Redacts IP addresses, UUIDs, and credentials from log strings', () {
      const rawString =
          'User with uuid 7a30c51b-e5fb-4c7b-bc43-2fd3f8a0028e connected to 198.51.100.42 with password: secret_vpn_password';
      final redacted = LoggingRedactionInterceptor.redact(rawString);

      expect(redacted.contains('7a30c51b-e5fb-4c7b-bc43-2fd3f8a0028e'), isFalse);
      expect(redacted.contains('198.51.100.42'), isFalse);
      expect(redacted.contains('secret_vpn_password'), isFalse);
      expect(redacted.contains('[REDACTED_UUID]'), isTrue);
      expect(redacted.contains('[REDACTED_IP]'), isTrue);
      expect(redacted.contains('[REDACTED_SECRET]'), isTrue);
    });
  });

  group('Drift In-Memory Database Tests', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('Inserts and retrieves tunnel configuration successfully', () async {
      final id = await database.into(database.tunnelConfigs).insert(
            TunnelConfigsCompanion.insert(
              name: 'Frankfurt OpenVPN',
              protocol: 'ovpn',
              serverAddress: 'de-fra.nodes.rameztunnel.com',
              serverPort: 1194,
              rawConfig: 'client\ndev tun\nproto udp',
            ),
          );

      expect(id, isPositive);

      final configs = await database.select(database.tunnelConfigs).get();
      expect(configs.length, equals(1));
      expect(configs.first.name, equals('Frankfurt OpenVPN'));
      expect(configs.first.protocol, equals('ovpn'));
    });
  });
}
