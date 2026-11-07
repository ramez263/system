import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tunnel_plus/core/vpn/vpn_bridge.g.dart';
import 'package:tunnel_plus/core/vpn/vpn_service.dart';

class MockVpnHostApi extends Mock implements VpnHostApi {}
class FakeVpnProfilePayload extends Fake implements VpnProfilePayload {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockVpnHostApi mockHostApi;
  late VpnService vpnService;

  setUpAll(() {
    registerFallbackValue(FakeVpnProfilePayload());
  });

  setUp(() {
    mockHostApi = MockVpnHostApi();
    vpnService = VpnService(hostApi: mockHostApi);
  });

  tearDown(() {
    vpnService.dispose();
  });

  group('VpnService Method Delegation', () {
    test('prepare delegates to VpnHostApi.prepare', () async {
      when(() => mockHostApi.prepare()).thenAnswer((_) async => true);

      final result = await vpnService.prepare();

      expect(result, isTrue);
      verify(() => mockHostApi.prepare()).called(1);
    });

    test('connect delegates to VpnHostApi.connect with profile payload', () async {
      final profile = VpnProfilePayload(
        id: '1',
        name: 'Frankfurt 01',
        protocol: 'ovpn',
        serverAddress: '185.220.101.5',
        serverPort: 1194,
        rawPayload: 'client\ndev tun\n',
        dnsServers: ['1.1.1.1'],
        bypassLan: true,
        excludedApps: [],
      );

      when(() => mockHostApi.connect(any())).thenAnswer((_) async => true);

      final result = await vpnService.connect(profile);

      expect(result, isTrue);
      verify(() => mockHostApi.connect(profile)).called(1);
    });

    test('disconnect delegates to VpnHostApi.disconnect', () async {
      when(() => mockHostApi.disconnect()).thenAnswer((_) async => true);

      final result = await vpnService.disconnect();

      expect(result, isTrue);
      verify(() => mockHostApi.disconnect()).called(1);
    });

    test('getStatus delegates to VpnHostApi.getStatus', () async {
      final mockStatus = VpnStatusPayload(
        state: 'connected',
        connectedServerName: 'Frankfurt 01',
      );

      when(() => mockHostApi.getStatus()).thenAnswer((_) async => mockStatus);

      final result = await vpnService.getStatus();

      expect(result.state, equals('connected'));
      expect(result.connectedServerName, equals('Frankfurt 01'));
      verify(() => mockHostApi.getStatus()).called(1);
    });

    test('connect delegates to VpnHostApi.connect with WireGuard profile payload', () async {
      final wgProfile = VpnProfilePayload(
        id: 'wg-1',
        name: 'Zurich Fast WG',
        protocol: 'wireguard',
        serverAddress: '195.201.10.25',
        serverPort: 51820,
        rawPayload: '[Interface]\nPrivateKey=abc=\n[Peer]\nPublicKey=xyz=\nEndpoint=195.201.10.25:51820',
        dnsServers: ['1.1.1.1', '1.0.0.1'],
        bypassLan: true,
        excludedApps: [],
      );

      when(() => mockHostApi.connect(any())).thenAnswer((_) async => true);

      final result = await vpnService.connect(wgProfile);

      expect(result, isTrue);
      verify(() => mockHostApi.connect(wgProfile)).called(1);
    });

    test('connect delegates to VpnHostApi.connect with SSH profile payload', () async {
      final sshProfile = VpnProfilePayload(
        id: 'ssh-1',
        name: 'Cairo SSH Bug Host',
        protocol: 'ssh',
        serverAddress: '156.204.18.22',
        serverPort: 22,
        rawPayload: 'ssh://user:pass@156.204.18.22:22?sni=m.we.com.eg',
        dnsServers: ['8.8.8.8'],
        bypassLan: false,
        excludedApps: ['com.android.chrome'],
      );

      when(() => mockHostApi.connect(any())).thenAnswer((_) async => true);

      final result = await vpnService.connect(sshProfile);

      expect(result, isTrue);
      verify(() => mockHostApi.connect(sshProfile)).called(1);
    });

    test('listEngines delegates to VpnHostApi.listEngines with all 4 registered engines', () async {
      final mockEngines = [
        VpnEngineInfo(
          id: 'openvpn_native_core',
          name: 'OpenVPN High-Speed Engine',
          supportedProtocols: ['ovpn', 'openvpn'],
          version: '2.6.9',
        ),
        VpnEngineInfo(
          id: 'wireguard_native_core',
          name: 'WireGuard Modern Tunnel Engine',
          supportedProtocols: ['wireguard', 'wg'],
          version: '1.0.2024',
        ),
        VpnEngineInfo(
          id: 'ssh_tunnel_core',
          name: 'SSH Secure Shell & Injector Engine',
          supportedProtocols: ['ssh', 'direct_ssh', 'ssl_ssh'],
          version: '0.9.2',
        ),
        VpnEngineInfo(
          id: 'sing_box_core',
          name: 'sing-box Multi-Protocol Engine',
          supportedProtocols: ['vless', 'vmess', 'trojan', 'shadowsocks', 'hy2'],
          version: '1.10.4',
        ),
      ];

      when(() => mockHostApi.listEngines()).thenAnswer((_) async => mockEngines);

      final result = await vpnService.listEngines();

      expect(result.length, equals(4));
      expect(result[0].id, equals('openvpn_native_core'));
      expect(result[1].id, equals('wireguard_native_core'));
      expect(result[2].id, equals('ssh_tunnel_core'));
      expect(result[3].id, equals('sing_box_core'));
      verify(() => mockHostApi.listEngines()).called(1);
    });
  });
}
