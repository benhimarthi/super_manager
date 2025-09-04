import '../../../../core/util/typedef.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  ResultFuture<void> createNotification(Notifications notification);
  ResultFuture<List<Notifications>> getAllNotifications();
  ResultFuture<Notifications> getNotificationById(String id);
  ResultFuture<void> updateNotification(Notifications notification);
  ResultFuture<void> deleteNotification(String id);
}
