import 'package:equatable/equatable.dart';
import '../../domain/entities/product.pricing.dart';

abstract class ProductPricingState extends Equatable {
  const ProductPricingState();

  @override
  List<Object> get props => [];
}

class ProductPricingManagerInitial extends ProductPricingState {}

class ProductPricingManagerLoading extends ProductPricingState {}

class ProductPricingManagerLoaded extends ProductPricingState {
  final List<ProductPricing> pricingList;

  const ProductPricingManagerLoaded(this.pricingList);

  @override
  List<Object> get props => [pricingList];
}

class ProductPricingManagerError extends ProductPricingState {
  final String message;

  const ProductPricingManagerError(this.message);

  @override
  List<Object> get props => [message];
}
