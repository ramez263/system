import 'package:flutter_test/flutter_test.dart';
import 'package:tunnel_plus/features/settings/domain/entities/advanced_network_settings.dart';
import 'package:tunnel_plus/features/settings/domain/entities/app_settings_entity.dart';
import 'package:tunnel_plus/features/settings/domain/repositories/settings_repository.dart';
import 'package:tunnel_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tunnel_plus/features/settings/presentation/cubit/settings_state.dart';

class MockSettingsRepository implements ISettingsRepository {
  AdvancedNetworkSettings advSettings = const AdvancedNetworkSettings();
  AppSettingsEntity appSettings = const AppSettingsEntity();
  bool cacheCleared = false;

  @override
  Future<AdvancedNetworkSettings> getAdvancedSettings() async => advSettings;

  @override
  Future<void> saveAdvancedSettings(AdvancedNetworkSettings settings) async {
    advSettings = settings;
  }

  @override
  Future<AppSettingsEntity> getAppSettings() async => appSettings;

  @override
  Future<void> saveAppSettings(AppSettingsEntity settings) async {
    appSettings = settings;
  }

  @override
  Future<void> clearCache() async {
    cacheCleared = true;
  }

  @override
  Future<String> exportRedactedDiagnosticLogs() async {
    return '=== MOCK REDACTED DIAGNOSTICS ===\nPlatform: android\nDevice: [REDACTED]';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSettingsRepository repository;
  late SettingsCubit cubit;

  setUp(() {
    repository = MockSettingsRepository();
    cubit = SettingsCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  test('loadSettings emits SettingsLoaded with default configurations', () async {
    final expectedStates = [
      isA<SettingsLoading>(),
      isA<SettingsLoaded>()
          .having((s) => s.advancedSettings.killSwitch, 'killSwitch', true)
          .having((s) => s.advancedSettings.mtu, 'mtu', 1420)
          .having((s) => s.appSettings.autoConnectOnWifi, 'autoConnectOnWifi', true),
    ];

    expectLater(cubit.stream, emitsInOrder(expectedStates));
    await cubit.loadSettings();
  });

  test('updateAdvancedSettings updates MTU, DNS, and Split Tunneling', () async {
    await cubit.loadSettings();

    await cubit.updateAdvancedSettings(
      mtu: 1400,
      dnsProvider: 'AdGuard Ad-Blocking',
      splitTunnelingEnabled: true,
      splitTunnelingMode: 'exclude',
    );

    expect(cubit.state, isA<SettingsLoaded>());
    final state = cubit.state as SettingsLoaded;
    expect(state.advancedSettings.mtu, 1400);
    expect(state.advancedSettings.dnsProvider, 'AdGuard Ad-Blocking');
    expect(state.advancedSettings.splitTunnelingEnabled, true);
    expect(repository.advSettings.mtu, 1400);
  });

  test('toggleAppForSplitTunnel adds and removes application packages', () async {
    await cubit.loadSettings();

    // Add app
    await cubit.toggleAppForSplitTunnel('com.whatsapp');
    var state = cubit.state as SettingsLoaded;
    expect(state.advancedSettings.selectedApps, contains('com.whatsapp'));
    expect(repository.advSettings.selectedApps, contains('com.whatsapp'));

    // Remove app
    await cubit.toggleAppForSplitTunnel('com.whatsapp');
    state = cubit.state as SettingsLoaded;
    expect(state.advancedSettings.selectedApps, isNot(contains('com.whatsapp')));
  });

  test('clearAppCache clears cache and sets feedback message', () async {
    await cubit.loadSettings();

    await cubit.clearAppCache();

    expect(repository.cacheCleared, true);
    final state = cubit.state as SettingsLoaded;
    expect(state.feedbackMessage, contains('Cache cleared successfully'));
  });

  test('exportDiagnosticReport returns privacy-compliant redacted logs', () async {
    await cubit.loadSettings();

    final logs = await cubit.exportDiagnosticReport();
    expect(logs, contains('[REDACTED]'));
    expect(logs, isNot(contains('password')));
  });
}
