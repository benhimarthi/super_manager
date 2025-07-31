import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/action.history.dart';
import '../repositories/action.history.repository.dart';

class GetAllActionHistory implements UseCaseWithoutParams<List<ActionHistory>> {
  final ActionHistoryRepository _repo;
  GetAllActionHistory(this._repo);

  @override
  ResultFuture<List<ActionHistory>> call() => _repo.getAllActions();
}
