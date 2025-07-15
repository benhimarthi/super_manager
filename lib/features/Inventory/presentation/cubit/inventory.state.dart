import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object> get props => [];
}

class InventoryManagerInitial extends InventoryState {}

class InventoryManagerLoading extends InventoryState {}

class InventoryManagerLoaded extends InventoryState {
  final List<Inventory> inventoryList;

  const InventoryManagerLoaded(this.inventoryList);

  @override
  List<Object> get props => [inventoryList];
}

class InventoryManagerError extends InventoryState {
  final String message;

  const InventoryManagerError(this.message);

  @override
  List<Object> get props => [message];
}
