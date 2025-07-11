import 'package:flutter_bloc/flutter_bloc.dart';

import '../../synchronisation_manager/product.pricing.sync.manager.dart';
import 'product.pricing.sync.trigger.state.dart';

class ProductPricingSyncTriggerCubit
    extends Cubit<ProductPricingSyncTriggerState> {
  final ProductPricingSyncManager _sync;

  ProductPricingSyncTriggerCubit(this._sync) : super(SyncIdle());

  Future<void> triggerManualSync() async {
    try {
      emit(SyncInProgress());
      await _sync.pushLocalChanges();
      await _sync.pullRemoteData();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }

  Future<void> refreshFromRemote() async {
    try {
      emit(SyncInProgress());
      await _sync.refreshFromRemote();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }
}
