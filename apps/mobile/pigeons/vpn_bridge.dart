import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/core/vpn/vpn_bridge.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/app/src/main/kotlin/com/ramez/tunnel_plus/vpn/bridge/VpnBridge.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.ramez.tunnel_plus.vpn.bridge',
  ),
))

class VpnProfilePayload {
  String id;
  String name;
  String protocol;
  String serverAddress;
  int serverPort;
  String rawPayload;
  List<String> dnsServers;
  bool bypassLan;
  List<String> excludedApps;

  VpnProfilePayload({
    required this.id,
    required this.name,
    required this.protocol,
    required this.serverAddress,
    required this.serverPort,
    required this.rawPayload,
    required this.dnsServers,
    required this.bypassLan,
    required this.excludedApps,
  });
}

class VpnStatusPayload {
  String state; // disconnected, preparing, connecting, connected, reconnecting, failed
  String? connectedServerName;
  String? errorMessage;
  String? connectedAtIso;

  VpnStatusPayload({
    required this.state,
    this.connectedServerName,
    this.errorMessage,
    this.connectedAtIso,
  });
}

class VpnStatsPayload {
  int bytesIn;
  int bytesOut;
  int downloadSpeedBps;
  int uploadSpeedBps;
  int durationSeconds;

  VpnStatsPayload({
    required this.bytesIn,
    required this.bytesOut,
    required this.downloadSpeedBps,
    required this.uploadSpeedBps,
    required this.durationSeconds,
  });
}

class VpnEngineInfo {
  String id;
  String name;
  List<String> supportedProtocols;
  String version;

  VpnEngineInfo({
    required this.id,
    required this.name,
    required this.supportedProtocols,
    required this.version,
  });
}

@HostApi()
abstract class VpnHostApi {
  @async
  bool prepare();

  @async
  bool connect(VpnProfilePayload profile);

  @async
  bool disconnect();

  VpnStatusPayload getStatus();

  List<VpnEngineInfo> listEngines();
}
