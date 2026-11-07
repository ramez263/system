import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/session_record.dart';
import '../../domain/repositories/telemetry_repository.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final List<SessionRecord> sessions;
  final Map<String, dynamic> summary;

  const StatisticsLoaded({
    required this.sessions,
    required this.summary,
  });

  @override
  List<Object?> get props => [sessions, summary];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class StatisticsCubit extends Cubit<StatisticsState> {
  final ITelemetryRepository _repository;

  StatisticsCubit(this._repository) : super(StatisticsInitial());

  Future<void> loadStatistics() async {
    emit(StatisticsLoading());

    final sessionsResult = await _repository.getLocalSessions();
    final summaryResult = await _repository.getUsageSummary();

    sessionsResult.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (sessions) {
        final summary = summaryResult.getOrElse((_) => {
          'total_sessions': sessions.length,
          'total_duration_seconds': 0,
          'bytes_downloaded': 0,
          'bytes_uploaded': 0,
          'total_bytes_transferred': 0,
        });

        emit(StatisticsLoaded(sessions: sessions, summary: summary));
      },
    );
  }

  Future<void> recordCompletedSession(SessionRecord record) async {
    await _repository.recordSession(record);
    await loadStatistics();
  }
}
