import 'package:flutter_bloc/flutter_bloc.dart';

import '../../synchronisation_manager/product.sync.manager.dart';
import 'product.sync.trigger.state.dart';

class ProductSyncTriggerCubit extends Cubit<ProductSyncTriggerState> {
  final ProductSyncManager _syncManager;

  ProductSyncTriggerCubit(this._syncManager) : super(ProductSyncIdle());

  Future<void> triggerManualSync() async {
    try {
      emit(ProductSyncInProgress());
      await _syncManager.pushLocalChanges();
      await _syncManager.pullRemoteData();
      emit(ProductSyncSuccess());
    } catch (e) {
      emit(ProductSyncFailure(e.toString()));
    }
  }

  Future<void> refreshFromRemote() async {
    try {
      emit(ProductSyncInProgress());
      await _syncManager.refreshFromRemote();
      emit(ProductSyncSuccess());
    } catch (e) {
      emit(ProductSyncFailure(e.toString()));
    }
  }
}
