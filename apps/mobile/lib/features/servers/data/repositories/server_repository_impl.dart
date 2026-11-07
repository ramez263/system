import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/hive_storage_service.dart';
import '../../domain/entities/server_entity.dart';
import '../../domain/repositories/server_repository.dart';
import '../models/server_model.dart';

class ServerRepositoryImpl implements IServerRepository {
  final DioClient _dioClient;
  final IHiveStorageService _hiveStorage;

  static const String _serversCacheKey = 'cached_servers_list';

  ServerRepositoryImpl({
    required DioClient dioClient,
    required IHiveStorageService hiveStorage,
  })  : _dioClient = dioClient,
        _hiveStorage = hiveStorage;

  @override
  Future<Either<Failure, List<ServerEntity>>> getServers({
    String? country,
    String? protocol,
    bool? isPremium,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (country != null) queryParams['country'] = country;
      if (protocol != null) queryParams['protocol'] = protocol;
      if (isPremium != null) queryParams['is_premium'] = isPremium;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dioClient.get(
        '/api/v1/servers',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data != null && data['status'] == 'success') {
        final list = (data['data'] as List)
            .map((e) => ServerModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Cache unfiltered list in Hive for offline resilience
        if (queryParams.isEmpty) {
          final serialized = jsonEncode(list.map((s) => s.toJson()).toList());
          await _hiveStorage.put(HiveStorageService.boxCache, _serversCacheKey, serialized);
        }

        return Right(list);
      }

      return const Left(ServerFailure('Invalid response while fetching servers.'));
    } on DioException catch (_) {
      // Offline fallback: load cached servers
      final cachedJson = _hiveStorage.get<String>(HiveStorageService.boxCache, _serversCacheKey);
      if (cachedJson != null) {
        try {
          final decoded = jsonDecode(cachedJson) as List;
          final cachedList = decoded.map((e) => ServerModel.fromJson(e)).toList();

          // Apply local filters if needed
          var filtered = cachedList;
          if (country != null) {
            filtered = filtered.where((s) => s.countryCode.toUpperCase() == country.toUpperCase()).toList();
          }
          if (isPremium != null) {
            filtered = filtered.where((s) => s.isPremium == isPremium).toList();
          }
          if (search != null && search.isNotEmpty) {
            final term = search.toLowerCase();
            filtered = filtered.where((s) =>
                s.name.toLowerCase().contains(term) ||
                s.countryName.toLowerCase().contains(term)).toList();
          }

          return Right(filtered);
        } catch (_) {}
      }

      // Hardcoded fallback list if no cache is present
      return Right(_fallbackCuratedServers());
    } catch (e) {
      return Left(ServerFailure('Error fetching servers: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadOvpnConfig(int serverId) async {
    try {
      final response = await _dioClient.get(
        '/api/v1/servers/$serverId/ovpn',
        options: Options(responseType: ResponseType.plain),
      );

      if (response.data != null && response.data.toString().isNotEmpty) {
        return Right(response.data.toString());
      }

      return const Left(ServerFailure('OpenVPN configuration is empty.'));
    } on DioException catch (dioErr) {
      return Left(NetworkFailure('Network error downloading OpenVPN config: ${dioErr.message}'));
    } catch (e) {
      return Left(ServerFailure('Error downloading OpenVPN config: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCountries() async {
    try {
      final response = await _dioClient.get('/api/v1/servers/countries');
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        final list = List<Map<String, dynamic>>.from(data['data'] as List);
        return Right(list);
      }
      return const Left(ServerFailure('Failed to fetch country list.'));
    } catch (e) {
      return Left(ServerFailure('Error fetching countries: $e'));
    }
  }

  List<ServerEntity> _fallbackCuratedServers() {
    return const [
      ServerEntity(
        id: 1,
        name: 'Frankfurt Fast OpenVPN 01',
        countryCode: 'DE',
        countryName: 'Germany',
        city: 'Frankfurt',
        flagEmoji: '🇩🇪',
        protocol: 'ovpn',
        ipAddress: '185.120.40.12',
        port: 1194,
        pingMs: 28,
        currentLoad: 22,
        isPremium: false,
      ),
      ServerEntity(
        id: 2,
        name: 'Amsterdam Ultra OpenVPN 01',
        countryCode: 'NL',
        countryName: 'Netherlands',
        city: 'Amsterdam',
        flagEmoji: '🇳🇱',
        protocol: 'ovpn',
        ipAddress: '194.36.144.50',
        port: 1194,
        pingMs: 32,
        currentLoad: 35,
        isPremium: false,
      ),
      ServerEntity(
        id: 3,
        name: 'London Express OpenVPN 01',
        countryCode: 'GB',
        countryName: 'United Kingdom',
        city: 'London',
        flagEmoji: '🇬🇧',
        protocol: 'ovpn',
        ipAddress: '89.238.150.10',
        port: 1194,
        pingMs: 39,
        currentLoad: 18,
        isPremium: false,
      ),
    ];
  }
}
