import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/inventory.meta.data.dart';
import '../repositories/inventory.meta.data.repository.dart';

class CreateInventoryMetadata
    implements UsecaseWithParams<void, InventoryMetadata> {
  final InventoryMetadataRepository _repo;

  CreateInventoryMetadata(this._repo);

  @override
  ResultFuture<void> call(InventoryMetadata params) {
    return _repo.createMetadata(params);
  }
}
