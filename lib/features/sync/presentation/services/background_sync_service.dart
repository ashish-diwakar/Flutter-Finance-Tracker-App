import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import '../../data/services/sync_service.dart';

class BackgroundSyncService
    with WidgetsBindingObserver {

  final SyncService syncService;

  bool _syncing = false;

  StreamSubscription?
      _connectivitySubscription;

  BackgroundSyncService(
    this.syncService,
  );

  Future<void> initialize() async {

    WidgetsBinding.instance
        .addObserver(this);

    _connectivitySubscription =
        Connectivity()
            .onConnectivityChanged
            .listen(
      (_) {
        _triggerSync();
      },
    );
  }

  Future<void> dispose() async {

    WidgetsBinding.instance
        .removeObserver(this);

    await _connectivitySubscription
        ?.cancel();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {

    if (state ==
        AppLifecycleState.resumed) {

      _triggerSync();
    }
  }

  Future<void> syncNow() async {

    await _triggerSync();
  }

  Future<void> _triggerSync()
  async {

    if (_syncing) {
      return;
    }

    _syncing = true;

    try {

      await syncService.syncAll();

    } catch (_) {

      // ignore background sync failures
    }

    _syncing = false;
  }
}