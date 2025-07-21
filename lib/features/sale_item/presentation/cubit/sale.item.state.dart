import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.item.dart';

abstract class SaleItemState extends Equatable {
  const SaleItemState();

  @override
  List<Object> get props => [];
}

class SaleItemManagerInitial extends SaleItemState {}

class SaleItemManagerLoading extends SaleItemState {}

class SaleItemManagerLoaded extends SaleItemState {
  final List<SaleItem> saleItemList;

  const SaleItemManagerLoaded(this.saleItemList);

  @override
  List<Object> get props => [saleItemList];
}

class SaleItemManagerError extends SaleItemState {
  final String message;

  const SaleItemManagerError(this.message);

  @override
  List<Object> get props => [message];
}
