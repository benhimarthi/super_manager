import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductManagerLoading extends ProductState {}

class ProductManagerLoaded extends ProductState {
  final List<Product> products;

  const ProductManagerLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class GetProductByIdSuccessfully extends ProductState {
  final Product product;

  const GetProductByIdSuccessfully(this.product);
}

class ProductManagerError extends ProductState {
  final String message;

  const ProductManagerError(this.message);

  @override
  List<Object?> get props => [message];
}
