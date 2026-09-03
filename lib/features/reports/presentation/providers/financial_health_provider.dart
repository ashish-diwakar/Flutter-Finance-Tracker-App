import 'package:finance_tracker/features/reports/domain/models/financial_health_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finance_tracker/shared/providers/database_provider.dart';

import '../../data/services/financial_health_service.dart';

final financialHealthProvider =
    FutureProvider.family<
        FinancialHealthModel,
        DateTime>(
  (ref, month) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final service =
        FinancialHealthService(
      isar,
    );

    return await service.calculateHealth(month);
    
  },
);