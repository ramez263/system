import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/vpn/vpn_bridge.g.dart';
import '../../../../core/vpn/vpn_service.dart';
import '../../../../core/widgets/ramez_status_chip.dart';
import '../../../configurations/domain/entities/configuration_entity.dart';
import '../../../servers/domain/entities/server_entity.dart';
import '../../../servers/domain/repositories/server_repository.dart';
import '../../../statistics/domain/entities/session_record.dart';
import '../../../statistics/domain/repositories/telemetry_repository.dart';
import 'vpn_connection_state.dart';

class VpnConnectionCubit extends Cubit<VpnConnectionState> {
  final IVpnService _vpnService;
  final IServerRepository _serverRepository;
  final ITelemetryRepository? _telemetryRepository;

  StreamSubscription<TunnelState>? _statusSubscription;
  StreamSubscription<VpnStatsPayload>? _statsSubscription;

  VpnConnectionCubit({
    required IVpnService vpnService,
    required IServerRepository serverRepository,
    ITelemetryRepository? telemetryRepository,
  })  : _vpnService = vpnService,
        _serverRepository = serverRepository,
        _telemetryRepository = telemetryRepository,
        super(const VpnConnectionState()) {
    _init();
  }

  Future<void> _init() async {
    // Listen to native status updates
    _statusSubscription = _vpnService.statusStream.listen(_onStatusChanged);

    // Listen to native stats updates
    _statsSubscription = _vpnService.statsStream.listen(_onStatsChanged);

    // Check initial native status
    try {
      final initialStatus = await _vpnService.getStatus();
      final mappedState = _mapStringToState(initialStatus.state);
      emit(state.copyWith(
        status: mappedState,
        connectedServerName: initialStatus.connectedServerName,
      ));
    } catch (_) {
      // Ignore on startup if platform is initializing
    }
  }

  void _onStatusChanged(TunnelState newStatus) {
    if (state.status == TunnelState.connected &&
        newStatus == TunnelState.disconnected) {
      _recordCompletedSession();
    }

    emit(state.copyWith(
      status: newStatus,
      connectedAt: newStatus == TunnelState.connected
          ? (state.connectedAt ?? DateTime.now())
          : (newStatus == TunnelState.disconnected ? null : state.connectedAt),
      durationSeconds:
          newStatus == TunnelState.disconnected ? 0 : state.durationSeconds,
      downloadSpeedBps:
          newStatus == TunnelState.disconnected ? 0 : state.downloadSpeedBps,
      uploadSpeedBps:
          newStatus == TunnelState.disconnected ? 0 : state.uploadSpeedBps,
    ));
  }

  void _onStatsChanged(VpnStatsPayload stats) {
    if (state.status == TunnelState.connected) {
      emit(state.copyWith(
        bytesIn: stats.bytesIn,
        bytesOut: stats.bytesOut,
        downloadSpeedBps: stats.downloadSpeedBps,
        uploadSpeedBps: stats.uploadSpeedBps,
        durationSeconds: stats.durationSeconds,
      ));
    }
  }

  void selectServer(ServerEntity server) {
    emit(state.copyWith(
      selectedServer: server,
      selectedConfig: null,
    ));
  }

  void selectConfig(ConfigurationEntity config) {
    emit(state.copyWith(
      selectedConfig: config,
      selectedServer: null,
    ));
  }

  Future<void> toggleConnection() async {
    if (state.isConnected || state.isConnecting) {
      await disconnect();
    } else {
      await connect();
    }
  }

  Future<void> connect() async {
    emit(state.copyWith(
      status: TunnelState.connecting,
      clearError: true,
    ));

    try {
      // 1. Prepare VPN (check/request permission)
      final prepared = await _vpnService.prepare();
      if (!prepared) {
        emit(state.copyWith(
          status: TunnelState.failed,
          errorMessage: 'VPN authorization permission denied by user',
        ));
        return;
      }

      // 2. Build profile payload
      final VpnProfilePayload profile;

      if (state.selectedConfig != null) {
        final cfg = state.selectedConfig!;
        profile = VpnProfilePayload(
          id: cfg.id?.toString() ?? 'custom_config',
          name: cfg.name,
          protocol: cfg.protocol,
          serverAddress: cfg.serverAddress,
          serverPort: cfg.serverPort,
          rawPayload: cfg.rawConfig,
          dnsServers: const ['1.1.1.1', '8.8.8.8'],
          bypassLan: true,
          excludedApps: const [],
        );
      } else if (state.selectedServer != null) {
        final server = state.selectedServer!;
        String rawConfig = '';

        if (server.hasOvpn) {
          final res = await _serverRepository.downloadOvpnConfig(server.id);
          rawConfig = res.fold(
            (failure) => '',
            (ovpn) => ovpn,
          );
        }

        profile = VpnProfilePayload(
          id: server.id.toString(),
          name: server.name,
          protocol: server.protocol,
          serverAddress: server.ipAddress,
          serverPort: server.port,
          rawPayload: rawConfig,
          dnsServers: const ['1.1.1.1', '8.8.8.8'],
          bypassLan: true,
          excludedApps: const [],
        );
      } else {
        // Fallback default: Frankfurt fast server
        profile = VpnProfilePayload(
          id: 'default_server_01',
          name: 'Frankfurt Fast-01',
          protocol: 'ovpn',
          serverAddress: '185.220.101.5',
          serverPort: 1194,
          rawPayload:
              'client\ndev tun\nproto udp\nremote 185.220.101.5 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nverb 3\n',
          dnsServers: const ['1.1.1.1', '8.8.8.8'],
          bypassLan: true,
          excludedApps: const [],
        );
      }

      final success = await _vpnService.connect(profile);
      if (success) {
        emit(state.copyWith(
          connectedServerName: profile.name,
          connectedAt: DateTime.now(),
        ));
      } else {
        emit(state.copyWith(
          status: TunnelState.failed,
          errorMessage: 'Failed to establish native VPN tunnel',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TunnelState.failed,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> disconnect() async {
    try {
      await _vpnService.disconnect();
      _recordCompletedSession();
      emit(state.copyWith(
        status: TunnelState.disconnected,
        durationSeconds: 0,
        bytesIn: 0,
        bytesOut: 0,
        downloadSpeedBps: 0,
        uploadSpeedBps: 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to disconnect: $e',
      ));
    }
  }

  void _recordCompletedSession() {
    if (state.connectedAt != null && _telemetryRepository != null) {
      final now = DateTime.now();
      final duration = now.difference(state.connectedAt!).inSeconds;
      final session = SessionRecord(
        serverName: state.connectedServerName ?? 'Unknown Server',
        protocol: state.selectedConfig?.protocol ??
            state.selectedServer?.protocol ??
            'ovpn',
        connectedAt: state.connectedAt!,
        disconnectedAt: now,
        durationSeconds:
            state.durationSeconds > 0 ? state.durationSeconds : (duration >= 0 ? duration : 0),
        bytesUploaded: state.bytesOut,
        bytesDownloaded: state.bytesIn,
        disconnectReason: 'User initiated disconnect',
      );
      _telemetryRepository.recordSession(session);
    }
  }

  TunnelState _mapStringToState(String s) {
    switch (s.toLowerCase()) {
      case 'connected':
        return TunnelState.connected;
      case 'connecting':
        return TunnelState.connecting;
      case 'reconnecting':
        return TunnelState.reconnecting;
      case 'failed':
        return TunnelState.failed;
      default:
        return TunnelState.disconnected;
    }
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    _statsSubscription?.cancel();
    return super.close();
  }
}
