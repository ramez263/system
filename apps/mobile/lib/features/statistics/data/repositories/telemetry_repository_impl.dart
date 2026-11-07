import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/database/app_database.dart';
import '../../domain/entities/session_record.dart';
import '../../domain/repositories/telemetry_repository.dart';

class TelemetryRepositoryImpl implements ITelemetryRepository {
  final AppDatabase _database;
  final DioClient _dioClient;

  TelemetryRepositoryImpl({
    required AppDatabase database,
    required DioClient dioClient,
  })  : _database = database,
        _dioClient = dioClient;

  @override
  Future<Either<Failure, void>> recordSession(SessionRecord record) async {
    try {
      // 1. Insert into local SQLite
      final companion = ConnectionLogsCompanion.insert(
        serverName: record.serverName,
        protocol: record.protocol,
        connectedAt: record.connectedAt,
        disconnectedAt: Value(record.disconnectedAt),
        durationSeconds: Value(record.durationSeconds),
        bytesUploaded: Value(record.bytesUploaded),
        bytesDownloaded: Value(record.bytesDownloaded),
        disconnectReason: Value(record.disconnectReason),
      );

      await _database.into(_database.connectionLogs).insert(companion);

      // 2. Report to backend API asynchronously
      try {
        await _dioClient.post(
          '/api/v1/telemetry/session',
          data: {
            'session_uuid': const Uuid().v4(),
            'protocol': record.protocol,
            'bytes_in': record.bytesDownloaded,
            'bytes_out': record.bytesUploaded,
            'duration_seconds': record.durationSeconds,
            'disconnect_reason': record.disconnectReason ?? 'user_disconnect',
            'connected_at': record.connectedAt.toIso8601String(),
            'disconnected_at': record.disconnectedAt?.toIso8601String(),
          },
        );
      } catch (_) {
        // Safe fail: local record is already preserved in SQLite
      }

      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to log session: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SessionRecord>>> getLocalSessions() async {
    try {
      final rows = await (_database.select(_database.connectionLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.connectedAt)]))
          .get();

      final list = rows.map((r) {
        return SessionRecord(
          id: r.id,
          serverName: r.serverName,
          protocol: r.protocol,
          connectedAt: r.connectedAt,
          disconnectedAt: r.disconnectedAt,
          durationSeconds: r.durationSeconds,
          bytesUploaded: r.bytesUploaded,
          bytesDownloaded: r.bytesDownloaded,
          disconnectReason: r.disconnectReason,
        );
      }).toList();

      return Right(list);
    } catch (e) {
      return Left(StorageFailure('Failed to load sessions: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUsageSummary() async {
    try {
      final response = await _dioClient.get('/api/v1/telemetry/summary');
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return Right(data['data'] as Map<String, dynamic>);
      }

      return const Left(ServerFailure('Invalid usage summary response.'));
    } catch (e) {
      // Local fallback calculation from Drift SQLite
      try {
        final sessions = await (_database.select(_database.connectionLogs)).get();
        final totalUploaded = sessions.fold<int>(0, (sum, s) => sum + s.bytesUploaded);
        final totalDownloaded = sessions.fold<int>(0, (sum, s) => sum + s.bytesDownloaded);
        final totalDuration = sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);

        return Right({
          'total_sessions': sessions.length,
          'total_duration_seconds': totalDuration,
          'bytes_downloaded': totalDownloaded,
          'bytes_uploaded': totalUploaded,
          'total_bytes_transferred': totalUploaded + totalDownloaded,
        });
      } catch (localErr) {
        return Left(StorageFailure('Failed to calculate usage summary: $localErr'));
      }
    }
  }
}
