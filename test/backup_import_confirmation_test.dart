import 'dart:async';
import 'dart:convert';

import 'package:finance_tracker/features/backup/data/repositories/backup_repository.dart';
import 'package:finance_tracker/features/backup/domain/services/backup_v2_preflight.dart';
import 'package:finance_tracker/features/backup/presentation/providers/backup_repository_provider.dart';
import 'package:finance_tracker/features/backup/presentation/screens/backup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';

class _UnusedIsar extends Fake implements Isar {}

Map<String, dynamic> _emptyBackup() {
  const names = [
    'accounts',
    'categories',
    'transactions',
    'recurringTransactions',
    'financialGoals',
    'investments',
  ];
  return {
    'format': 'finance-tracker-backup',
    'schemaVersion': 2,
    'metadata': {
      'exportedAt': '2026-11-06T00:00:00.000Z',
      'appVersion': null,
      'currencyCode': 'USD',
    },
    'manifest': {
      for (final name in names) name: {'recordCount': 0},
    },
    'collections': {for (final name in names) name: <dynamic>[]},
  };
}

class _FakeBackupRepository extends BackupRepository {
  _FakeBackupRepository()
    : super(_UnusedIsar(), backupImportFilePicker: () async => null);

  PreparedV2BackupImport? selected;
  Object? prepareError;
  Completer<BackupRestoreResult>? restoreCompleter;
  int prepareCalls = 0;
  int restoreCalls = 0;

  @override
  Future<PreparedV2BackupImport?> prepareVersion2BackupImport() async {
    prepareCalls++;
    if (prepareError case final error?) throw error;
    return selected;
  }

  @override
  Future<List<TransactionModel>> loadTransactionsForRestore() async => [];

  @override
  Future<BackupRestoreResult> restoreVersion2Backup(
    ValidatedBackupRestorePlan? plan,
  ) async {
    restoreCalls++;
    return restoreCompleter?.future ??
        BackupRestoreResult.success({
          'accounts': 0,
          'categories': 0,
          'transactions': 0,
          'recurringTransactions': 0,
          'financialGoals': 0,
          'investments': 0,
        });
  }
}

