abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code});
}

class VpnEngineFailure extends Failure {
  const VpnEngineFailure(super.message, {super.code});
}

class ConfigParsingFailure extends Failure {
  const ConfigParsingFailure(super.message, {super.code});
}
