import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../../../shared/models/investment_model.dart';

final investmentSyncProvider =
    Provider<InvestmentSyncService>((ref) {
  return InvestmentSyncService(ref);
});

class InvestmentSyncService {
  final Ref ref;

  InvestmentSyncService(this.ref);

  Future<int> syncAllInvestments() async {
    final isar = await ref.read(isarProvider.future);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw StateError(
        'User must be signed in to sync investments.',
      );
    }

    final investments =
        await isar.investmentModels
            .filter()
            //.isDeletedEqualTo(false)
            .isSyncedEqualTo(false)
            .findAll();

    if (investments.isNotEmpty) {

        await Supabase.instance.client
            .from('investments')
            .upsert(

              investments.map(
                (investment) => {

                  'id': investment.id,

                  'user_id': user.id,

                  'name': investment.name,

                  'type': investment.type,

                  'symbol': investment.symbol,

                  'quantity': investment.quantity,

                  'purchase_price':
                      investment.purchasePrice,

                  'current_price':
                      investment.currentPrice,

                  'purchase_date':
                      investment.purchaseDate
                          .toIso8601String(),

                  'notes':
                      investment.notes,

                  'is_deleted':
                      investment.isDeleted,

                  'updated_at':
                      investment.updatedAt
                          .toIso8601String(),
                },
              ).toList(),
            );

        await isar.writeTxn(() async {

          for (final investment
              in investments) {

            investment.isSynced =
                true;

            investment.updatedAt =
                DateTime.now();

            await isar
                .investmentModels
                .put(
              investment,
            );
          }
        });
      }

      return investments.length;
  }
}