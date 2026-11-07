import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tunnel_plus/core/errors/failures.dart';
import 'package:tunnel_plus/features/servers/domain/entities/server_entity.dart';
import 'package:tunnel_plus/features/servers/domain/repositories/server_repository.dart';
import 'package:tunnel_plus/features/servers/presentation/cubit/server_list_cubit.dart';

class MockServerRepository extends Mock implements IServerRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockServerRepository mockRepo;
  late ServerListCubit cubit;

  final sampleServers = [
    const ServerEntity(
      id: 1,
      name: 'Frankfurt Fast 01',
      countryCode: 'DE',
      countryName: 'Germany',
      city: 'Frankfurt',
      flagEmoji: '🇩🇪',
      protocol: 'ovpn',
      ipAddress: '185.120.40.12',
      port: 1194,
      pingMs: 24,
      currentLoad: 40,
      isPremium: false,
    ),
    const ServerEntity(
      id: 2,
      name: 'Amsterdam Ultra 01',
      countryCode: 'NL',
      countryName: 'Netherlands',
      city: 'Amsterdam',
      flagEmoji: '🇳🇱',
      protocol: 'ovpn',
      ipAddress: '194.36.144.50',
      port: 1194,
      pingMs: 35,
      currentLoad: 15,
      isPremium: false,
    ),
    const ServerEntity(
      id: 3,
      name: 'New York East 01',
      countryCode: 'US',
      countryName: 'United States',
      city: 'New York',
      flagEmoji: '🇺🇸',
      protocol: 'ovpn',
      ipAddress: '198.51.100.88',
      port: 1194,
      pingMs: 90,
      currentLoad: 20,
      isPremium: false,
    ),
  ];

  setUp(() {
    mockRepo = MockServerRepository();
    cubit = ServerListCubit(mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('ServerListCubit Lifecycle & Filtering', () {
    test('Initial state is ServerListInitial', () {
      expect(cubit.state, isA<ServerListInitial>());
    });

    test('loadServers fetches catalog and emits ServerListLoaded sorted by ping', () async {
      when(() => mockRepo.getServers()).thenAnswer((_) async => Right(sampleServers));

      await cubit.loadServers();

      expect(cubit.state, isA<ServerListLoaded>());
      final loaded = cubit.state as ServerListLoaded;
      expect(loaded.servers.length, equals(3));
      expect(loaded.filteredServers.length, equals(3));
      expect(loaded.selectedServer?.name, equals('Frankfurt Fast 01'));
      expect(loaded.sortOption, equals(ServerSortOption.ping));
    });

    test('filterByCountry filters list by ISO code', () async {
      when(() => mockRepo.getServers()).thenAnswer((_) async => Right(sampleServers));

      await cubit.loadServers();
      cubit.filterByCountry('NL');

      final loaded = cubit.state as ServerListLoaded;
      expect(loaded.filteredServers.length, equals(1));
      expect(loaded.filteredServers.first.countryCode, equals('NL'));
    });

    test('search filters servers by text across name, country, and city', () async {
      when(() => mockRepo.getServers()).thenAnswer((_) async => Right(sampleServers));

      await cubit.loadServers();
      cubit.search('York');

      final loaded = cubit.state as ServerListLoaded;
      expect(loaded.filteredServers.length, equals(1));
      expect(loaded.filteredServers.first.name, equals('New York East 01'));
    });

    test('changeSort sorts servers by load or alphabetical', () async {
      when(() => mockRepo.getServers()).thenAnswer((_) async => Right(sampleServers));

      await cubit.loadServers();

      // Sort by load (Amsterdam has lowest load: 15%)
      cubit.changeSort(ServerSortOption.load);
      var loaded = cubit.state as ServerListLoaded;
      expect(loaded.filteredServers.first.name, equals('Amsterdam Ultra 01'));

      // Sort by name (Amsterdam -> Frankfurt -> New York)
      cubit.changeSort(ServerSortOption.name);
      loaded = cubit.state as ServerListLoaded;
      expect(loaded.filteredServers.first.name, equals('Amsterdam Ultra 01'));
      expect(loaded.filteredServers.last.name, equals('New York East 01'));
    });

    test('autoSelectBestServer scores by weighted ping and load', () async {
      when(() => mockRepo.getServers()).thenAnswer((_) async => Right(sampleServers));

      await cubit.loadServers();
      cubit.autoSelectBestServer();

      final loaded = cubit.state as ServerListLoaded;
      // Frankfurt: (24 * 0.7) + (40 * 0.3) = 16.8 + 12 = 28.8
      // Amsterdam: (35 * 0.7) + (15 * 0.3) = 24.5 + 4.5 = 29.0
      // Frankfurt is best!
      expect(loaded.selectedServer?.name, equals('Frankfurt Fast 01'));
    });

    test('loadServers emits ServerListError on failure', () async {
      when(() => mockRepo.getServers()).thenAnswer(
        (_) async => const Left(ServerFailure('Catalog unavailable')),
      );

      await cubit.loadServers();

      expect(cubit.state, isA<ServerListError>());
      final error = cubit.state as ServerListError;
      expect(error.message, equals('Catalog unavailable'));
    });
  });
}
