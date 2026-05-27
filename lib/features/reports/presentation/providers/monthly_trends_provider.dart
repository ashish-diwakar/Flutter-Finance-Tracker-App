import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/shared/providers/database_provider.dart';

import '../../data/services/monthly_trend_service.dart';

final monthlyTrendsProvider =
    FutureProvider(
  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final service =
        MonthlyTrendService(
      isar,
    );

    return service
        .getMonthlyTrends();
  },
);