import 'dart:async';

import 'package:finance_tracker/features/backup/data/repositories/backup_repository.dart';
import 'package:finance_tracker/features/backup/presentation/providers/backup_repository_provider.dart';
import 'package:finance_tracker/features/backup/presentation/screens/backup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

class _UnusedIsar extends Fake implements Isar {}

class _FakeBackupRepository extends BackupRepository {
  _FakeBackupRepository() : super(_UnusedIsar());

  Future<PreparedBackupImport?> Function()? prepare;
  Future<void> Function(PreparedBackupImport)? restore;
  int prepareCalls = 0;
  int restoreCalls = 0;

  @override
  Future<PreparedBackupImport?> prepareBackupImport() async {
    prepareCalls++;
    return prepare?.call();
  }

  @override
  Future<void> restoreBackup(PreparedBackupImport prepared) async {
    restoreCalls++;
    await restore?.call(prepared);
  }
}

PreparedBackupImport preparedBackup() {
  return PreparedBackupImport(
    fileName: 'finance_backup.json',
    transactions: [],
    categories: [],
    accounts: [],
  );
}

Future<void> _pumpBackupScreen(
  WidgetTester tester,
  _FakeBackupRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        backupRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: const MaterialApp(home: BackupScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapImport(WidgetTester tester) async {
  final importButton = find.widgetWithText(OutlinedButton, 'Import Backup');
  await tester.ensureVisible(importButton);
  await tester.pumpAndSettle();
  await tester.tap(importButton);
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets(
    'cancelling the file picker never shows confirmation or restores',
    (tester) async {
      final repository = _FakeBackupRepository()..prepare = () async => null;
      await _pumpBackupScreen(tester, repository);

      await tapImport(tester);

      expect(repository.prepareCalls, 1);
      expect(repository.restoreCalls, 0);
      expect(find.text('Restore Backup?'), findsNothing);
    },
  );

  testWidgets('preflight failure shows an error without confirmation', (
    tester,
  ) async {
    final repository = _FakeBackupRepository()
      ..prepare = () async => throw const FormatException('Invalid backup');
    await _pumpBackupScreen(tester, repository);

    await tapImport(tester);

    expect(find.text('Restore Backup?'), findsNothing);
    expect(find.textContaining('Import failed:'), findsOneWidget);
    expect(repository.restoreCalls, 0);
  });

  testWidgets('Cancel leaves the prepared backup unrestored', (tester) async {
    final repository = _FakeBackupRepository()
      ..prepare = () async => preparedBackup();
    await _pumpBackupScreen(tester, repository);

    await tapImport(tester);

    expect(find.text('finance_backup.json'), findsOneWidget);
    expect(find.text('Replace existing data'), findsOneWidget);
    expect(
      find.text(
        'Importing this backup will replace your existing accounts, categories, and transactions with the records from the selected file.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(repository.restoreCalls, 0);
  });

  testWidgets('back dismissal leaves the prepared backup unrestored', (
    tester,
  ) async {
    final repository = _FakeBackupRepository()
      ..prepare = () async => preparedBackup();
    await _pumpBackupScreen(tester, repository);

    await tapImport(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Restore Backup?'), findsNothing);
    expect(repository.restoreCalls, 0);
  });

  testWidgets('outside dismissal leaves the prepared backup unrestored', (
    tester,
  ) async {
    final repository = _FakeBackupRepository()
      ..prepare = () async => preparedBackup();
    await _pumpBackupScreen(tester, repository);

    await tapImport(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Restore Backup?'), findsNothing);
    expect(repository.restoreCalls, 0);
  });

  testWidgets('explicit Restore invokes the restore operation once', (
    tester,
  ) async {
    final repository = _FakeBackupRepository();
    repository.prepare = () async => preparedBackup();
    repository.restore = (_) async {
      throw StateError('Controlled test failure');
    };
    await _pumpBackupScreen(tester, repository);

    await tapImport(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
    await tester.pumpAndSettle();

    expect(repository.restoreCalls, 1);
    expect(find.textContaining('Import failed:'), findsOneWidget);
  });

  testWidgets('import button is disabled while restore is in progress', (
    tester,
  ) async {
    final restoreCompleter = Completer<void>();
    final repository = _FakeBackupRepository();
    repository.prepare = () async => preparedBackup();
    repository.restore = (_) => restoreCompleter.future;
    await _pumpBackupScreen(tester, repository);

    await tapImport(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
    await tester.pump();

    final importButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Preparing backup…'),
    );
    expect(importButton.onPressed, isNull);
    expect(repository.restoreCalls, 1);

    restoreCompleter.completeError(StateError('Controlled test failure'));
    await tester.pumpAndSettle();

    expect(repository.restoreCalls, 1);
  });
}
