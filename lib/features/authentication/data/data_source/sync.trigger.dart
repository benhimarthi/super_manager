import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'sync.manager.dart';

class SyncTrigger {
  SyncTrigger(this._syncManager);

  final SyncManager _syncManager;
  Timer? _syncTimer;

  void startSyncing() {
    _syncTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await _syncManager.syncData();
      }
    });
  }

  void runOnAppStart() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await _syncManager.syncData();
    }
  }

  void stopSyncing() {
    _syncTimer?.cancel();
  }
}
