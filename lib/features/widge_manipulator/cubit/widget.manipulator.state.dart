import 'package:equatable/equatable.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';

class WidgetManipulatorState extends Equatable {
  const WidgetManipulatorState();
  @override
  List<Object?> get props => [];
}

class WidgetManipulatorInitial extends WidgetManipulatorState {}

class ChangeMenuSuccessfully extends WidgetManipulatorState {
  final double position;
  final String title;
  const ChangeMenuSuccessfully(this.position, this.title);
}

class SelectingProductCategorySuccessfully extends WidgetManipulatorState {
  final String categoryName;
  final String categoryuid;

  const SelectingProductCategorySuccessfully({
    required this.categoryName,
    required this.categoryuid,
  });
}

class SelectingCurrencySuccessfully extends WidgetManipulatorState {
  final String currency;
  final String country;
  const SelectingCurrencySuccessfully(this.currency, this.country);
}

class CacheProductSuccessfully extends WidgetManipulatorState {
  final Product product;
  const CacheProductSuccessfully(this.product);
}

class ElementAddedSuccessfully extends WidgetManipulatorState {
  final String elementId;

  const ElementAddedSuccessfully(this.elementId);
}
