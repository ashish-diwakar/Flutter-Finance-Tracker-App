import 'package:flutter_riverpod/flutter_riverpod.dart';

//import '../../data/services/sync_service.dart';
import '../services/background_sync_service.dart';
import 'sync_provider.dart';

final backgroundSyncProvider =
    FutureProvider<
        BackgroundSyncService>(
  (ref) async {

    final syncService =
        await ref.watch(
      syncServiceProvider.future,
    );

    final service =
        BackgroundSyncService(
      syncService,
    );

    await service.initialize();

    ref.onDispose(() {
      service.dispose();
    });

    return service;
  },
);