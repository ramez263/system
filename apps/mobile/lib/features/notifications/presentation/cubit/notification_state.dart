import 'package:equatable/equatable.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/notification_preferences.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final NotificationPreferences preferences;
  final List<AnnouncementEntity> announcements;
  final bool permissionGranted;
  final String? message;

  const NotificationLoaded({
    required this.preferences,
    this.announcements = const [],
    this.permissionGranted = true,
    this.message,
  });

  NotificationLoaded copyWith({
    NotificationPreferences? preferences,
    List<AnnouncementEntity>? announcements,
    bool? permissionGranted,
    String? message,
  }) {
    return NotificationLoaded(
      preferences: preferences ?? this.preferences,
      announcements: announcements ?? this.announcements,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      message: message,
    );
  }

  @override
  List<Object?> get props => [preferences, announcements, permissionGranted, message];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
