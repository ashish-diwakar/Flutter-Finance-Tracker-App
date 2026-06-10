import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
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

    final items =
    await isar
        .investmentModels
        .filter()
        .isDeletedEqualTo(false)
        .findAll();

    debugPrint(
      'INVESTMENTS COUNT: ${items.length}',
    );

    return items;
  },
);

