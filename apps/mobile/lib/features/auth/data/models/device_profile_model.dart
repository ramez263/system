import '../../domain/entities/device_profile.dart';

class DeviceProfileModel extends DeviceProfile {
  const DeviceProfileModel({
    required super.deviceUuid,
    required super.deviceName,
    required super.isActive,
    required super.isPremium,
    required super.tier,
    super.maxDevices = 1,
    super.dailyBandwidthLimitBytes = 0,
    super.bytesUploaded = 0,
    super.bytesDownloaded = 0,
    super.lastHandshakeAt,
  });

  factory DeviceProfileModel.fromJson(Map<String, dynamic> json) {
    return DeviceProfileModel(
      deviceUuid: json['device_uuid'] as String? ?? '',
      deviceName: json['device_name'] as String? ?? 'Android Device',
      isActive: json['is_active'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? false,
      tier: json['tier'] as String? ?? 'free',
      maxDevices: json['max_devices'] as int? ?? 1,
      dailyBandwidthLimitBytes: json['daily_bandwidth_limit_bytes'] as int? ?? 0,
      bytesUploaded: json['bytes_uploaded'] as int? ?? 0,
      bytesDownloaded: json['bytes_downloaded'] as int? ?? 0,
      lastHandshakeAt: json['last_handshake_at'] != null
          ? DateTime.tryParse(json['last_handshake_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_uuid': deviceUuid,
      'device_name': deviceName,
      'is_active': isActive,
      'is_premium': isPremium,
      'tier': tier,
      'max_devices': maxDevices,
      'daily_bandwidth_limit_bytes': dailyBandwidthLimitBytes,
      'bytes_uploaded': bytesUploaded,
      'bytes_downloaded': bytesDownloaded,
      'last_handshake_at': lastHandshakeAt?.toIso8601String(),
    };
  }
}
