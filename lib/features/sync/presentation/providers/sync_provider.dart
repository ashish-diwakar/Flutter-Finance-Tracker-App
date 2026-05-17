import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/services/sync_service.dart';

final syncServiceProvider =
    FutureProvider<SyncService>(
        (ref) async {

  final isar =
      await ref.watch(
        isarProvider.future,
      );

  return SyncService(isar);
});