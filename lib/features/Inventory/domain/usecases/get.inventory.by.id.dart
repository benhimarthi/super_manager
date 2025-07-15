import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/inventory.dart';
import '../repositories/inventory.repository.dart';

class GetInventoryById implements UsecaseWithParams<Inventory, String> {
  final InventoryRepository _repo;

  GetInventoryById(this._repo);

  @override
  ResultFuture<Inventory> call(String id) {
    return _repo.getInventoryById(id);
  }
}
