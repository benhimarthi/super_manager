import 'package:equatable/equatable.dart';

abstract class ProductCategorySyncTriggerState extends Equatable {
  const ProductCategorySyncTriggerState();

  @override
  List<Object?> get props => [];
}

class SyncInitial extends ProductCategorySyncTriggerState {}

class SyncInProgress extends ProductCategorySyncTriggerState {}

class SyncSuccess extends ProductCategorySyncTriggerState {}

class SyncFailure extends ProductCategorySyncTriggerState {
  final String message;

  const SyncFailure(this.message);

  @override
  List<Object?> get props => [message];
}
