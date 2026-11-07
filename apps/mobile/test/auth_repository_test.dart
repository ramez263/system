import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tunnel_plus/core/network/dio_client.dart';
import 'package:tunnel_plus/core/services/device_identity_service.dart';
import 'package:tunnel_plus/core/storage/hive_storage_service.dart';
import 'package:tunnel_plus/features/auth/data/repositories/auth_repository_impl.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDeviceIdentityService extends Mock implements DeviceIdentityService {}
class MockHiveStorageService extends Mock implements IHiveStorageService {}

void main() {
  late MockDioClient mockDioClient;
  late MockDeviceIdentityService mockDeviceService;
  late MockHiveStorageService mockHiveStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDeviceService = MockDeviceIdentityService();
    mockHiveStorage = MockHiveStorageService();

    repository = AuthRepositoryImpl(
      dioClient: mockDioClient,
      deviceIdentityService: mockDeviceService,
      hiveStorage: mockHiveStorage,
    );
  });

  group('AuthRepository Handshake Tests', () {
    test('Performs handshake with backend and caches profile in Hive', () async {
      when(() => mockDeviceService.getDeviceMetadata()).thenAnswer((_) async => {
            'device_uuid': 'test-uuid-999',
            'device_name': 'Pixel 8',
            'model': 'Pixel 8',
            'os_version': 'Android 14',
            'platform': 'android',
          });

      final apiResponse = {
        'status': 'success',
        'data': {
          'device_uuid': 'test-uuid-999',
          'device_name': 'Pixel 8',
          'is_active': true,
          'is_premium': false,
          'tier': 'free',
          'max_devices': 1,
          'bytes_uploaded': 1000,
          'bytes_downloaded': 2000,
        },
      };

      when(() => mockDioClient.post(
            '/api/v1/devices/handshake',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: apiResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/devices/handshake'),
          ));

      when(() => mockHiveStorage.put<String>(any(), any(), any())).thenAnswer((_) async {});

      final result = await repository.performHandshake();

      result.fold(
        (f) => fail('Failed with message: ${f.message}'),
        (profile) {
          expect(profile.deviceUuid, 'test-uuid-999');
          expect(profile.tier, 'free');
          expect(profile.isActive, true);
        },
      );

      verify(() => mockHiveStorage.put<String>(HiveStorageService.boxCache, 'cached_device_profile', any())).called(1);
    });

    test('Generates fallback guest profile when offline and no cache exists', () async {
      when(() => mockDeviceService.getDeviceMetadata()).thenAnswer((_) async => {
            'device_uuid': 'test-uuid-offline',
          });

      when(() => mockDioClient.post(
            '/api/v1/devices/handshake',
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/v1/devices/handshake'),
        type: DioExceptionType.connectionError,
      ));

      when(() => mockHiveStorage.get<String>(any(), any())).thenReturn(null);

      when(() => mockDeviceService.getOrCreateDeviceUuid())
          .thenAnswer((_) async => 'test-uuid-offline');

      final result = await repository.performHandshake();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (profile) {
          expect(profile.deviceUuid, 'test-uuid-offline');
          expect(profile.tier, 'free');
          expect(profile.deviceName, contains('Offline'));
        },
      );
    });
  });
}
