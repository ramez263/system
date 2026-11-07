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

    test('listEngines delegates to VpnHostApi.listEngines', () async {
      final mockEngines = [
        VpnEngineInfo(
          id: 'openvpn',
          name: 'OpenVPN 2.6 Native',
          supportedProtocols: ['ovpn'],
          version: '2.6.9',
        ),
      ];

      when(() => mockHostApi.listEngines()).thenAnswer((_) async => mockEngines);

      final result = await vpnService.listEngines();

      expect(result.length, equals(1));
      expect(result.first.id, equals('openvpn'));
      verify(() => mockHostApi.listEngines()).called(1);
    });
  });
}
