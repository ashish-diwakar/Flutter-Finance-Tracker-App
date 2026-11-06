import 'package:finance_tracker/core/services/logger_service.dart';
import 'package:finance_tracker/features/backup/data/repositories/backup_repository.dart';
import 'package:finance_tracker/features/borrow_lend/data/services/borrow_lend_notification_service.dart';
import 'package:finance_tracker/features/backup/domain/services/backup_v2_preflight.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:finance_tracker/shared/providers/currency_provider.dart';
import 'package:finance_tracker/shared/utils/provider_refresh_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/aurora_app_bar.dart';
import '../providers/backup_repository_provider.dart';

typedef BackupPostRestoreReconciler =
    Future<List<String>> Function(
      WidgetRef ref,
      List<TransactionModel> previousTransactions,
    );

class BackupScreen extends ConsumerStatefulWidget {
  final BackupPostRestoreReconciler? postRestoreReconciler;

  const BackupScreen({super.key, this.postRestoreReconciler});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _exporting = false;
  bool _savingLocally = false;
  bool _importing = false;

  Future<void> _exportBackup({required bool saveLocally}) async {
    if (_exporting || _importing) {
      return;
    }

    setState(() {
      _exporting = true;
      _savingLocally = saveLocally;
    });

    try {
      final repository = await ref.read(backupRepositoryProvider.future);
      if (!mounted) return;

      bool? recoveryApproved;
      Future<bool> confirmUnverified(FormatException error) async {
        final approved =
            mounted &&
            await _confirmRecoveryCopy(error, saveLocally: saveLocally);
        recoveryApproved = mounted && approved;
        return recoveryApproved!;
      }

      if (saveLocally) {
        final saved = await repository.saveBackupLocally(
          confirmUnverified: confirmUnverified,
        );
        if (!saved) return;
      } else {
        await repository.shareBackup(confirmUnverified: confirmUnverified);
        if (recoveryApproved == false) return;
      }

      if (!mounted) return;
      final label = recoveryApproved == true
          ? 'Unverified recovery copy'
          : 'Backup';
      final action = saveLocally ? 'saved' : 'prepared for sharing';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label $action')));
    } on Object catch (error) {
      LoggerService.error('Backup export failed (${error.runtimeType}).');

      if (mounted) {
        final action = saveLocally
            ? 'save the file'
            : 'prepare the file for sharing';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to $action. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _savingLocally = false;
        });
      }
    }
  }

  Future<bool> _confirmRecoveryCopy(
    FormatException error, {
    required bool saveLocally,
  }) async {
    final missingReferences = error is MissingRecurringReferencesException
        ? error
        : null;
    final issue = switch (error) {
      MissingRecurringReferencesException(:final message, :final paths) =>
        '${paths.length} invalid ${paths.length == 1 ? 'reference' : 'references'}. $message',
      BackupValidationException(:final issue) => issue,
      _ => 'The generated backup failed validation.',
    };
    final paths = switch (error) {
      MissingRecurringReferencesException(:final paths) => paths,
      BackupValidationException(:final path) => [path],
      _ => const <String>[],
    };
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFFF3FAF5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            scrollable: true,
            title: const Text(
              'Backup Needs Attention',
              style: TextStyle(color: Color(0xFF315F53)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This backup is not verified for restore. Import will reject this copy. You can keep it for recovery, then fix the data and export a new backup.',
                ),
                const SizedBox(height: 12),
                Text(issue),
                if (paths.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SelectableText(paths.join('\n')),
                ],
                if (missingReferences != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Go to Settings → Recurring Transactions → Edit. Select the correct account and category, tap Save Repair, then export again.',
                  ),
                ],
              ],
            ),
            actions: [
              OutlinedButton(
                autofocus: true,
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF315F53),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  saveLocally
                      ? 'Save Unverified Recovery Copy'
                      : 'Share Unverified Recovery Copy',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _importBackup() async {
    if (_importing || _exporting) return;
    setState(() => _importing = true);

    try {
      final repository = await ref.read(backupRepositoryProvider.future);
      if (!mounted) return;

      final selected = await repository.prepareVersion2BackupImport();
      if (!mounted || selected == null) return;

      var previousTransactions = <TransactionModel>[];
      var previousTransactionsAvailable = false;
      final result = await showDialog<BackupRestoreResult>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _RestoreConfirmationDialog(
          fileName: _displayFileName(selected.fileName),
          plan: selected.plan,
          onRestore: () async {
            try {
              previousTransactions = await repository
                  .loadTransactionsForRestore();
              previousTransactionsAvailable = true;
            } on Object catch (error) {
              LoggerService.error(
                'Could not snapshot reminder IDs before restore '
                '(${error.runtimeType}).',
              );
            }
            return repository.restoreVersion2Backup(selected.plan);
          },
        ),
      );

      if (!mounted || result == null) return;
      if (!result.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Backup restore failed.'),
          ),
        );
        return;
      }

      final warnings = <String>[...result.warnings];
      if (!previousTransactionsAvailable) {
        warnings.add(
          'Data was restored, but prior borrow/lend reminders could not all be identified for cancellation.',
        );
      }
      try {
        warnings.addAll(
          widget.postRestoreReconciler == null
              ? await _refreshAndReconcile(repository, previousTransactions)
              : await widget.postRestoreReconciler!(ref, previousTransactions),
        );
      } on Object catch (error) {
        LoggerService.error(
          'Post-restore reconciliation failed (${error.runtimeType}).',
        );
        warnings.add(
          'Data was restored, but screen refresh or reminders may need attention.',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(_restoreSuccessMessage(result.restoredCounts)),
        ),
      );
      for (final warning in warnings) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(warning)));
      }
    } on Object catch (error) {
      final diagnostic = error is MissingRecurringReferencesException
          ? MissingRecurringReferencesException.code
          : error.runtimeType.toString();
      LoggerService.error('V2 import was not completed ($diagnostic).');
      if (mounted) {
        await _showImportError(error);
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _showImportError(Object error) async {
    final paths = error is MissingRecurringReferencesException
        ? error.paths
        : const <String>[];
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF3FAF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        scrollable: true,
        title: const Text(
          'Cannot Restore Backup',
          style: TextStyle(color: Color(0xFF315F53)),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_importErrorMessage(error)),
            if (paths.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${paths.length} invalid ${paths.length == 1 ? 'reference' : 'references'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SelectableText(paths.join('\n')),
            ],
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _refreshAndReconcile(
    BackupRepository repository,
    List<TransactionModel> previousTransactions,
  ) async {
    final warnings = <String>[];
    final currency = ref.read(currencyProvider);
    try {
      await ProviderRefreshHelper.refreshAllFinancialData(ref);
    } on Object catch (error) {
      LoggerService.error(
        'Post-restore provider refresh failed (${error.runtimeType}).',
      );
      warnings.add(
        'Data was restored, but some screens may need to be reopened to refresh.',
      );
    }

    var remindersFailed = false;
    for (final transaction in previousTransactions) {
      if (transaction.type == 'borrowed' || transaction.type == 'lent') {
        try {
          await BorrowLendNotificationService.cancelReminders(transaction.uuid);
        } on Object {
          remindersFailed = true;
        }
      }
    }
    try {
      final restoredTransactions = await repository
          .loadTransactionsForRestore();
      final synced = await BorrowLendNotificationService.syncAllReminders(
        transactions: restoredTransactions,
        currency: currency,
      );
      remindersFailed = remindersFailed || !synced;
    } on Object catch (error) {
      LoggerService.error(
        'Post-restore borrow/lend reminder reconciliation failed '
        '(${error.runtimeType}).',
      );
      remindersFailed = true;
    }
    if (remindersFailed) {
      warnings.add(
        'Data was restored, but borrow/lend reminders may need attention.',
      );
    }
    return warnings;
  }

  static String _displayFileName(String fileName) {
    final normalized = fileName.replaceAll('\\', '/');
    final baseName = normalized.split('/').last;
    final safeName = baseName
        .replaceAll(
          RegExp(
            r'[\x00-\x1F\x7F-\x9F\u061C\u200E\u200F\u202A-\u202E\u2066-\u2069]',
          ),
          '',
        )
        .trim();
    return safeName.isEmpty ? 'Selected backup' : safeName;
  }

  static String _importErrorMessage(Object error) {
    if (error is MissingRecurringReferencesException) {
      return error.message;
    }
    if (error is FormatException &&
        error.message.contains('older incomplete backup format')) {
      return 'This older backup is incomplete and cannot be used for full restoration.';
    }
    if (error is FormatException &&
        error.message.contains('could not be read')) {
      return error.message;
    }
    return 'Unable to validate this file. Select a complete, supported Version 2 JSON backup.';
  }

  static String _restoreSuccessMessage(Map<String, int> counts) {
    return 'Backup restored successfully: '
        '${counts['accounts'] ?? 0} accounts, '
        '${counts['categories'] ?? 0} categories, '
        '${counts['transactions'] ?? 0} transactions, '
        '${counts['recurringTransactions'] ?? 0} recurring, '
        '${counts['financialGoals'] ?? 0} goals, '
        '${counts['investments'] ?? 0} investments.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Backup & Restore')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFB6D7CC),
                  Color(0xFFDAEDE5),
                  Color(0xFFF8FCFA),
                ],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Protect Your Financial Data',
                    style: TextStyle(
                      color: Color(0xFF244D40),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Save a complete JSON backup locally or share it, and choose a backup file to import.',
                    style: TextStyle(color: Color(0xFF536B61), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.zero,
                    color: const Color(0xFFF1F8F2),
                    surfaceTintColor: Colors.transparent,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: Color(0xFFA8CFC0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDFF1E5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.backup_outlined,
                                  color: Color(0xFF237F50),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Export Backup',
                                  style: TextStyle(
                                    color: Color(0xFF244D40),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Create a complete JSON backup of your accounts, categories, transactions, recurring transactions, goals, and investments.',
                            style: TextStyle(
                              color: Color(0xFF536B61),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _exporting || _importing
                                  ? null
                                  : () => _exportBackup(saveLocally: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF17664F),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_exporting && _savingLocally)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    const Icon(Icons.save_alt_outlined),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _exporting && _savingLocally
                                          ? 'Saving backup...'
                                          : 'Save Backup Locally',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _exporting || _importing
                                  ? null
                                  : () => _exportBackup(saveLocally: false),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9FCF9),
                                foregroundColor: const Color(0xFF17664F),
                                minimumSize: const Size.fromHeight(52),
                                side: const BorderSide(
                                  color: Color(0xFFA8CFC0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_exporting && !_savingLocally)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF17664F),
                                      ),
                                    )
                                  else
                                    const Icon(Icons.share_outlined),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _exporting && !_savingLocally
                                          ? 'Preparing share...'
                                          : 'Share / Send Backup',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    color: const Color(0xFFF1F8F2),
                    surfaceTintColor: Colors.transparent,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: Color(0xFFA8CFC0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F1E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.file_upload_outlined,
                                  color: Color(0xFF315F53),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Import Backup',
                                  style: TextStyle(
                                    color: Color(0xFF244D40),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Choose a complete Version 2 JSON backup to preview its six collections before full replacement. Older backups are incomplete and cannot be restored.',
                            style: TextStyle(
                              color: Color(0xFF536B61),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _importing || _exporting
                                  ? null
                                  : _importBackup,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9FCF9),
                                foregroundColor: const Color(0xFF17664F),
                                minimumSize: const Size.fromHeight(52),
                                side: const BorderSide(
                                  color: Color(0xFFA8CFC0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              icon: _importing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.upload_file_outlined),
                              label: Text(
                                _importing
                                    ? 'Preparing restore…'
                                    : 'Import Backup',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestoreConfirmationDialog extends StatefulWidget {
  final String fileName;
  final ValidatedBackupRestorePlan plan;
  final Future<BackupRestoreResult> Function() onRestore;

  const _RestoreConfirmationDialog({
    required this.fileName,
    required this.plan,
    required this.onRestore,
  });

  @override
  State<_RestoreConfirmationDialog> createState() =>
      _RestoreConfirmationDialogState();
}

class _RestoreConfirmationDialogState
    extends State<_RestoreConfirmationDialog> {
  bool _acknowledged = false;
  bool _restoring = false;

  Future<void> _restore() async {
    if (!_acknowledged || _restoring) return;
    setState(() => _restoring = true);
    try {
      final result = await widget.onRestore();
      if (mounted) Navigator.of(context).pop(result);
    } on Object {
      if (mounted) {
        Navigator.of(context).pop(
          BackupRestoreResult.failure('Backup restore failed unexpectedly.'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exportedAt = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(widget.plan.exportedAt.toLocal());
    final counts = widget.plan.recordCounts;

    return PopScope(
      canPop: !_restoring,
      child: AlertDialog(
        backgroundColor: const Color(0xFFF3FAF5),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        constraints: const BoxConstraints(maxWidth: 480),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        scrollable: true,
        titlePadding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actionsOverflowButtonSpacing: 8,
        actionsOverflowDirection: VerticalDirection.down,
        title: const Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFBE6E3),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB54C44),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Replace Existing Financial Data?',
                style: TextStyle(
                  color: Color(0xFF315F53),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F1E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected backup',
                      style: TextStyle(color: Color(0xFF536B61), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF244C40),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Exported $exportedAt',
                      style: const TextStyle(
                        color: Color(0xFF536B61),
                        fontSize: 14,
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFC9DBD0)),
                    const Text(
                      'Full replacement',
                      style: TextStyle(
                        color: Color(0xFF244C40),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RestoreCountRow(
                      label: 'Accounts',
                      count: counts['accounts']!,
                    ),
                    _RestoreCountRow(
                      label: 'Categories',
                      count: counts['categories']!,
                    ),
                    _RestoreCountRow(
                      label: 'Transactions',
                      count: counts['transactions']!,
                    ),
                    _RestoreCountRow(
                      label: 'Recurring Transactions',
                      count: counts['recurringTransactions']!,
                    ),
                    _RestoreCountRow(
                      label: 'Financial Goals',
                      count: counts['financialGoals']!,
                    ),
                    _RestoreCountRow(
                      label: 'Investments',
                      count: counts['investments']!,
                    ),
                    const Divider(height: 20, color: Color(0xFFC9DBD0)),
                    _RestoreCountRow(
                      label: 'Total records',
                      count: widget.plan.totalRecordCount,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Restoring this backup will replace ALL existing financial records in these six collections with the selected backup. Records added or changed after the backup was created will be lost.',
                style: TextStyle(color: Color(0xFF244C40), fontSize: 15),
              ),
              const SizedBox(height: 8),
              const Text(
                'This is NOT a merge and cannot be undone through the restore action. Save or share a fresh backup of your current data before proceeding.',
                style: TextStyle(color: Color(0xFF536B61), fontSize: 14),
              ),
              if (widget.plan.currencyCode != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Currency code in the backup is display metadata only. It will not convert amounts or change your current currency setting.',
                  style: TextStyle(color: Color(0xFF536B61), fontSize: 14),
                ),
              ],
              if (widget.plan.totalRecordCount == 0) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE9B8AF)),
                  ),
                  child: const Text(
                    'This is a valid, explicitly empty full snapshot. Restoring it will remove all existing records from these six collections.',
                    style: TextStyle(
                      color: Color(0xFF7C3933),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _acknowledged,
                onChanged: _restoring
                    ? null
                    : (value) => setState(() {
                        _acknowledged = value ?? false;
                      }),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I understand that restoring this backup will replace my existing financial records.',
                  style: TextStyle(color: Color(0xFF244C40), fontSize: 14),
                ),
                activeColor: const Color(0xFF17664F),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _restoring ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF315F53),
              minimumSize: const Size(88, 48),
              side: const BorderSide(color: Color(0xFFB5D9CA)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: !_acknowledged || _restoring ? null : _restore,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB54C44),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD8C3C0),
              disabledForegroundColor: const Color(0xFF705F5D),
              minimumSize: const Size(128, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: _restoring
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Restore Data'),
          ),
        ],
      ),
    );
  }
}

class _RestoreCountRow extends StatelessWidget {
  final String label;
  final int count;
  final bool isTotal;

  const _RestoreCountRow({
    required this.label,
    required this.count,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF315F53),
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            color: const Color(0xFF244C40),
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
