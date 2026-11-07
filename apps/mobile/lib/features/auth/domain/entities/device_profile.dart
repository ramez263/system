import 'package:equatable/equatable.dart';

class DeviceProfile extends Equatable {
  final String deviceUuid;
  final String deviceName;
  final bool isActive;
  final bool isPremium;
  final String tier; // 'free' or 'pro'
  final int maxDevices;
  final int dailyBandwidthLimitBytes;
  final int bytesUploaded;
  final int bytesDownloaded;
  final DateTime? lastHandshakeAt;

  const DeviceProfile({
    required this.deviceUuid,
    required this.deviceName,
    required this.isActive,
    required this.isPremium,
    required this.tier,
    this.maxDevices = 1,
    this.dailyBandwidthLimitBytes = 0,
    this.bytesUploaded = 0,
    this.bytesDownloaded = 0,
    this.lastHandshakeAt,
  });

  @override
  List<Object?> get props => [
        deviceUuid,
        deviceName,
        isActive,
        isPremium,
        tier,
        maxDevices,
        dailyBandwidthLimitBytes,
        bytesUploaded,
        bytesDownloaded,
        lastHandshakeAt,
      ];
}
