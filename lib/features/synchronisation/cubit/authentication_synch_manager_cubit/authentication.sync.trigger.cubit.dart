import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../authentication/data/data_source/sync.manager.dart';
import 'authentication.sync.trigger.state.dart';

class AuthenticationSyncTriggerCubit
    extends Cubit<AuthenticationSyncTriggerState> {
  final SyncManager _syncManager;
  Timer? _syncTimer;
  late final StreamSubscription<ConnectivityResult> _subscription;

  AuthenticationSyncTriggerCubit(this._syncManager) : super(SyncInitial()) {
    startSyncing();
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        runOnAppStart();
      }
    });
  }

  void startSyncing() {
    _syncTimer = Timer.periodic(const Duration(seconds: 100), (timer) async {
      emit(SyncInProgress()); // 🔄 Sync is happening
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          await _syncManager.syncData();
          emit(SyncSuccess()); // ✅ Sync completed successfully
        } catch (e) {
          emit(SyncFailure(e.toString())); // ❌ Handle sync failure
        }
      }
    });
  }

  void runOnAppStart() async {
    emit(SyncInProgress());
    try {
      await _syncManager.syncData();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }

  void stopSyncing() {
    _syncTimer?.cancel();
    emit(SyncInitial());
  }

  @override
  Future<void> close() {
    stopSyncing();
    _subscription.cancel();
    return super.close();
  }
}
