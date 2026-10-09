import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/services/budget_alert_checker.dart';
import '../../domain/models/budget_alert_model.dart';

// =========================================================
// GENERIC FINANCIAL TARGET PROVIDER
// =========================================================

typedef FinancialTargetAlertsParams = ({
  FinancialTargetType targetType,
  int year,
  int month,
});

final financialTargetAlertsProvider =
    FutureProvider.family<
        List<BudgetAlertModel>,
        FinancialTargetAlertsParams>(
  (
    ref,
    params,
  ) async {
    final isar = await ref.read(
      isarProvider.future,
    );

    final checker =
        BudgetAlertChecker(
      isar,
    );

    return checker.checkAlerts(
      includeSafe: true,
      targetType:
          params.targetType,
      month: DateTime(
        params.year,
        params.month,
        1,
      ),
    );
  },
);

// =========================================================
// EXISTING EXPENSE BUDGET PROVIDER
// =========================================================
//
// Keep this provider so existing Budget Alerts UI
// continues working without any changes yet.

final budgetAlertsProvider =
    FutureProvider<
        List<BudgetAlertModel>>(
  (ref) async {
    final now = DateTime.now();

    return ref.watch(
      financialTargetAlertsProvider(
        (
          targetType:
              FinancialTargetType
                  .expenseBudget,
          year: now.year,
          month: now.month,
        ),
      ).future,
    );
  },
);