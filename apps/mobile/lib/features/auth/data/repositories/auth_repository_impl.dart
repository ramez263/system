import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../../../core/storage/hive_storage_service.dart';
import '../../domain/entities/device_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/device_profile_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final DioClient _dioClient;
  final DeviceIdentityService _deviceIdentityService;
  final IHiveStorageService _hiveStorage;

  static const String _cacheKey = 'cached_device_profile';

  AuthRepositoryImpl({
    required DioClient dioClient,
    required DeviceIdentityService deviceIdentityService,
    required IHiveStorageService hiveStorage,
  })  : _dioClient = dioClient,
        _deviceIdentityService = deviceIdentityService,
        _hiveStorage = hiveStorage;

  @override
  Future<Either<Failure, DeviceProfile>> performHandshake() async {
    try {
      final metadata = await _deviceIdentityService.getDeviceMetadata();

      final response = await _dioClient.post(
        '/api/v1/devices/handshake',
        data: metadata,
      );

      final data = response.data;
      if (data != null && data['status'] == 'success') {
        final profileModel = DeviceProfileModel.fromJson(data['data'] as Map<String, dynamic>);
        await _hiveStorage.put(HiveStorageService.boxCache, _cacheKey, jsonEncode(profileModel.toJson()));
        return Right(profileModel);
      }

      return const Left(ServerFailure('Invalid handshake response from control plane.'));
    } on DioException catch (_) {
      // Offline fallback: load cached profile
      final cachedJson = _hiveStorage.get<String>(HiveStorageService.boxCache, _cacheKey);
      if (cachedJson != null) {
        try {
          final cachedProfile = DeviceProfileModel.fromJson(jsonDecode(cachedJson));
          return Right(cachedProfile);
        } catch (_) {}
      }

      // Generate local guest fallback profile
      final uuid = await _deviceIdentityService.getOrCreateDeviceUuid();
      final fallbackProfile = DeviceProfile(
        deviceUuid: uuid,
        deviceName: 'Android Device (Offline)',
        isActive: true,
        isPremium: false,
        tier: 'free',
      );
      return Right(fallbackProfile);
    } catch (e) {
      return Left(ServerFailure('Handshake failed: $e'));
    }
  }

  @override
  Future<Either<Failure, DeviceProfile>> getDeviceProfile() async {
    try {
      final response = await _dioClient.get('/api/v1/devices/me');
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        final profileModel = DeviceProfileModel.fromJson(data['data'] as Map<String, dynamic>);
        await _hiveStorage.put(HiveStorageService.boxCache, _cacheKey, jsonEncode(profileModel.toJson()));
        return Right(profileModel);
      }

      return const Left(ServerFailure('Failed to fetch device profile.'));
    } on DioException catch (_) {
      final cachedJson = _hiveStorage.get<String>(HiveStorageService.boxCache, _cacheKey);
      if (cachedJson != null) {
        final cachedProfile = DeviceProfileModel.fromJson(jsonDecode(cachedJson));
        return Right(cachedProfile);
      }
      return const Left(NetworkFailure('Device is offline and no cached profile is available.'));
    } catch (e) {
      return Left(ServerFailure('Error fetching device profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePushToken(String token) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/devices/push-token',
        data: {'push_token': token},
      );
      if (response.data != null && response.data['status'] == 'success') {
        return const Right(null);
      }
      return const Left(ServerFailure('Failed to update push token.'));
    } catch (e) {
      return Left(ServerFailure('Error updating push token: $e'));
    }
  }
}
