import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../synchronisation_manager/product.category.sync.manager.dart';
import 'product.category.sync.trigger.state.dart';

class ProductCategorySyncTriggerCubit
    extends Cubit<ProductCategorySyncTriggerState> {
  final ProductCategorySyncManager _syncManager;
  Timer? _syncTimer;
  late final StreamSubscription<ConnectivityResult> _subscription;

  ProductCategorySyncTriggerCubit(this._syncManager) : super(SyncInitial()) {
    startSyncing();
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _triggerSync();
      }
    });
  }

  void startSyncing() {
    _syncTimer?.cancel(); // avoid duplicates
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _triggerSync();
    });
    _triggerSync(); // immediate first run
  }

  Future<void> _triggerSync() async {
    emit(SyncInProgress());

    final result = await _syncManager.syncPendingChanges();
    result.fold(
      (failure) => emit(SyncFailure(failure.message)),
      (_) => emit(SyncSuccess()),
    );
  }

  void stopSyncing() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  @override
  Future<void> close() {
    stopSyncing();
    _subscription.cancel();
    return super.close();
  }

  Future<void> triggerManualSync() async {
    await _triggerSync();
  }

  Future<void> refreshFromRemote() async {
    try {
      emit(SyncInProgress());
      await _syncManager.refreshFromRemote();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }
}
