import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/inventory.meta.data.dart';
import '../repositories/inventory.meta.data.repository.dart';

class GetInventoryMetadataById
    implements UsecaseWithParams<InventoryMetadata, String> {
  final InventoryMetadataRepository _repo;

  GetInventoryMetadataById(this._repo);

  @override
  ResultFuture<InventoryMetadata> call(String id) {
    return _repo.getMetadataById(id);
  }
}
