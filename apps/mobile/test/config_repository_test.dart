import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tunnel_plus/core/network/dio_client.dart';
import 'package:tunnel_plus/core/services/device_identity_service.dart';
import 'package:tunnel_plus/core/storage/database/app_database.dart';
import 'package:tunnel_plus/features/configurations/data/repositories/configuration_repository_impl.dart';
import 'package:tunnel_plus/features/configurations/domain/entities/configuration_entity.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDeviceIdentityService extends Mock implements DeviceIdentityService {}

void main() {
  late AppDatabase database;
  late MockDioClient mockDioClient;
  late MockDeviceIdentityService mockDeviceService;
  late ConfigurationRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    mockDioClient = MockDioClient();
    mockDeviceService = MockDeviceIdentityService();

    when(() => mockDeviceService.getOrCreateDeviceUuid())
        .thenAnswer((_) async => 'test-device-uuid');

    repository = ConfigurationRepositoryImpl(
      database: database,
      dioClient: mockDioClient,
      deviceIdentityService: mockDeviceService,
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('ConfigurationRepository Drift Tests', () {
    test('Inserts and retrieves configuration in Drift SQLite', () async {
      final config = ConfigurationEntity(
        name: 'Fast Gaming UDP',
        description: 'Optimized MTU',
        protocol: 'ovpn',
        serverAddress: '185.120.40.12',
        serverPort: 1194,
        rawConfig: 'client\ndev tun\nremote 185.120.40.12 1194',
        createdAt: DateTime.now(),
      );

      final saveResult = await repository.saveConfiguration(config);
      expect(saveResult.isRight(), true);

      final listResult = await repository.getLocalConfigurations();
      expect(listResult.isRight(), true);

      final list = listResult.getOrElse((_) => []);
      expect(list.length, 1);
      expect(list.first.name, 'Fast Gaming UDP');
      expect(list.first.serverPort, 1194);
    });

    test('Deletes configuration from SQLite', () async {
      final config = ConfigurationEntity(
        name: 'Temporary Config',
        protocol: 'ovpn',
        serverAddress: '1.2.3.4',
        serverPort: 443,
        rawConfig: 'client\ndev tun',
        createdAt: DateTime.now(),
      );

      final saved = (await repository.saveConfiguration(config)).getOrElse((_) => throw Exception());
      expect(saved.id, isNotNull);

      final deleteResult = await repository.deleteConfiguration(saved.id!);
      expect(deleteResult.isRight(), true);

      final list = (await repository.getLocalConfigurations()).getOrElse((_) => []);
      expect(list.isEmpty, true);
    });

    test('Imports raw OpenVPN string and persists to SQLite', () async {
      const ovpn = '''
client
dev tun
proto udp
remote 10.0.0.1 1194
resolv-retry infinite
nobind
verb 3
''';

      final result = await repository.importFromRawString(ovpn, name: 'Imported Profile');
      expect(result.isRight(), true);

      final list = (await repository.getLocalConfigurations()).getOrElse((_) => []);
      expect(list.length, 1);
      expect(list.first.name, 'Imported Profile');
      expect(list.first.serverAddress, '10.0.0.1');
    });
  });
}
