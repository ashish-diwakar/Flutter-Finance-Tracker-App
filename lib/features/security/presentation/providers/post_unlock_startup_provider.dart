import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/database/isar_service.dart';
import '../../../borrow_lend/data/services/borrow_lend_notification_service.dart';
import '../../../recurring/data/services/recurring_scheduler_service.dart';
import '../../../reports/data/services/budget_alert_checker.dart';
import '../../../reports/data/services/budget_notification_service.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../services/post_unlock_startup_coordinator.dart';

final postUnlockStartupProvider = Provider<PostUnlockStartup>((ref) {
  return PostUnlockStartupCoordinator<Isar>(
    openDatabase: IsarService.openIsar,
    processRecurring: (isar) =>
        RecurringSchedulerService(isar).processRecurringTransactions(),
    reconcileReminders: () async {
      final transactions = await ref.read(transactionsStreamProvider.future);
      final currency = ref.read(currencyProvider);
      await BorrowLendNotificationService.syncAllReminders(
        transactions: transactions,
        currency: currency,
      );
    },
    processBudgetAlerts: (isar) async {
      final alerts = await BudgetAlertChecker(
        isar,
      ).checkAlerts(includeSafe: false);
      await BudgetNotificationService.processBudgetAlerts(alerts);
    },
  );
});
