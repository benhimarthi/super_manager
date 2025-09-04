import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/notification.dart';
import '../repositories/notification.repository.dart';

class GetNotificationById implements UsecaseWithParams<Notifications, String> {
  final NotificationRepository _repo;
  GetNotificationById(this._repo);

  @override
  ResultFuture<Notifications> call(String id) => _repo.getNotificationById(id);
}
