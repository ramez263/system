import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../storage/secure_storage_service.dart';

class DeviceIdentityService {
  final ISecureStorageService _secureStorage;
  final DeviceInfoPlugin _deviceInfo;

  DeviceIdentityService({
    required ISecureStorageService secureStorage,
    DeviceInfoPlugin? deviceInfo,
  })  : _secureStorage = secureStorage,
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  String? _cachedDeviceUuid;

  Future<String> getOrCreateDeviceUuid() async {
    if (_cachedDeviceUuid != null) return _cachedDeviceUuid!;

    var uuid = await _secureStorage.read(SecureStorageService.keyDeviceUuid);
    if (uuid == null || uuid.isEmpty) {
      uuid = const Uuid().v4();
      await _secureStorage.write(SecureStorageService.keyDeviceUuid, uuid);
    }

    _cachedDeviceUuid = uuid;
    return uuid;
  }

  Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (_) {
      return '1.0.0+1';
    }
  }

  Future<Map<String, dynamic>> getDeviceMetadata() async {
    final uuid = await getOrCreateDeviceUuid();
    final appVersion = await getAppVersion();

    String deviceName = 'Unknown Device';
    String osVersion = Platform.operatingSystemVersion;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceName = iosInfo.utsname.machine;
        osVersion = 'iOS ${iosInfo.systemVersion}';
      }
    } catch (_) {
      // Fallback to basic details on unsupported or mocked platforms
    }

    return {
      'device_uuid': uuid,
      'device_name': deviceName,
      'os_version': osVersion,
      'app_version': appVersion,
      'platform': Platform.operatingSystem,
    };
  }
}
