import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/shared/providers/database_provider.dart';

import '../../data/services/expense_forecast_service.dart';

final expenseForecastProvider =
    FutureProvider(
  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final service =
        ExpenseForecastService(
      isar,
    );

    return service
        .generateForecast();
  },
);