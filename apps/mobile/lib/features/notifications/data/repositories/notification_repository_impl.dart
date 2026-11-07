import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/hive_storage_service.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final DioClient _dioClient;
  final IHiveStorageService _hiveStorage;

  static const String _prefsKey = 'cached_notif_preferences';

  NotificationRepositoryImpl({
    required DioClient dioClient,
    required IHiveStorageService hiveStorage,
  })  : _dioClient = dioClient,
        _hiveStorage = hiveStorage;

  @override
  Future<Either<Failure, NotificationPreferences>> getPreferences() async {
    try {
      final response = await _dioClient.get('/api/v1/notifications/preferences');
      final data = response.data;

      if (data != null && data['status'] == 'success') {
        final prefs = NotificationPreferences.fromJson(data['data'] as Map<String, dynamic>);
        await _hiveStorage.put(HiveStorageService.boxSettings, _prefsKey, jsonEncode(prefs.toJson()));
        return Right(prefs);
      }

      return _loadFromCacheOrDefault();
    } on DioException catch (_) {
      return _loadFromCacheOrDefault();
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationPreferences>> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      await _hiveStorage.put(HiveStorageService.boxSettings, _prefsKey, jsonEncode(preferences.toJson()));

      await _dioClient.post(
        '/api/v1/notifications/preferences',
        data: preferences.toJson(),
      );

      return Right(preferences);
    } on DioException catch (_) {
      // Return cached local state even if offline
      return Right(preferences);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements() async {
    try {
      final response = await _dioClient.get('/api/v1/notifications/announcements');
      final data = response.data;

      if (data != null && data['status'] == 'success') {
        final list = (data['data'] as List)
            .map((e) => AnnouncementEntity.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(list);
      }

      return const Right([]);
    } catch (_) {
      return const Right([]);
    }
  }

  Either<Failure, NotificationPreferences> _loadFromCacheOrDefault() {
    final cached = _hiveStorage.get<String>(HiveStorageService.boxSettings, _prefsKey);
    if (cached != null) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        return Right(NotificationPreferences.fromJson(map));
      } catch (_) {}
    }
    return const Right(NotificationPreferences());
  }
}
