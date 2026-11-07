import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tunnel_plus/core/network/dio_client.dart';
import 'package:tunnel_plus/core/storage/hive_storage_service.dart';
import 'package:tunnel_plus/features/servers/data/repositories/server_repository_impl.dart';

class MockDioClient extends Mock implements DioClient {}
class MockHiveStorageService extends Mock implements IHiveStorageService {}

void main() {
  late MockDioClient mockDioClient;
  late MockHiveStorageService mockHiveStorage;
  late ServerRepositoryImpl repository;

  setUp(() {
    mockDioClient = MockDioClient();
    mockHiveStorage = MockHiveStorageService();
    repository = ServerRepositoryImpl(
      dioClient: mockDioClient,
      hiveStorage: mockHiveStorage,
    );
  });

  group('ServerRepository Tests', () {
    final sampleApiResponse = {
      'status': 'success',
      'data': [
        {
          'id': 1,
          'name': 'Frankfurt Node',
          'country_code': 'DE',
          'country_name': 'Germany',
          'city': 'Frankfurt',
          'flag_emoji': '🇩🇪',
          'protocol': 'ovpn',
          'ip_address': '185.120.40.12',
          'port': 1194,
          'ping_ms': 25,
          'current_load': 15,
          'is_premium': false,
          'has_ovpn': true,
        },
      ],
      'meta': {'count': 1},
    };

    test('Fetches servers from control plane and caches in Hive', () async {
      when(() => mockDioClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: sampleApiResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/servers'),
          ));

      when(() => mockHiveStorage.put<String>(any(), any(), any())).thenAnswer((_) async {});

      final result = await repository.getServers();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (servers) {
          expect(servers.length, 1);
          expect(servers.first.name, 'Frankfurt Node');
          expect(servers.first.countryCode, 'DE');
        },
      );

      verify(() => mockHiveStorage.put<String>(HiveStorageService.boxCache, 'cached_servers_list', any())).called(1);
    });

    test('Falls back to Hive cache when network is offline', () async {
      when(() => mockDioClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/v1/servers'),
        type: DioExceptionType.connectionError,
      ));

      const cachedJson = '''[
        {
          "id": 2,
          "name": "Cached Amsterdam Node",
          "country_code": "NL",
          "country_name": "Netherlands",
          "flag_emoji": "🇳🇱",
          "protocol": "ovpn",
          "ip_address": "1.2.3.4",
          "port": 1194,
          "ping_ms": 30,
          "current_load": 20,
          "is_premium": false,
          "has_ovpn": true
        }
      ]''';

      when(() => mockHiveStorage.get<String>(any(), any())).thenReturn(cachedJson);

      final result = await repository.getServers();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected cached fallback'),
        (servers) {
          expect(servers.length, 1);
          expect(servers.first.name, 'Cached Amsterdam Node');
          expect(servers.first.countryCode, 'NL');
        },
      );
    });

    test('Downloads raw OpenVPN configuration string', () async {
      const ovpnText = 'client\ndev tun\nremote 1.1.1.1 1194';

      when(() => mockDioClient.get(
            '/api/v1/servers/1/ovpn',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: ovpnText,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/servers/1/ovpn'),
          ));

      final result = await repository.downloadOvpnConfig(1);

      expect(result.isRight(), true);
      expect(result.getOrElse((_) => ''), ovpnText);
    });
  });
}
