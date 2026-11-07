import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../../../core/services/rtp_config_engine.dart';
import '../../../../core/storage/database/app_database.dart';
import '../../domain/entities/configuration_entity.dart';
import '../../domain/repositories/configuration_repository.dart';
import '../models/configuration_model.dart';

class ConfigurationRepositoryImpl implements IConfigurationRepository {
  final AppDatabase _database;
  final DioClient _dioClient;
  final DeviceIdentityService _deviceIdentityService;

  ConfigurationRepositoryImpl({
    required AppDatabase database,
    required DioClient dioClient,
    required DeviceIdentityService deviceIdentityService,
  })  : _database = database,
        _dioClient = dioClient,
        _deviceIdentityService = deviceIdentityService;

  @override
  Future<Either<Failure, List<ConfigurationEntity>>> getLocalConfigurations() async {
    try {
      final rows = await _database.select(_database.tunnelConfigs).get();
      final entities = rows.map((row) {
        return ConfigurationEntity(
          id: row.id,
          name: row.name,
          protocol: row.protocol,
          serverAddress: row.serverAddress,
          serverPort: row.serverPort,
          rawConfig: row.rawConfig,
          isFavorite: row.isFavorite,
          isLocked: row.isLocked,
          createdAt: row.createdAt,
        );
      }).toList();

      return Right(entities);
    } catch (e) {
      return Left(StorageFailure('Failed to load local configurations: $e'));
    }
  }

  @override
  Future<Either<Failure, ConfigurationEntity>> saveConfiguration(ConfigurationEntity config) async {
    try {
      if (config.id == null) {
        // Insert new
        final companion = TunnelConfigsCompanion.insert(
          name: config.name,
          protocol: config.protocol,
          serverAddress: config.serverAddress,
          serverPort: config.serverPort,
          rawConfig: config.rawConfig,
          isFavorite: Value(config.isFavorite),
          isLocked: Value(config.isLocked),
          createdAt: Value(config.createdAt),
        );
        final id = await _database.into(_database.tunnelConfigs).insert(companion);
        return Right(config.copyWith(id: id));
      } else {
        // Update existing
        final companion = TunnelConfigsCompanion(
          id: Value(config.id!),
          name: Value(config.name),
          protocol: Value(config.protocol),
          serverAddress: Value(config.serverAddress),
          serverPort: Value(config.serverPort),
          rawConfig: Value(config.rawConfig),
          isFavorite: Value(config.isFavorite),
          isLocked: Value(config.isLocked),
        );
        await (_database.update(_database.tunnelConfigs)
              ..where((tbl) => tbl.id.equals(config.id!)))
            .write(companion);
        return Right(config);
      }
    } catch (e) {
      return Left(StorageFailure('Failed to save configuration: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConfiguration(int id) async {
    try {
      await (_database.delete(_database.tunnelConfigs)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to delete configuration: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ConfigurationEntity>>> getCommunityConfigurations({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dioClient.get(
        '/api/v1/configs',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data != null && data['status'] == 'success') {
        final list = (data['data'] as List)
            .map((e) => ConfigurationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(list);
      }

      return const Left(ServerFailure('Invalid community configurations response.'));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch community configurations: $e'));
    }
  }

  @override
  Future<Either<Failure, ConfigurationEntity>> importByShareCode(String shareCode) async {
    try {
      final code = shareCode.trim().toUpperCase();
      final response = await _dioClient.get('/api/v1/configs/share/$code');

      final data = response.data;
      if (data != null && data['status'] == 'success') {
        final model = ConfigurationModel.fromJson(data['data'] as Map<String, dynamic>);

        // Validate and parse raw payload
        final uuid = await _deviceIdentityService.getOrCreateDeviceUuid();
        final profile = RtpConfigEngine.parseAny(
          model.rawConfig,
          currentDeviceUuid: uuid,
          defaultName: model.name,
        );

        final entity = ConfigurationEntity(
          name: profile.name,
          description: profile.description,
          protocol: profile.protocol,
          serverAddress: profile.serverAddress,
          serverPort: profile.serverPort,
          rawConfig: profile.rawPayload,
          isLocked: profile.exportLocked,
          shareCode: model.shareCode,
          createdAt: DateTime.now(),
        );

        // Persist to local database
        return await saveConfiguration(entity);
      }

      return const Left(ServerFailure('Configuration code not found.'));
    } catch (e) {
      return Left(ServerFailure('Import failed: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> shareConfiguration(ConfigurationEntity config) async {
    try {
      final payload = {
        'name': config.name,
        'description': config.description,
        'protocol': config.protocol,
        'config_data': config.rawConfig,
        'is_public': true,
        'export_locked': config.isLocked,
      };

      final response = await _dioClient.post(
        '/api/v1/configs',
        data: payload,
      );

      final data = response.data;
      if (data != null && data['status'] == 'success') {
        final shareCode = data['data']['share_code'] as String;
        return Right(shareCode);
      }

      return const Left(ServerFailure('Failed to publish configuration.'));
    } catch (e) {
      return Left(ServerFailure('Failed to share configuration: $e'));
    }
  }

  @override
  Future<Either<Failure, ConfigurationEntity>> importFromRawString(String rawData, {String? name}) async {
    try {
      final uuid = await _deviceIdentityService.getOrCreateDeviceUuid();
      final profile = RtpConfigEngine.parseAny(
        rawData,
        currentDeviceUuid: uuid,
        defaultName: name,
      );

      final entity = ConfigurationEntity(
        name: profile.name,
        description: profile.description,
        protocol: profile.protocol,
        serverAddress: profile.serverAddress,
        serverPort: profile.serverPort,
        rawConfig: profile.rawPayload,
        isLocked: profile.exportLocked,
        createdAt: DateTime.now(),
      );

      return await saveConfiguration(entity);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ConfigParsingFailure('Failed to parse configuration: $e'));
    }
  }
}
