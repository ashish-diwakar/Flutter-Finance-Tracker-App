import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finance_tracker/shared/providers/database_provider.dart';

import '../../data/services/financial_insight_service.dart';

final financialInsightsProvider =
    FutureProvider(
  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final service =
        FinancialInsightService(
      isar,
    );

    return service
        .generateInsights();
  },
);