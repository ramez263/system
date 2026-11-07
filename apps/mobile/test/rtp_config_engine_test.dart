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

    test('parseAny automatically distinguishes between JSON, URI, and OVPN', () {
      final fromJson = RtpConfigEngine.parseAny(sampleRtpJson);
      expect(fromJson.name, 'Frankfurt VIP RTP');

      final fromUri = RtpConfigEngine.parseAny('vless://u@host.com:8080#Test');
      expect(fromUri.protocol, 'vless');

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
