import '../../../../core/util/typedef.dart';
import '../entities/sale.dart';

abstract class SaleRepository {
  ResultFuture<void> createSale(Sale sale);
  ResultFuture<List<Sale>> getAllSales();
  ResultFuture<Sale> getSaleById(String id);
  ResultFuture<void> updateSale(Sale sale);
  ResultFuture<void> deleteSale(String id);
}
