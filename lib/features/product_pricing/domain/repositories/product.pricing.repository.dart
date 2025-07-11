import '../../../../core/util/typedef.dart';
import '../entities/product.pricing.dart';

abstract class ProductPricingRepository {
  ResultFuture<void> createPricing(ProductPricing pricing);
  ResultFuture<List<ProductPricing>> getAllPricing();
  ResultFuture<ProductPricing> getPricingById(String id);
  ResultFuture<void> updatePricing(ProductPricing pricing);
  ResultFuture<void> deletePricing(String id);
}
