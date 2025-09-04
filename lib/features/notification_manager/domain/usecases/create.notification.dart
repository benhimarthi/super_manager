import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/notification.dart';
import '../repositories/notification.repository.dart';

class CreateNotification implements UsecaseWithParams<void, Notifications> {
  final NotificationRepository _repo;
  CreateNotification(this._repo);

  @override
  ResultFuture<void> call(Notifications params) =>
      _repo.createNotification(params);
}
