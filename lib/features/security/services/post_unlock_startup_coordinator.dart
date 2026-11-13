import '../../../core/services/logger_service.dart';

abstract interface class PostUnlockStartup {
  Future<void> run();
}

/// Runs the existing post-authentication work in its established order.
class PostUnlockStartupCoordinator<TDatabase> implements PostUnlockStartup {
  const PostUnlockStartupCoordinator({
    required Future<TDatabase> Function() openDatabase,
    required Future<int> Function(TDatabase) processRecurring,
    required Future<void> Function() reconcileReminders,
    required Future<void> Function(TDatabase) processBudgetAlerts,
  }) : _openDatabase = openDatabase,
       _processRecurring = processRecurring,
       _reconcileReminders = reconcileReminders,
       _processBudgetAlerts = processBudgetAlerts;

  final Future<TDatabase> Function() _openDatabase;
  final Future<int> Function(TDatabase) _processRecurring;
  final Future<void> Function() _reconcileReminders;
  final Future<void> Function(TDatabase) _processBudgetAlerts;

  @override
  Future<void> run() async {
    final database = await _openDatabase();

    final generatedCount = await _processRecurring(database);
    if (generatedCount > 0) {
      LoggerService.info('$generatedCount recurring transactions generated.');
    }

    try {
      await _reconcileReminders();
      LoggerService.info('Borrow/Lend reminders reconciled.');
    } catch (e, stackTrace) {
      LoggerService.exception(
        'Unable to reconcile Borrow/Lend reminders',
        e,
        stackTrace,
      );
    }

    await _processBudgetAlerts(database);
    LoggerService.info('Post-authentication initialization completed.');
  }
}
