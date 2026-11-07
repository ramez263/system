import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final ISettingsRepository _repository;

  SettingsCubit({required ISettingsRepository repository})
      : _repository = repository,
        super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());

    final adv = await _repository.getAdvancedSettings();
    final app = await _repository.getAppSettings();

    emit(SettingsLoaded(
      advancedSettings: adv,
      appSettings: app,
    ));
  }

  Future<void> updateAdvancedSettings({
    bool? killSwitch,
    bool? ipv6Protection,
    String? dnsProvider,
    String? customDns,
    int? mtu,
    bool? splitTunnelingEnabled,
    String? splitTunnelingMode,
    List<String>? selectedApps,
  }) async {
    if (state is! SettingsLoaded) return;
    final current = state as SettingsLoaded;

    final updated = current.advancedSettings.copyWith(
      killSwitch: killSwitch,
      ipv6Protection: ipv6Protection,
      dnsProvider: dnsProvider,
      customDns: customDns,
      mtu: mtu,
      splitTunnelingEnabled: splitTunnelingEnabled,
      splitTunnelingMode: splitTunnelingMode,
      selectedApps: selectedApps,
    );

    emit(current.copyWith(advancedSettings: updated, clearFeedback: true));
    await _repository.saveAdvancedSettings(updated);
  }

  Future<void> toggleAppForSplitTunnel(String packageName) async {
    if (state is! SettingsLoaded) return;
    final current = state as SettingsLoaded;

    final list = List<String>.from(current.advancedSettings.selectedApps);
    if (list.contains(packageName)) {
      list.remove(packageName);
    } else {
      list.add(packageName);
    }

    await updateAdvancedSettings(selectedApps: list);
  }

  Future<void> updateAppSettings({
    bool? autoConnectOnBoot,
    bool? autoConnectOnWifi,
    bool? autoConnectOnCellular,
    bool? excludeTrustedWifi,
    bool? dataLimitAlertEnabled,
    int? dataLimitThresholdMb,
  }) async {
    if (state is! SettingsLoaded) return;
    final current = state as SettingsLoaded;

    final updated = current.appSettings.copyWith(
      autoConnectOnBoot: autoConnectOnBoot,
      autoConnectOnWifi: autoConnectOnWifi,
      autoConnectOnCellular: autoConnectOnCellular,
      excludeTrustedWifi: excludeTrustedWifi,
      dataLimitAlertEnabled: dataLimitAlertEnabled,
      dataLimitThresholdMb: dataLimitThresholdMb,
    );

    emit(current.copyWith(appSettings: updated, clearFeedback: true));
    await _repository.saveAppSettings(updated);
  }

  Future<void> clearAppCache() async {
    await _repository.clearCache();
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      emit(current.copyWith(feedbackMessage: 'Cache cleared successfully.'));
    }
  }

  Future<String> exportDiagnosticReport() async {
    return await _repository.exportRedactedDiagnosticLogs();
  }
}
