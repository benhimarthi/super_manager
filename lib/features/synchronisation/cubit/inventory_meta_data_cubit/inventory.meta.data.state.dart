import 'package:equatable/equatable.dart';
import '../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';

abstract class InventoryMetadataState extends Equatable {
  const InventoryMetadataState();

  @override
  List<Object> get props => [];
}

class InventoryMetadataManagerInitial extends InventoryMetadataState {}

class InventoryMetadataManagerLoading extends InventoryMetadataState {}

class InventoryMetadataManagerLoaded extends InventoryMetadataState {
  final List<InventoryMetadata> metadataList;

  const InventoryMetadataManagerLoaded(this.metadataList);

  @override
  List<Object> get props => [metadataList];
}

class InventoryMetadataManagerError extends InventoryMetadataState {
  final String message;

  const InventoryMetadataManagerError(this.message);

  @override
  List<Object> get props => [message];
}
