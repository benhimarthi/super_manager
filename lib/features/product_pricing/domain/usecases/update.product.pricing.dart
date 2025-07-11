import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/product.pricing.dart';
import '../repositories/product.pricing.repository.dart';

class UpdateProductPricing implements UsecaseWithParams<void, ProductPricing> {
  final ProductPricingRepository _repo;

  UpdateProductPricing(this._repo);

  @override
  ResultFuture<void> call(ProductPricing params) {
    return _repo.updatePricing(params);
  }
}
