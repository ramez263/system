import 'package:equatable/equatable.dart';

class SessionRecord extends Equatable {
  final int? id;
  final String serverName;
  final String protocol;
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final int durationSeconds;
  final int bytesUploaded;
  final int bytesDownloaded;
  final String? disconnectReason;

  const SessionRecord({
    this.id,
    required this.serverName,
    required this.protocol,
    required this.connectedAt,
    this.disconnectedAt,
    this.durationSeconds = 0,
    this.bytesUploaded = 0,
    this.bytesDownloaded = 0,
    this.disconnectReason,
  });

  @override
  List<Object?> get props => [
        id,
        serverName,
        protocol,
        connectedAt,
        disconnectedAt,
        durationSeconds,
        bytesUploaded,
        bytesDownloaded,
        disconnectReason,
      ];
}
