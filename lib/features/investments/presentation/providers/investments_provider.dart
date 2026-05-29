import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../../../shared/models/investment_model.dart';

final investmentsProvider =
    FutureProvider<
        List<
            InvestmentModel>>(

  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    return isar
        .investmentModels
        .filter()
        .isDeletedEqualTo(
          false,
        )
        .sortByPurchaseDateDesc()
        .findAll();
  },
);