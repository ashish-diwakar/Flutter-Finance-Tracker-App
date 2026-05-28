import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finance_tracker/shared/providers/database_provider.dart';

import '../../data/services/financial_health_service.dart';

final financialHealthProvider =
    FutureProvider(
  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final service =
        FinancialHealthService(
      isar,
    );

    return service
        .calculateHealth();
  },
);