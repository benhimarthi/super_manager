import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/inventory.meta.data.dart';
import '../repositories/inventory.meta.data.repository.dart';

class UpdateInventoryMetadata
    implements UsecaseWithParams<void, InventoryMetadata> {
  final InventoryMetadataRepository _repo;

  UpdateInventoryMetadata(this._repo);

  @override
  ResultFuture<void> call(InventoryMetadata params) {
    return _repo.updateMetadata(params);
  }
}
