import 'dart:async';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 2,
    this.retryDelay = const Duration(milliseconds: 1000),
  }) : _dio = dio;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    var retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

    final isTransient = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (isTransient && retryCount < maxRetries) {
      retryCount++;
      err.requestOptions.extra['retry_count'] = retryCount;

      final delay = retryDelay * retryCount;
      await Future.delayed(delay);

      try {
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      }
    }

    return handler.next(err);
  }
}
