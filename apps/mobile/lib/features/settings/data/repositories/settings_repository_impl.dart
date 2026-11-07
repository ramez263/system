import 'dart:convert';
import 'dart:io';
import '../../../../core/storage/hive_storage_service.dart';
import '../../domain/entities/advanced_network_settings.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final IHiveStorageService _hiveStorage;

  static const String _advSettingsKey = 'cached_adv_network_settings';
  static const String _appSettingsKey = 'cached_general_app_settings';

  SettingsRepositoryImpl({required IHiveStorageService hiveStorage})
      : _hiveStorage = hiveStorage;

  @override
  Future<AdvancedNetworkSettings> getAdvancedSettings() async {
    final raw = _hiveStorage.get<String>(HiveStorageService.boxSettings, _advSettingsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return AdvancedNetworkSettings.fromJson(map);
      } catch (_) {}
    }
    return const AdvancedNetworkSettings();
  }

  @override
  Future<void> saveAdvancedSettings(AdvancedNetworkSettings settings) async {
    await _hiveStorage.put(
      HiveStorageService.boxSettings,
      _advSettingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  @override
  Future<AppSettingsEntity> getAppSettings() async {
    final raw = _hiveStorage.get<String>(HiveStorageService.boxSettings, _appSettingsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return AppSettingsEntity.fromJson(map);
      } catch (_) {}
    }
    return const AppSettingsEntity();
  }

  @override
  Future<void> saveAppSettings(AppSettingsEntity settings) async {
    await _hiveStorage.put(
      HiveStorageService.boxSettings,
      _appSettingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  @override
  Future<void> clearCache() async {
    await _hiveStorage.clearBox(HiveStorageService.boxCache);
  }

  @override
  Future<String> exportRedactedDiagnosticLogs() async {
    final adv = await getAdvancedSettings();
    final app = await getAppSettings();

    final buffer = StringBuffer();
    buffer.writeln('=== RAMEZ TUNNEL PLUS DIAGNOSTIC REPORT ===');
    buffer.writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}');
    buffer.writeln('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    buffer.writeln('App Version: 1.0.0+1 (Phase 8 Verified)');
    buffer.writeln('Device Identity: [REDACTED_HARDWARE_UUID]');
    buffer.writeln('Push Token: [REDACTED_FCM_TOKEN]');
    buffer.writeln('--- Network Settings ---');
    buffer.writeln('MTU: ${adv.mtu}');
    buffer.writeln('DNS Provider: ${adv.dnsProvider}');
    buffer.writeln('IPv6 Protection: ${adv.ipv6Protection}');
    buffer.writeln('Kill Switch Enabled: ${adv.killSwitch}');
    buffer.writeln('Split Tunneling: ${adv.splitTunnelingEnabled} (${adv.splitTunnelingMode})');
    buffer.writeln('Excluded Apps Count: ${adv.selectedApps.length}');
    buffer.writeln('--- Automation Settings ---');
    buffer.writeln('Auto Connect On Boot: ${app.autoConnectOnBoot}');
    buffer.writeln('Auto Connect On Wi-Fi: ${app.autoConnectOnWifi}');
    buffer.writeln('Bypass Trusted Wi-Fi: ${app.excludeTrustedWifi}');
    buffer.writeln('=== END DIAGNOSTIC REPORT (Zero PII / Zero Plaintext Keys) ===');

    return buffer.toString();
  }
}
