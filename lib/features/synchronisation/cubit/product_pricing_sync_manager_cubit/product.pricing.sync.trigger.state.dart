import 'package:equatable/equatable.dart';

abstract class ProductPricingSyncTriggerState extends Equatable {
  const ProductPricingSyncTriggerState();

  @override
  List<Object?> get props => [];
}

class SyncIdle extends ProductPricingSyncTriggerState {}

class SyncInProgress extends ProductPricingSyncTriggerState {}

class SyncSuccess extends ProductPricingSyncTriggerState {}

class SyncFailure extends ProductPricingSyncTriggerState {
  final String message;

  const SyncFailure(this.message);

  @override
  List<Object?> get props => [message];
}
