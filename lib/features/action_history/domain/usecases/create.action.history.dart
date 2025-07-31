import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/action.history.dart';
import '../repositories/action.history.repository.dart';

class CreateActionHistory implements UsecaseWithParams<void, ActionHistory> {
  final ActionHistoryRepository _repo;
  CreateActionHistory(this._repo);

  @override
  ResultFuture<void> call(ActionHistory params) => _repo.createAction(params);
}