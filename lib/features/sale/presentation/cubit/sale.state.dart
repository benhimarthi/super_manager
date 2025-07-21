import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.dart';

abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object> get props => [];
}

class SaleManagerInitial extends SaleState {}

class SaleManagerLoading extends SaleState {}

class SaleManagerLoaded extends SaleState {
  final List<Sale> saleList;

  const SaleManagerLoaded(this.saleList);

  @override
  List<Object> get props => [saleList];
}

class SaleManagerError extends SaleState {
  final String message;

  const SaleManagerError(this.message);

  @override
  List<Object> get props => [message];
}
