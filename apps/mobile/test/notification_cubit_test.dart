import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tunnel_plus/core/errors/failures.dart';
import 'package:tunnel_plus/features/notifications/domain/entities/announcement_entity.dart';
import 'package:tunnel_plus/features/notifications/domain/entities/notification_preferences.dart';
import 'package:tunnel_plus/features/notifications/domain/repositories/notification_repository.dart';
import 'package:tunnel_plus/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:tunnel_plus/features/notifications/presentation/cubit/notification_state.dart';

class MockNotificationRepository implements INotificationRepository {
  NotificationPreferences prefs = const NotificationPreferences();
  List<AnnouncementEntity> announcements = [
    const AnnouncementEntity(
      id: 1,
      title: 'Amsterdam Node Live',
      body: 'High speed 1Gbps',
      category: 'updates',
      icon: 'dns',
      time: '1h ago',
    ),
  ];

  @override
  Future<Either<Failure, NotificationPreferences>> getPreferences() async {
    return Right(prefs);
  }

  @override
  Future<Either<Failure, NotificationPreferences>> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    prefs = preferences;
    return Right(prefs);
  }

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements() async {
    return Right(announcements);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNotificationRepository repository;
  late NotificationCubit cubit;

  setUp(() {
    repository = MockNotificationRepository();
    cubit = NotificationCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  test('loadNotifications emits NotificationLoaded with preferences and announcements', () async {
    final expectedStates = [
      isA<NotificationLoading>(),
      isA<NotificationLoaded>()
          .having((s) => s.preferences.notifyConnection, 'notifyConnection', true)
          .having((s) => s.announcements.length, 'announcements length', 1),
    ];

    expectLater(cubit.stream, emitsInOrder(expectedStates));
    await cubit.loadNotifications();
  });

  test('togglePreference updates individual category switch and persists to repository', () async {
    await cubit.loadNotifications();

    await cubit.togglePreference(notifyConnection: false, notifyPromotions: true);

    expect(cubit.state, isA<NotificationLoaded>());
    final state = cubit.state as NotificationLoaded;
    expect(state.preferences.notifyConnection, false);
    expect(state.preferences.notifyPromotions, true);
    expect(repository.prefs.notifyConnection, false);
    expect(repository.prefs.notifyPromotions, true);
  });
}
