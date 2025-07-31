import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/action.history.repository.dart';

class DeleteActionHistory
    implements UsecaseWithParams<void, Map<String, dynamic>> {
  final ActionHistoryRepository _repo;
  DeleteActionHistory(this._repo);

  @override
  ResultFuture<void> call(Map<String, dynamic> params) =>
      _repo.deleteAction(params['entityId'], params['timestamp']);
}
