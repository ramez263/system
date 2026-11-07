import 'dart:async';
import 'package:flutter/services.dart';
import '../widgets/ramez_status_chip.dart';
import 'vpn_bridge.g.dart';

abstract class IVpnService {
  Stream<TunnelState> get statusStream;
  Stream<VpnStatsPayload> get statsStream;
  Future<bool> prepare();
  Future<bool> connect(VpnProfilePayload profile);
  Future<bool> disconnect();
  Future<VpnStatusPayload> getStatus();
  Future<List<VpnEngineInfo>> listEngines();
  void dispose();
}

class VpnService implements IVpnService {
  final VpnHostApi _hostApi;
  final EventChannel _statusChannel;
  final EventChannel _statsChannel;

  StreamController<TunnelState>? _statusController;
  StreamController<VpnStatsPayload>? _statsController;
  StreamSubscription? _statusSub;
  StreamSubscription? _statsSub;

  VpnService({
    VpnHostApi? hostApi,
    EventChannel? statusChannel,
    EventChannel? statsChannel,
  })  : _hostApi = hostApi ?? VpnHostApi(),
        _statusChannel = statusChannel ??
            const EventChannel('com.ramez.tunnel_plus/vpn_status'),
        _statsChannel = statsChannel ??
            const EventChannel('com.ramez.tunnel_plus/vpn_stats');

  @override
  Stream<TunnelState> get statusStream {
    _statusController ??= StreamController<TunnelState>.broadcast(
      onListen: _listenStatus,
      onCancel: _cancelStatus,
    );
    return _statusController!.stream;
  }

  @override
  Stream<VpnStatsPayload> get statsStream {
    _statsController ??= StreamController<VpnStatsPayload>.broadcast(
      onListen: _listenStats,
      onCancel: _cancelStats,
    );
    return _statsController!.stream;
  }

  void _listenStatus() {
    _statusSub = _statusChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        final stateStr = event?.toString().toLowerCase() ?? 'disconnected';
        _statusController?.add(_mapStringToTunnelState(stateStr));
      },
      onError: (dynamic error) {
        _statusController?.add(TunnelState.failed);
      },
    );
  }

  void _cancelStatus() {
    _statusSub?.cancel();
    _statusSub = null;
  }

  void _listenStats() {
    _statsSub = _statsChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final map = Map<String, dynamic>.from(event);
          final stats = VpnStatsPayload(
            bytesIn: (map['bytesIn'] as num?)?.toInt() ?? 0,
            bytesOut: (map['bytesOut'] as num?)?.toInt() ?? 0,
            downloadSpeedBps: (map['downloadSpeedBps'] as num?)?.toInt() ?? 0,
            uploadSpeedBps: (map['uploadSpeedBps'] as num?)?.toInt() ?? 0,
            durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
          );
          _statsController?.add(stats);
        }
      },
      onError: (dynamic error) {
        // Silently tolerate stats stream errors
      },
    );
  }

  void _cancelStats() {
    _statsSub?.cancel();
    _statsSub = null;
  }

  TunnelState _mapStringToTunnelState(String state) {
    switch (state) {
      case 'connected':
        return TunnelState.connected;
      case 'connecting':
        return TunnelState.connecting;
      case 'reconnecting':
        return TunnelState.reconnecting;
      case 'failed':
        return TunnelState.failed;
      case 'disconnected':
      case 'disconnecting':
      default:
        return TunnelState.disconnected;
    }
  }

  @override
  Future<bool> prepare() => _hostApi.prepare();

  @override
  Future<bool> connect(VpnProfilePayload profile) => _hostApi.connect(profile);

  @override
  Future<bool> disconnect() => _hostApi.disconnect();

  @override
  Future<VpnStatusPayload> getStatus() => _hostApi.getStatus();

  @override
  Future<List<VpnEngineInfo>> listEngines() => _hostApi.listEngines();

  @override
  void dispose() {
    _cancelStatus();
    _cancelStats();
    _statusController?.close();
    _statsController?.close();
  }
}
