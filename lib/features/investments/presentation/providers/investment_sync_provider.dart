import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../sync/presentation/providers/sync_provider.dart';

final investmentSyncProvider =
    Provider<InvestmentSyncService>((ref) {
  return InvestmentSyncService(ref);
});

class InvestmentSyncService {
  final Ref ref;

  InvestmentSyncService(this.ref);

  Future<int> syncAllInvestments() async {
    //final isar = await ref.read(isarProvider.future);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw StateError(
        'User must be signed in to sync investments.',
      );
    }

    //
    final syncService = await ref.read(
        syncServiceProvider.future,
    );
    return await syncService.syncInvestments();
  }
}