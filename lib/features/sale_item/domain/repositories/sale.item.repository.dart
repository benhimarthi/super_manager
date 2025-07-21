import '../../../../core/util/typedef.dart';
import '../entities/sale.item.dart';

abstract class SaleItemRepository {
  ResultFuture<void> createSaleItem(SaleItem item);
  ResultFuture<List<SaleItem>> getSaleItemsBySaleId(String saleId);
  ResultFuture<SaleItem> getSaleItemById(String id);
  ResultFuture<void> updateSaleItem(SaleItem item);
  ResultFuture<void> deleteSaleItem(String id);
}
