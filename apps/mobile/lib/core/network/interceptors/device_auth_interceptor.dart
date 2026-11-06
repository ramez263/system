import 'dart:io';
import 'package:dio/dio.dart';
import '../../services/device_identity_service.dart';

class DeviceAuthInterceptor extends Interceptor {
  final DeviceIdentityService _deviceIdentityService;

  DeviceAuthInterceptor(this._deviceIdentityService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final deviceUuid = await _deviceIdentityService.getOrCreateDeviceUuid();
    final appVersion = await _deviceIdentityService.getAppVersion();

    options.headers['X-Device-UUID'] = deviceUuid;
    options.headers['X-App-Version'] = appVersion;
    options.headers['X-Platform'] = Platform.operatingSystem;
    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }
}
