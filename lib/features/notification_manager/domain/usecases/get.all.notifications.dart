import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/notification.dart';
import '../repositories/notification.repository.dart';

class GetAllNotifications implements UseCaseWithoutParams<List<Notifications>> {
  final NotificationRepository _repo;
  GetAllNotifications(this._repo);

  @override
  ResultFuture<List<Notifications>> call() => _repo.getAllNotifications();
}
