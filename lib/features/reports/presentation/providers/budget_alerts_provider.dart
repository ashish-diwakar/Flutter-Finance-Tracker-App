
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/services/budget_alert_checker.dart';
import '../../domain/models/budget_alert_model.dart';

final budgetAlertsProvider =
    FutureProvider<
        List<BudgetAlertModel>>(

  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final checker =
        BudgetAlertChecker(
      isar,
    );

    return checker
        .checkAlerts(includeSafe: true);
  },
);