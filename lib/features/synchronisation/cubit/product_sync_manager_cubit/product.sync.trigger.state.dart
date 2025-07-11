import 'package:equatable/equatable.dart';

abstract class ProductSyncTriggerState extends Equatable {
  const ProductSyncTriggerState();

  @override
  List<Object?> get props => [];
}

class ProductSyncIdle extends ProductSyncTriggerState {}

class ProductSyncInProgress extends ProductSyncTriggerState {}

class ProductSyncSuccess extends ProductSyncTriggerState {}

class ProductSyncFailure extends ProductSyncTriggerState {
  final String message;
  const ProductSyncFailure(this.message);

  @override
  List<Object?> get props => [message];
}
