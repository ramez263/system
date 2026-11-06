import 'package:dio/dio.dart';
import '../config/app_environment.dart';
import '../services/device_identity_service.dart';
import 'interceptors/device_auth_interceptor.dart';
import 'interceptors/logging_redaction_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  final Dio _dio;

  DioClient({
    required AppConfig config,
    required DeviceIdentityService deviceIdentityService,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: config.connectTimeout,
            receiveTimeout: config.receiveTimeout,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.addAll([
      DeviceAuthInterceptor(deviceIdentityService),
      LoggingRedactionInterceptor(isEnabled: config.enableLogging),
      RetryInterceptor(dio: _dio),
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }
}
