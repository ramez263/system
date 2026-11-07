import 'package:equatable/equatable.dart';
import '../../../../core/widgets/ramez_status_chip.dart';
import '../../../configurations/domain/entities/configuration_entity.dart';
import '../../../servers/domain/entities/server_entity.dart';

class VpnConnectionState extends Equatable {
  final TunnelState status;
  final ServerEntity? selectedServer;
  final ConfigurationEntity? selectedConfig;
  final String? connectedServerName;
  final DateTime? connectedAt;
  final int durationSeconds;
  final int bytesIn;
  final int bytesOut;
  final int downloadSpeedBps;
  final int uploadSpeedBps;
  final String? errorMessage;

  const VpnConnectionState({
    this.status = TunnelState.disconnected,
    this.selectedServer,
    this.selectedConfig,
    this.connectedServerName,
    this.connectedAt,
    this.durationSeconds = 0,
    this.bytesIn = 0,
    this.bytesOut = 0,
    this.downloadSpeedBps = 0,
    this.uploadSpeedBps = 0,
    this.errorMessage,
  });

  bool get isConnected => status == TunnelState.connected;
  bool get isConnecting =>
      status == TunnelState.connecting || status == TunnelState.reconnecting;
  bool get isDisconnected => status == TunnelState.disconnected;

  String get formattedDuration {
    final h = (durationSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((durationSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (durationSeconds % 60).toString().padLeft(2, '0');
    if (h != '00') return '$h:$m:$s';
    return '$m:$s';
  }

  String get downloadSpeedMbps {
    final mbps = (downloadSpeedBps * 8) / 1000000.0;
    return mbps.toStringAsFixed(1);
  }

  String get uploadSpeedMbps {
    final mbps = (uploadSpeedBps * 8) / 1000000.0;
    return mbps.toStringAsFixed(1);
  }

  VpnConnectionState copyWith({
    TunnelState? status,
    ServerEntity? selectedServer,
    ConfigurationEntity? selectedConfig,
    String? connectedServerName,
    DateTime? connectedAt,
    int? durationSeconds,
    int? bytesIn,
    int? bytesOut,
    int? downloadSpeedBps,
    int? uploadSpeedBps,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VpnConnectionState(
      status: status ?? this.status,
      selectedServer: selectedServer ?? this.selectedServer,
      selectedConfig: selectedConfig ?? this.selectedConfig,
      connectedServerName: connectedServerName ?? this.connectedServerName,
      connectedAt: connectedAt ?? this.connectedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      bytesIn: bytesIn ?? this.bytesIn,
      bytesOut: bytesOut ?? this.bytesOut,
      downloadSpeedBps: downloadSpeedBps ?? this.downloadSpeedBps,
      uploadSpeedBps: uploadSpeedBps ?? this.uploadSpeedBps,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedServer,
        selectedConfig,
        connectedServerName,
        connectedAt,
        durationSeconds,
        bytesIn,
        bytesOut,
        downloadSpeedBps,
        uploadSpeedBps,
        errorMessage,
      ];
}
