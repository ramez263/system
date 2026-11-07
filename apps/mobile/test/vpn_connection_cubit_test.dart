import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tunnel_plus/core/vpn/vpn_bridge.g.dart';
import 'package:tunnel_plus/core/vpn/vpn_service.dart';
import 'package:tunnel_plus/core/widgets/ramez_status_chip.dart';
import 'package:tunnel_plus/features/configurations/domain/entities/configuration_entity.dart';
import 'package:tunnel_plus/features/servers/domain/entities/server_entity.dart';
import 'package:tunnel_plus/features/servers/domain/repositories/server_repository.dart';
import 'package:tunnel_plus/features/statistics/domain/entities/session_record.dart';
import 'package:tunnel_plus/features/statistics/domain/repositories/telemetry_repository.dart';
import 'package:tunnel_plus/features/vpn_connection/presentation/cubit/vpn_connection_cubit.dart';

class MockVpnService extends Mock implements IVpnService {}
class MockServerRepository extends Mock implements IServerRepository {}
class MockTelemetryRepository extends Mock implements ITelemetryRepository {}
class FakeVpnProfilePayload extends Fake implements VpnProfilePayload {}
class FakeSessionRecord extends Fake implements SessionRecord {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockVpnService mockVpnService;
  late MockServerRepository mockServerRepository;
  late MockTelemetryRepository mockTelemetryRepository;

  late StreamController<TunnelState> statusController;
  late StreamController<VpnStatsPayload> statsController;
  late VpnConnectionCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeVpnProfilePayload());
    registerFallbackValue(FakeSessionRecord());
  });

  setUp(() {
    mockVpnService = MockVpnService();
    mockServerRepository = MockServerRepository();
    mockTelemetryRepository = MockTelemetryRepository();

    statusController = StreamController<TunnelState>.broadcast();
    statsController = StreamController<VpnStatsPayload>.broadcast();

    when(() => mockVpnService.statusStream).thenAnswer((_) => statusController.stream);
    when(() => mockVpnService.statsStream).thenAnswer((_) => statsController.stream);
    when(() => mockVpnService.getStatus()).thenAnswer(
      (_) async => VpnStatusPayload(state: 'disconnected'),
    );

    cubit = VpnConnectionCubit(
      vpnService: mockVpnService,
      serverRepository: mockServerRepository,
      telemetryRepository: mockTelemetryRepository,
    );
  });

  tearDown(() {
    cubit.close();
    statusController.close();
    statsController.close();
  });

  group('VpnConnectionCubit Lifecycle & State Management', () {
    test('Initial state is disconnected with zero counters', () {
      expect(cubit.state.status, equals(TunnelState.disconnected));
      expect(cubit.state.durationSeconds, equals(0));
      expect(cubit.state.bytesIn, equals(0));
      expect(cubit.state.bytesOut, equals(0));
      expect(cubit.state.isConnected, isFalse);
      expect(cubit.state.isConnecting, isFalse);
    });

    test('selectServer updates selectedServer and resets selectedConfig', () {
      const server = ServerEntity(
        id: 1,
        name: 'Frankfurt 01',
        countryCode: 'DE',
        countryName: 'Germany',
        flagEmoji: '🇩🇪',
        protocol: 'ovpn',
        ipAddress: '185.220.101.5',
        port: 1194,
        pingMs: 25,
        currentLoad: 20,
        isPremium: false,
        hasOvpn: true,
      );

      cubit.selectServer(server);

      expect(cubit.state.selectedServer, equals(server));
      expect(cubit.state.selectedConfig, isNull);
    });

    test('selectConfig updates selectedConfig and resets selectedServer', () {
      final config = ConfigurationEntity(
        id: 5,
        name: 'Orange Flex',
        protocol: 'ovpn',
        serverAddress: '185.220.101.5',
        serverPort: 1194,
        rawConfig: 'client\nproto udp\n',
        createdAt: DateTime.now(),
      );

      cubit.selectConfig(config);

      expect(cubit.state.selectedConfig, equals(config));
      expect(cubit.state.selectedServer, isNull);
    });

    test('Status stream updates emit new cubit state', () async {
      statusController.add(TunnelState.connecting);
      await pumpEventQueue();
      expect(cubit.state.status, equals(TunnelState.connecting));
      expect(cubit.state.isConnecting, isTrue);

      statusController.add(TunnelState.connected);
      await pumpEventQueue();
      expect(cubit.state.status, equals(TunnelState.connected));
      expect(cubit.state.isConnected, isTrue);
      expect(cubit.state.connectedAt, isNotNull);
    });

    test('Stats stream updates traffic metrics when connected', () async {
      statusController.add(TunnelState.connected);
      await pumpEventQueue();

      final stats = VpnStatsPayload(
        bytesIn: 1048576, // 1 MB
        bytesOut: 524288,  // 0.5 MB
        downloadSpeedBps: 2000000,
        uploadSpeedBps: 1000000,
        durationSeconds: 45,
      );

      statsController.add(stats);
      await pumpEventQueue();

      expect(cubit.state.bytesIn, equals(1048576));
      expect(cubit.state.bytesOut, equals(524288));
      expect(cubit.state.downloadSpeedBps, equals(2000000));
      expect(cubit.state.uploadSpeedBps, equals(1000000));
      expect(cubit.state.durationSeconds, equals(45));
      expect(cubit.state.formattedDuration, equals('00:45'));
    });

    test('connect() requests prepare and calls vpnService.connect', () async {
      when(() => mockVpnService.prepare()).thenAnswer((_) async => true);
      when(() => mockVpnService.connect(any())).thenAnswer((_) async => true);

      await cubit.connect();

      verify(() => mockVpnService.prepare()).called(1);
      verify(() => mockVpnService.connect(any())).called(1);
      expect(cubit.state.connectedServerName, isNotNull);
    });

    test('connect() fails if permission prepare is denied', () async {
      when(() => mockVpnService.prepare()).thenAnswer((_) async => false);

      await cubit.connect();

      verify(() => mockVpnService.prepare()).called(1);
      verifyNever(() => mockVpnService.connect(any()));
      expect(cubit.state.status, equals(TunnelState.failed));
      expect(cubit.state.errorMessage, contains('permission denied'));
    });

    test('disconnect() calls vpnService.disconnect and records telemetry', () async {
      when(() => mockVpnService.prepare()).thenAnswer((_) async => true);
      when(() => mockVpnService.connect(any())).thenAnswer((_) async => true);
      when(() => mockVpnService.disconnect()).thenAnswer((_) async => true);
      when(() => mockTelemetryRepository.recordSession(any())).thenAnswer(
        (_) async => const Right(null),
      );

      // Connect first
      await cubit.connect();
      statusController.add(TunnelState.connected);
      await pumpEventQueue();

      // Disconnect
      await cubit.disconnect();

      verify(() => mockVpnService.disconnect()).called(1);
      verify(() => mockTelemetryRepository.recordSession(any())).called(1);
      expect(cubit.state.status, equals(TunnelState.disconnected));
      expect(cubit.state.durationSeconds, equals(0));
    });
  });
}
