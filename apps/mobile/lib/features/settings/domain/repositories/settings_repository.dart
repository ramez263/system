import '../entities/advanced_network_settings.dart';
import '../entities/app_settings_entity.dart';

abstract class ISettingsRepository {
  Future<AdvancedNetworkSettings> getAdvancedSettings();
  Future<void> saveAdvancedSettings(AdvancedNetworkSettings settings);
  Future<AppSettingsEntity> getAppSettings();
  Future<void> saveAppSettings(AppSettingsEntity settings);
  Future<void> clearCache();
  Future<String> exportRedactedDiagnosticLogs();
}
