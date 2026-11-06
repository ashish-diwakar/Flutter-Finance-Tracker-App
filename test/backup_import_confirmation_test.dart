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

  int prepareCalls = 0;
  int restoreCalls = 0;

  @override
  Future<PreparedBackupImport?> prepareBackupImport() async {
    prepareCalls++;
    return null;
  }

  @override
  Future<void> restoreBackup(PreparedBackupImport prepared) async {
    restoreCalls++;
  }
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

void main() {
  testWidgets('restore action is unavailable pending complete V2 restore', (
    tester,
  ) async {
    final repository = _FakeBackupRepository();
    await _pumpBackupScreen(tester, repository);

    expect(
      find.textContaining(
        'Version 2 backups can be exported, but importing them requires the upcoming restore update.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Older backups are incomplete'), findsOneWidget);
    final restoreButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Restore update coming soon'),
    );
    expect(restoreButton.onPressed, isNull);
    expect(repository.prepareCalls, 0);
    expect(repository.restoreCalls, 0);
  });
}
