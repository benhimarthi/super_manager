import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/inventory.repository.dart';

class DeleteInventory implements UsecaseWithParams<void, String> {
  final InventoryRepository _repo;

  DeleteInventory(this._repo);

  @override
  ResultFuture<void> call(String id) {
    return _repo.deleteInventory(id);
  }
}
