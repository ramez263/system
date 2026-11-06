import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class LoggingRedactionInterceptor extends Interceptor {
  final bool isEnabled;

  LoggingRedactionInterceptor({this.isEnabled = true});

  static final RegExp _ipPattern = RegExp(
    r'\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b',
  );
  static final RegExp _uuidPattern = RegExp(
    r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
  );
  static final RegExp _secretPattern = RegExp(
    r'(password|secret|token|key|credential)["' "'" r']?\s*[:=]\s*["' "'" r']?([^"' "'" r',\s]+)',
    caseSensitive: false,
  );

  static String redact(String input) {
    var result = input.replaceAllMapped(_secretPattern, (m) => '${m.group(1)}: [REDACTED_SECRET]');
    result = result.replaceAll(_uuidPattern, '[REDACTED_UUID]');
    result = result.replaceAll(_ipPattern, '[REDACTED_IP]');
    return result;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (isEnabled) {
      final safeUrl = redact(options.uri.toString());
      developer.log(
        '--> ${options.method} $safeUrl',
        name: 'RamezNetwork',
      );
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (isEnabled) {
      developer.log(
        '<-- ${response.statusCode} ${response.requestOptions.uri.path}',
        name: 'RamezNetwork',
      );
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isEnabled) {
      final safeMessage = redact(err.message ?? 'Unknown network error');
      developer.log(
        '<-- ERROR ${err.response?.statusCode}: $safeMessage',
        name: 'RamezNetwork',
        error: err.error,
      );
    }
    return handler.next(err);
  }
}
