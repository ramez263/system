import 'package:equatable/equatable.dart';

class AppSettingsEntity extends Equatable {
  final bool autoConnectOnBoot;
  final bool autoConnectOnWifi;
  final bool autoConnectOnCellular;
  final bool excludeTrustedWifi;
  final bool dataLimitAlertEnabled;
  final int dataLimitThresholdMb;

  const AppSettingsEntity({
    this.autoConnectOnBoot = false,
    this.autoConnectOnWifi = true,
    this.autoConnectOnCellular = false,
    this.excludeTrustedWifi = true,
    this.dataLimitAlertEnabled = false,
    this.dataLimitThresholdMb = 2000,
  });

  AppSettingsEntity copyWith({
    bool? autoConnectOnBoot,
    bool? autoConnectOnWifi,
    bool? autoConnectOnCellular,
    bool? excludeTrustedWifi,
    bool? dataLimitAlertEnabled,
    int? dataLimitThresholdMb,
  }) {
    return AppSettingsEntity(
      autoConnectOnBoot: autoConnectOnBoot ?? this.autoConnectOnBoot,
      autoConnectOnWifi: autoConnectOnWifi ?? this.autoConnectOnWifi,
      autoConnectOnCellular: autoConnectOnCellular ?? this.autoConnectOnCellular,
      excludeTrustedWifi: excludeTrustedWifi ?? this.excludeTrustedWifi,
      dataLimitAlertEnabled: dataLimitAlertEnabled ?? this.dataLimitAlertEnabled,
      dataLimitThresholdMb: dataLimitThresholdMb ?? this.dataLimitThresholdMb,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auto_connect_on_boot': autoConnectOnBoot,
      'auto_connect_on_wifi': autoConnectOnWifi,
      'auto_connect_on_cellular': autoConnectOnCellular,
      'exclude_trusted_wifi': excludeTrustedWifi,
      'data_limit_alert_enabled': dataLimitAlertEnabled,
      'data_limit_threshold_mb': dataLimitThresholdMb,
    };
  }

  factory AppSettingsEntity.fromJson(Map<String, dynamic> json) {
    return AppSettingsEntity(
      autoConnectOnBoot: json['auto_connect_on_boot'] == true,
      autoConnectOnWifi: json['auto_connect_on_wifi'] != false,
      autoConnectOnCellular: json['auto_connect_on_cellular'] == true,
      excludeTrustedWifi: json['exclude_trusted_wifi'] != false,
      dataLimitAlertEnabled: json['data_limit_alert_enabled'] == true,
      dataLimitThresholdMb: (json['data_limit_threshold_mb'] as num?)?.toInt() ?? 2000,
    );
  }

  @override
  List<Object?> get props => [
        autoConnectOnBoot,
        autoConnectOnWifi,
        autoConnectOnCellular,
        excludeTrustedWifi,
        dataLimitAlertEnabled,
        dataLimitThresholdMb,
      ];
}
