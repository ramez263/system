import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/server_entity.dart';

abstract class IServerRepository {
  /// Fetches curated servers catalog with optional query filters.
  Future<Either<Failure, List<ServerEntity>>> getServers({
    String? country,
    String? protocol,
    bool? isPremium,
    String? search,
  });

  /// Downloads raw OpenVPN configuration text for a specific server.
  Future<Either<Failure, String>> downloadOvpnConfig(int serverId);

  /// Retrieves list of unique countries offering servers.
  Future<Either<Failure, List<Map<String, dynamic>>>> getCountries();
}
