import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/notification.repository.dart';

class DeleteNotification implements UsecaseWithParams<void, String> {
  final NotificationRepository _repo;
  DeleteNotification(this._repo);

  @override
  ResultFuture<void> call(String id) => _repo.deleteNotification(id);
}
