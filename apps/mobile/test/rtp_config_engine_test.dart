import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunnel_plus/core/errors/failures.dart';
import 'package:tunnel_plus/core/services/rtp_config_engine.dart';

void main() {
  group('RtpConfigEngine Unit Tests', () {
    const validDeviceUuid = 'device-uuid-test-1234';

    final sampleRtpJson = jsonEncode({
      'schemaVersion': '1.0',
      'id': 'test-profile-uuid',
      'name': 'Frankfurt VIP RTP',
      'description': 'High speed UDP gaming tunnel',
      'protocol': 'ovpn',
      'serverAddress': '185.120.40.12',
      'serverPort': 1194,
      'authMethod': 'none',
      'transport': 'udp',
      'rawPayload': 'client\ndev tun\nremote 185.120.40.12 1194',
      'exportLocked': false,
      'hwidLock': null,
      'createdAt': '2026-11-06T18:00:00Z',
    });

    test('Parses valid .rtp configuration successfully', () {
      final profile = RtpConfigEngine.parseRtp(sampleRtpJson);

      expect(profile.name, 'Frankfurt VIP RTP');
      expect(profile.protocol, 'ovpn');
      expect(profile.serverAddress, '185.120.40.12');
      expect(profile.serverPort, 1194);
      expect(profile.exportLocked, false);
      expect(profile.rawPayload, contains('client'));
    });

    test('Rejects unsupported schema version', () {
      final invalidSchemaJson = jsonEncode({
        'schemaVersion': '2.0',
        'name': 'Future Config',
        'protocol': 'ovpn',
        'serverAddress': '1.1.1.1',
        'serverPort': 1194,
        'rawPayload': '',
      });

      expect(
        () => RtpConfigEngine.parseRtp(invalidSchemaJson),
        throwsA(isA<ConfigParsingFailure>()),
      );
    });

    test('Enforces HWID lock: allows matching device UUID', () {
      final lockedJson = jsonEncode({
        'schemaVersion': '1.0',
        'name': 'Device Locked Config',
        'protocol': 'ovpn',
        'serverAddress': '1.1.1.1',
        'serverPort': 1194,
        'rawPayload': '',
        'hwidLock': validDeviceUuid,
      });

      final profile = RtpConfigEngine.parseRtp(
        lockedJson,
        currentDeviceUuid: validDeviceUuid,
      );

      expect(profile.hwidLock, validDeviceUuid);
    });

    test('Enforces HWID lock: rejects mismatching device UUID', () {
      final lockedJson = jsonEncode({
        'schemaVersion': '1.0',
        'name': 'Device Locked Config',
        'protocol': 'ovpn',
        'serverAddress': '1.1.1.1',
        'serverPort': 1194,
        'rawPayload': '',
        'hwidLock': 'other-device-uuid',
      });

      expect(
        () => RtpConfigEngine.parseRtp(lockedJson, currentDeviceUuid: validDeviceUuid),
        throwsA(isA<ConfigParsingFailure>()),
      );
    });

    test('Enforces export lock: throws when exporting exportLocked profile', () {
      final lockedProfile = RtpProfile(
        id: 'locked-1',
        name: 'Secret Config',
        protocol: 'ovpn',
        serverAddress: '1.2.3.4',
        serverPort: 1194,
        rawPayload: 'secret credentials inside',
        exportLocked: true,
        createdAt: DateTime.now(),
      );

      expect(
        () => RtpConfigEngine.exportRtp(lockedProfile),
        throwsA(isA<ConfigParsingFailure>()),
      );
    });

    test('Exports and signs unlocked RTP profile successfully', () {
      final unlockedProfile = RtpProfile(
        id: 'unlocked-1',
        name: 'Public Config',
        protocol: 'ovpn',
        serverAddress: '1.2.3.4',
        serverPort: 1194,
        rawPayload: 'client\ndev tun',
        exportLocked: false,
        createdAt: DateTime.now(),
      );

      final exported = RtpConfigEngine.exportRtp(unlockedProfile);
      expect(exported, contains('"name": "Public Config"'));
      expect(exported, contains('"signature":'));
    });

    test('Parses raw OpenVPN (.ovpn) configuration file', () {
      const ovpnData = '''
# OpenVPN Config
client
dev tun
proto tcp
remote 194.36.144.50 443
resolv-retry infinite
nobind
persist-key
persist-tun
verb 3
''';

      final profile = RtpConfigEngine.parseOvpn(ovpnData, defaultName: 'Amsterdam TCP');

      expect(profile.name, 'Amsterdam TCP');
      expect(profile.protocol, 'ovpn');
      expect(profile.serverAddress, '194.36.144.50');
      expect(profile.serverPort, 443);
      expect(profile.transport, 'tcp');
      expect(profile.rawPayload, ovpnData);
    });

    test('Parses proxy URIs (vless://)', () {
      const vlessUri = 'vless://uuid-1234@server.example.com:443?type=ws&security=tls&sni=sni.example.com#VIP-VLESS';

      final profile = RtpConfigEngine.parseProxyUri(vlessUri);

      expect(profile.name, 'VIP-VLESS');
      expect(profile.protocol, 'vless');
      expect(profile.serverAddress, 'server.example.com');
      expect(profile.serverPort, 443);
      expect(profile.transport, 'ws');
      expect(profile.sni, 'sni.example.com');
    });

    test('Parses WireGuard (.conf) configuration file correctly', () {
      const wgConf = '''
[Interface]
PrivateKey = aGZsd2pzb2RmamtzZGtmanNka2Zqc2RramZzZGtqZnM=
Address = 10.0.0.5/32
DNS = 1.1.1.1, 8.8.8.8
MTU = 1420

[Peer]
PublicKey = cGtqZnNka2pmc2RramZzZGtmc2RramZzZGtmamtkc2Y=
Endpoint = 195.201.10.25:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
''';

      final profile = RtpConfigEngine.parseWireGuard(wgConf, defaultName: 'Zurich WG Fast');

      expect(profile.name, 'Zurich WG Fast');
      expect(profile.protocol, 'wireguard');
      expect(profile.serverAddress, '195.201.10.25');
      expect(profile.serverPort, 51820);
      expect(profile.transport, 'udp');
      expect(profile.credentials['privateKey'], 'aGZsd2pzb2RmamtzZGtmanNka2Zqc2RramZzZGtqZnM=');
      expect(profile.credentials['address'], '10.0.0.5/32');
      expect(profile.credentials['mtu'], 1420);
      expect(profile.credentials['persistentKeepalive'], 25);
      expect(profile.dnsServers, contains('1.1.1.1'));
    });

    test('Parses SSH Tunnel configuration and custom HTTP injection headers', () {
      const sshConf = '''
[SSH]
host = 156.204.18.22
port = 22
username = ramez_vip
password = secret_cairo_pass
sni = m.we.com.eg
payload = CONNECT [host_port] [protocol][crlf]Host: m.we.com.eg[crlf][crlf]
''';

      final profile = RtpConfigEngine.parseSsh(sshConf, defaultName: 'Cairo SSH Bug Host');

      expect(profile.name, 'Cairo SSH Bug Host');
      expect(profile.protocol, 'ssh');
      expect(profile.serverAddress, '156.204.18.22');
      expect(profile.serverPort, 22);
      expect(profile.transport, 'tcp');
      expect(profile.credentials['username'], 'ramez_vip');
      expect(profile.credentials['password'], 'secret_cairo_pass');
      expect(profile.sni, 'm.we.com.eg');
      expect(profile.credentials['payload'], contains('CONNECT'));
    });

    test('Parses SSH URI format (ssh://user:pass@host:port)', () {
      const sshUri = 'ssh://dev_user:secure123@ssh.rameztunnel.com:443?sni=fast.cdn.com';

      final profile = RtpConfigEngine.parseSsh(sshUri);

      expect(profile.protocol, 'ssh');
      expect(profile.serverAddress, 'ssh.rameztunnel.com');
      expect(profile.serverPort, 443);
      expect(profile.credentials['username'], 'dev_user');
      expect(profile.credentials['password'], 'secure123');
      expect(profile.sni, 'fast.cdn.com');
    });

    test('parseAny automatically distinguishes between JSON, URI, WireGuard, SSH, and OVPN', () {
      final fromJson = RtpConfigEngine.parseAny(sampleRtpJson);
      expect(fromJson.name, 'Frankfurt VIP RTP');

      final fromUri = RtpConfigEngine.parseAny('vless://u@host.com:8080#Test');
      expect(fromUri.protocol, 'vless');

      final fromWg = RtpConfigEngine.parseAny('[Interface]\nPrivateKey=xyz=\n[Peer]\nPublicKey=abc=\nEndpoint=1.1.1.1:51820');
      expect(fromWg.protocol, 'wireguard');

      final fromSsh = RtpConfigEngine.parseAny('ssh://admin:pass@10.0.0.1:22');
      expect(fromSsh.protocol, 'ssh');

      final fromOvpn = RtpConfigEngine.parseAny('client\nremote 5.5.5.5 1194');
      expect(fromOvpn.serverAddress, '5.5.5.5');
    });

    test('Enforces anti-DoS size limits (>1MB)', () {
      final oversizedString = 'A' * (1024 * 1024 + 10);
      expect(
        () => RtpConfigEngine.parseAny(oversizedString),
        throwsA(isA<ConfigParsingFailure>()),
      );
    });
  });
}
