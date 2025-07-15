import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/inventory.dart';
import '../repositories/inventory.repository.dart';

class GetAllInventory implements UseCaseWithoutParams<List<Inventory>> {
  final InventoryRepository _repo;

  GetAllInventory(this._repo);

  @override
  ResultFuture<List<Inventory>> call() {
    return _repo.getAllInventory();
  }
}
