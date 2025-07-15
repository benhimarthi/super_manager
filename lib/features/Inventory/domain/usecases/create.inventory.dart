import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/inventory.dart';
import '../repositories/inventory.repository.dart';

class CreateInventory implements UsecaseWithParams<void, Inventory> {
  final InventoryRepository _repo;

  CreateInventory(this._repo);

  @override
  ResultFuture<void> call(Inventory params) {
    return _repo.createInventory(params);
  }
}
