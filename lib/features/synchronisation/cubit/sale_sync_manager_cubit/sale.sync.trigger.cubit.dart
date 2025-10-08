import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../synchronisation_manager/sale.sync.manger.dart';
import 'sale.sync.trigger.state.dart';

class SaleSyncTriggerCubit extends Cubit<SaleSyncTriggerState> {
  final SaleSyncManager _syncManager;
  Timer? _syncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  SaleSyncTriggerCubit(this._syncManager) : super(const SyncInitial()) {
    _syncManager.initialize();
    startSyncing();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
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
    emit(const SyncInProgress());
    try {
      await _syncManager.pushLocalChanges();
      emit(const SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }

  Future<void> triggerManualSync() async {
    try {
      emit(const SyncInProgress());
      await _syncManager.pushLocalChanges();
      await _syncManager.pullRemoteData();
      emit(const SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }

  Future<void> refreshFromRemote() async {
    try {
      emit(const SyncInProgress());
      await _syncManager.refreshFromRemote();
      emit(const SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }

  void stopSyncing() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  @override
  Future<void> close() {
    _syncManager.dispose();
    _connectivitySubscription?.cancel();
    stopSyncing();
    return super.close();
  }
}
