import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/inventory.meta.data.repository.dart';

class DeleteInventoryMetadata implements UsecaseWithParams<void, String> {
  final InventoryMetadataRepository _repo;

  DeleteInventoryMetadata(this._repo);

  @override
  ResultFuture<void> call(String id) {
    return _repo.deleteMetadata(id);
  }
}
