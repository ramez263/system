import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/device_profile.dart';

abstract class IAuthRepository {
  /// Performs background handshake with backend using hardware metadata.
  Future<Either<Failure, DeviceProfile>> performHandshake();

  /// Gets cached or remote device profile.
  Future<Either<Failure, DeviceProfile>> getDeviceProfile();

  /// Updates FCM push notification token.
  Future<Either<Failure, void>> updatePushToken(String token);
}
