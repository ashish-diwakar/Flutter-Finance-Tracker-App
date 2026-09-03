import 'package:finance_tracker/features/reports/domain/models/financial_insight_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finance_tracker/shared/providers/database_provider.dart';

import '../../data/services/financial_insight_service.dart';

final financialInsightsProvider =
    FutureProvider.family<
        List<FinancialInsightModel>,
        DateTime>(
  (ref, month) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final service =
        FinancialInsightService(
      isar,
    );

    return service
        .generateInsights(month);
  },
);
