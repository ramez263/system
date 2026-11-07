import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final INotificationRepository _repository;

  NotificationCubit({required INotificationRepository repository})
      : _repository = repository,
        super(NotificationInitial());

  Future<void> loadNotifications() async {
    emit(NotificationLoading());

    final prefsResult = await _repository.getPreferences();
    final announcementsResult = await _repository.getAnnouncements();

    final prefs = prefsResult.fold((_) => const NotificationPreferences(), (p) => p);
    final announcements = announcementsResult.fold((_) => <AnnouncementEntity>[], (a) => a);

    emit(NotificationLoaded(
      preferences: prefs,
      announcements: announcements,
      permissionGranted: true,
    ));
  }

  Future<void> togglePreference({
    bool? notifyConnection,
    bool? notifyDisconnection,
    bool? notifyServerFailure,
    bool? notifySubscriptionExpiry,
    bool? notifySecurityAlerts,
    bool? notifyUpdates,
    bool? notifyPromotions,
  }) async {
    if (state is! NotificationLoaded) return;
    final current = state as NotificationLoaded;

    final updatedPrefs = current.preferences.copyWith(
      notifyConnection: notifyConnection,
      notifyDisconnection: notifyDisconnection,
      notifyServerFailure: notifyServerFailure,
      notifySubscriptionExpiry: notifySubscriptionExpiry,
      notifySecurityAlerts: notifySecurityAlerts,
      notifyUpdates: notifyUpdates,
      notifyPromotions: notifyPromotions,
    );

    emit(current.copyWith(preferences: updatedPrefs));
    await _repository.updatePreferences(updatedPrefs);
  }

  void grantPermission(bool granted) {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      emit(current.copyWith(permissionGranted: granted));
    }
  }
}