Future<void> _pumpBackupScreen(
  WidgetTester tester,
  _FakeBackupRepository repository, {
  double textScale = 1,
  Size size = const Size(800, 900),
  BackupPostRestoreReconciler? reconcile,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        backupRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: BackupScreen(
          postRestoreReconciler:
              reconcile ?? (ref, previousTransactions) async => [],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openPreview(
  WidgetTester tester,
  _FakeBackupRepository repository,
) async {
  final importButton = find.widgetWithText(OutlinedButton, 'Import Backup');
  await tester.ensureVisible(importButton);
  await tester.tap(importButton);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(repository.prepareCalls, 1);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cancelled picker makes no restore attempt', (tester) async {
    final repository = _FakeBackupRepository();
    await _pumpBackupScreen(tester, repository);

    await _openPreview(tester, repository);

    expect(find.text('Cannot Restore Backup'), findsNothing);
    expect(find.text('Replace Existing Financial Data?'), findsNothing);
    expect(repository.restoreCalls, 0);
  });

  testWidgets('invalid or legacy backup shows an error without preview', (
    tester,
  ) async {
    final repository = _FakeBackupRepository()
      ..prepareError = const FormatException(
        'This older incomplete backup format cannot be used for full restoration.',
      );
    await _pumpBackupScreen(tester, repository);

    await _openPreview(tester, repository);

    expect(
      find.text(
        'This older backup is incomplete and cannot be used for full restoration.',
      ),
      findsOneWidget,
    );
    expect(find.text('Replace Existing Financial Data?'), findsNothing);
    expect(repository.restoreCalls, 0);
  });

  testWidgets('invalid-reference details persist until closed at 130% scale', (
    tester,
  ) async {
    const paths = [
      r'$.collections.recurringTransactions[0].accountId',
      r'$.collections.recurringTransactions[0].categoryId',
      r'$.collections.recurringTransactions[1].accountId',
      r'$.collections.recurringTransactions[1].categoryId',
    ];
    final repository = _FakeBackupRepository()
      ..prepareError = MissingRecurringReferencesException(paths);
    await _pumpBackupScreen(
      tester,
      repository,
      size: const Size(320, 640),
      textScale: 1.3,
    );
    await _openPreview(tester, repository);
    await tester.pump(const Duration(seconds: 30));

    expect(find.text('Cannot Restore Backup'), findsOneWidget);
    expect(find.text('4 invalid references'), findsOneWidget);
    expect(find.text(paths.join('\n')), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Restore Data'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Close'));
    await tester.pumpAndSettle();
    expect(find.text('Cannot Restore Backup'), findsNothing);
    expect(
      find.widgetWithText(OutlinedButton, 'Import Backup'),
      findsOneWidget,
    );
    expect(repository.restoreCalls, 0);
  });

  testWidgets('preview shows sanitized filename, metadata, and all counts', (
    tester,
  ) async {
    final plan = BackupV2Preflight.parse(jsonEncode(_emptyBackup()));
    final repository = _FakeBackupRepository()
      ..selected = PreparedV2BackupImport(
        fileName: r'C:\private\finance_backup.json',
        plan: plan,
      );
    await _pumpBackupScreen(tester, repository);

    await _openPreview(tester, repository);

    expect(find.text('finance_backup.json'), findsOneWidget);
    expect(find.textContaining('Exported 06 Nov 2026'), findsOneWidget);
    expect(find.text('Full replacement'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Recurring Transactions'), findsOneWidget);
    expect(find.text('Financial Goals'), findsOneWidget);
    expect(find.text('Investments'), findsOneWidget);
    expect(find.text('Total records'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(7));
    expect(
      find.textContaining('valid, explicitly empty full snapshot'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Currency code in the backup is display metadata'),
      findsOneWidget,
    );
    final restoreButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Restore Data'),
    );
    expect(restoreButton.onPressed, isNull);
    expect(repository.restoreCalls, 0);
  });

  testWidgets('Cancel and back dismissal do not restore', (tester) async {
    for (final dismissWithBack in [false, true]) {
      final repository = _FakeBackupRepository()
        ..selected = PreparedV2BackupImport(
          fileName: 'synthetic.json',
          plan: BackupV2Preflight.parse(jsonEncode(_emptyBackup())),
        );
      await _pumpBackupScreen(tester, repository);
      await _openPreview(tester, repository);

      if (dismissWithBack) {
        await tester.binding.handlePopRoute();
      } else {
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      }
      await tester.pumpAndSettle();

      expect(find.text('Replace Existing Financial Data?'), findsNothing);
      expect(repository.restoreCalls, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('explicit acknowledgment and Restore Data invoke restore once', (
    tester,
  ) async {
    final repository = _FakeBackupRepository()
      ..selected = PreparedV2BackupImport(
        fileName: 'synthetic.json',
        plan: BackupV2Preflight.parse(jsonEncode(_emptyBackup())),
      );
    await _pumpBackupScreen(tester, repository);
    await _openPreview(tester, repository);

    final acknowledgment = find.textContaining('I understand that restoring');
    await tester.ensureVisible(acknowledgment);
    await tester.tap(acknowledgment);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final restoreButton = find.widgetWithText(FilledButton, 'Restore Data');
    await tester.ensureVisible(restoreButton);
    await tester.tap(restoreButton);
    await tester.pumpAndSettle();

    expect(repository.restoreCalls, 1);
    expect(
      find.textContaining('Backup restored successfully:'),
      findsOneWidget,
    );
  });

  testWidgets('restore action stays guarded against rapid repeated taps', (
    tester,
  ) async {
    final completer = Completer<BackupRestoreResult>();
    final repository = _FakeBackupRepository()
      ..selected = PreparedV2BackupImport(
        fileName: 'synthetic.json',
        plan: BackupV2Preflight.parse(jsonEncode(_emptyBackup())),
      )
      ..restoreCompleter = completer;
    await _pumpBackupScreen(tester, repository);
    await _openPreview(tester, repository);

    final acknowledgment = find.textContaining('I understand that restoring');
    await tester.ensureVisible(acknowledgment);
    await tester.tap(acknowledgment);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final restoreButton = find.widgetWithText(FilledButton, 'Restore Data');
    await tester.ensureVisible(restoreButton);
    await tester.tap(restoreButton);
    await tester.pump();
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.binding.handlePopRoute();
    await tester.tapAt(const Offset(4, 4));
    await tester.pump();

    expect(repository.restoreCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    completer.complete(
      BackupRestoreResult.success({
        'accounts': 0,
        'categories': 0,
        'transactions': 0,
        'recurringTransactions': 0,
        'financialGoals': 0,
        'investments': 0,
      }),
    );
    await tester.pumpAndSettle();
    expect(repository.restoreCalls, 1);
  });

  testWidgets('failed transaction shows failure and skips refresh', (
    tester,
  ) async {
    final repository = _FakeBackupRepository()
      ..selected = PreparedV2BackupImport(
        fileName: 'synthetic.json',
        plan: BackupV2Preflight.parse(jsonEncode(_emptyBackup())),
      )
      ..restoreCompleter = Completer<BackupRestoreResult>.sync();
    repository.restoreCompleter!.complete(
      BackupRestoreResult.failure(
        'Existing financial records were left unchanged.',
      ),
    );
    var refreshCalls = 0;
    await _pumpBackupScreen(
      tester,
      repository,
      reconcile: (_, _) async {
        refreshCalls++;
        return [];
      },
    );
    await _openPreview(tester, repository);
    final acknowledgment = find.byType(CheckboxListTile);
    await tester.ensureVisible(acknowledgment);
    await tester.tap(acknowledgment);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Restore Data'));
    await tester.pumpAndSettle();

    expect(repository.restoreCalls, 1);
    expect(refreshCalls, 0);
    expect(
      find.textContaining('Existing financial records were left unchanged'),
      findsOneWidget,
    );
    expect(find.textContaining('Backup restored successfully'), findsNothing);
  });

  testWidgets('committed restore reports a separate reconciliation warning', (
    tester,
  ) async {
    final repository = _FakeBackupRepository()
      ..selected = PreparedV2BackupImport(
        fileName: 'synthetic.json',
        plan: BackupV2Preflight.parse(jsonEncode(_emptyBackup())),
      );
    var refreshCalls = 0;
    await _pumpBackupScreen(
      tester,
      repository,
      reconcile: (_, _) async {
        expect(repository.restoreCalls, 1);
        refreshCalls++;
        throw StateError('synthetic notification failure');
      },
    );
    await _openPreview(tester, repository);
    final acknowledgment = find.byType(CheckboxListTile);
    await tester.ensureVisible(acknowledgment);
    await tester.tap(acknowledgment);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Restore Data'));
    await tester.pumpAndSettle();

    expect(refreshCalls, 1);
    expect(find.textContaining('Backup restored successfully'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Data was restored, but screen refresh or reminders'),
      findsOneWidget,
    );
  });

  testWidgets('restore dialog remains usable at narrow width and 130% scale', (
    tester,
  ) async {
    final repository = _FakeBackupRepository()
      ..selected = PreparedV2BackupImport(
        fileName: 'long_synthetic_finance_backup_20261106.json',
        plan: BackupV2Preflight.parse(jsonEncode(_emptyBackup())),
      );
    await _pumpBackupScreen(
      tester,
      repository,
      textScale: 1.3,
      size: const Size(320, 640),
    );
    await _openPreview(tester, repository);

    expect(find.text('Replace Existing Financial Data?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Restore Data'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
