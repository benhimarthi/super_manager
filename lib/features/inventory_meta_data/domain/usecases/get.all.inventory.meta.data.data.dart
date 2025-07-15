import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/inventory.meta.data.dart';
import '../repositories/inventory.meta.data.repository.dart';

class GetAllInventoryMetadata
    implements UseCaseWithoutParams<List<InventoryMetadata>> {
  final InventoryMetadataRepository _repo;

  GetAllInventoryMetadata(this._repo);

  @override
  ResultFuture<List<InventoryMetadata>> call() {
    return _repo.getAllMetadata();
  }
}
