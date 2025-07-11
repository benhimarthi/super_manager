import 'package:equatable/equatable.dart';
import '../../domain/entities/product.category.dart';

abstract class LocalCategoryManagerState extends Equatable {
  const LocalCategoryManagerState();

  @override
  List<Object?> get props => [];
}

class LocalCategoryManagerInitial extends LocalCategoryManagerState {}

class LocalCategoryManagerLoading extends LocalCategoryManagerState {}

class LocalCategoryManagerLoaded extends LocalCategoryManagerState {
  final List<ProductCategory> categories;

  const LocalCategoryManagerLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class LocalCategoryManagerError extends LocalCategoryManagerState {
  final String message;

  const LocalCategoryManagerError(this.message);

  @override
  List<Object?> get props => [message];
}
