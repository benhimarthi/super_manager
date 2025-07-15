import '../../../../core/util/typedef.dart';
import '../entities/inventory.meta.data.dart';

abstract class InventoryMetadataRepository {
  ResultFuture<void> createMetadata(InventoryMetadata metadata);
  ResultFuture<List<InventoryMetadata>> getAllMetadata();
  ResultFuture<InventoryMetadata> getMetadataById(String id);
  ResultFuture<void> updateMetadata(InventoryMetadata metadata);
  ResultFuture<void> deleteMetadata(String id);
}
