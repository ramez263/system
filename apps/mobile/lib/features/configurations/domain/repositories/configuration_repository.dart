import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/configuration_entity.dart';

abstract class IConfigurationRepository {
  /// Fetches locally stored user configurations from Drift SQLite database.
  Future<Either<Failure, List<ConfigurationEntity>>> getLocalConfigurations();

  /// Inserts or updates a configuration in local SQLite storage.
  Future<Either<Failure, ConfigurationEntity>> saveConfiguration(ConfigurationEntity config);

  /// Deletes a configuration from local storage.
  Future<Either<Failure, void>> deleteConfiguration(int id);

  /// Fetches shared community configurations from the control plane API.
  Future<Either<Failure, List<ConfigurationEntity>>> getCommunityConfigurations({String? search});

  /// Imports configuration by 8-character share code from backend.
  Future<Either<Failure, ConfigurationEntity>> importByShareCode(String shareCode);

  /// Publishes a custom configuration to the control plane, returning generated share code.
  Future<Either<Failure, String>> shareConfiguration(ConfigurationEntity config);

  /// Safely parses raw text (RTP, OVPN, or URI), validates, and saves locally.
  Future<Either<Failure, ConfigurationEntity>> importFromRawString(String rawData, {String? name});
}
