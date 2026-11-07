import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/session_record.dart';

abstract class ITelemetryRepository {
  /// Records completed session locally in Drift SQLite and reports to backend.
  Future<Either<Failure, void>> recordSession(SessionRecord record);

  /// Retrieves local session history logs from SQLite database.
  Future<Either<Failure, List<SessionRecord>>> getLocalSessions();

  /// Retrieves aggregate telemetry usage from the control plane API.
  Future<Either<Failure, Map<String, dynamic>>> getUsageSummary();
}
