import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/announcement_entity.dart';
import '../entities/notification_preferences.dart';

abstract class INotificationRepository {
  Future<Either<Failure, NotificationPreferences>> getPreferences();
  Future<Either<Failure, NotificationPreferences>> updatePreferences(NotificationPreferences preferences);
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements();
}
