import '../../../../core/util/typedef.dart';
import '../entities/inventory.dart';

abstract class InventoryRepository {
  ResultFuture<void> createInventory(Inventory inventory);
  ResultFuture<List<Inventory>> getAllInventory();
  ResultFuture<Inventory> getInventoryById(String id);
  ResultFuture<void> updateInventory(Inventory inventory);
  ResultFuture<void> deleteInventory(String id);
}
