import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/action.history.dart';
import '../repositories/action.history.repository.dart';

class GetActionHistoryById
    implements UsecaseWithParams<ActionHistory, Map<String, dynamic>> {
  final ActionHistoryRepository _repo;
  GetActionHistoryById(this._repo);

  @override
  ResultFuture<ActionHistory> call(Map<String, dynamic> params) =>
      _repo.getActionById(params['entityId'], params['timestamp']);
}
