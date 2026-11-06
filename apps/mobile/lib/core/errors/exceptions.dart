class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message ($statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class StorageException implements Exception {
  final String message;

  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

class VpnNativeException implements Exception {
  final String message;
  final String? nativeErrorCode;

  const VpnNativeException(this.message, {this.nativeErrorCode});

  @override
  String toString() => 'VpnNativeException: $message ($nativeErrorCode)';
}
