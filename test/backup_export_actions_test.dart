import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:finance_tracker/features/backup/data/repositories/backup_repository.dart';
import 'package:finance_tracker/features/backup/domain/services/backup_v2_preflight.dart';
import 'package:finance_tracker/features/backup/presentation/providers/backup_repository_provider.dart';
import 'package:finance_tracker/features/backup/presentation/screens/backup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

const _collections = [
  'accounts',
  'categories',
  'transactions',
  'recurringTransactions',
  'financialGoals',
  'investments',
];
const _privateNote = 'private synthetic schedule note';
const _missingId = '00000000-0000-4000-8000-000000000002';

String _fixture({bool broken = false}) => jsonEncode({
  'format': 'finance-tracker-backup',
  'schemaVersion': 2,
  'metadata': {'exportedAt': '2026-01-01T00:00:00.000Z'},
  'manifest': {
    for (final name in _collections)
      name: {'recordCount': broken && name == 'recurringTransactions' ? 1 : 0},
  },
  'collections': {
    for (final name in _collections) name: [],
    if (broken)
      'recurringTransactions': [
        {
          'id': '00000000-0000-4000-8000-000000000001',
          'accountId': _missingId,
          'categoryId': _missingId,
          'amount': 12345,
          'type': 'expense',
          'notes': _privateNote,
          'startDate': '2026-01-01T00:00:00.000Z',
          'endDate': null,
          'frequency': 'monthly',
          'interval': 1,
          'isActive': false,
          'nextRunDate': '2026-02-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
          'isDeleted': true,
        },
      ],
  },
});

final _backupJson = _fixture();

class _UnusedIsar extends Fake implements Isar {}

class _FakeBackupRepository extends BackupRepository {
  _FakeBackupRepository() : super(_UnusedIsar());

  Future<bool> Function()? save;
  Future<void> Function()? share;
  int saveCalls = 0;
  int shareCalls = 0;

  @override
  Future<bool> saveBackupLocally({
    ConfirmUnverifiedBackup? confirmUnverified,
  }) async {
    saveCalls++;
    final saveBackup = save;
    return saveBackup == null ? true : await saveBackup();
  }

  @override
  Future<void> shareBackup({ConfirmUnverifiedBackup? confirmUnverified}) async {
    shareCalls++;
    await share?.call();
  }
}

class _FixedJsonBackupRepository extends BackupRepository {
  _FixedJsonBackupRepository({
    required BackupLocalFileSaver localFileSaver,
    required BackupFileSharer fileSharer,
    this.json,
  }) : super(
         _UnusedIsar(),
         localFileSaver: localFileSaver,
         fileSharer: fileSharer,
       );

  int generationCalls = 0;
  final String? json;

  @override
  Future<String> generateBackupJson() async {
    generationCalls++;
    return json ?? _backupJson;
  }
}

Future<void> _pumpScreen(
  WidgetTester tester,
  BackupRepository repository, {
  double textScale = 1,
}) async {
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
        home: const BackupScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('backup export repository destinations', () {
    test(
      'both destinations require explicit approval for invalid JSON',
      () async {
        final json = _fixture(broken: true);
        final names = <String>[];
        final payloads = <String>[];
        File? shareFile;
        final repository = _FixedJsonBackupRepository(
          json: json,
          localFileSaver: ({required fileName, required bytes}) async {
            names.add(fileName);
            payloads.add(utf8.decode(bytes));
            return 'saved';
          },
          fileSharer: (file) async {
            shareFile = file;
            names.add(file.uri.pathSegments.last);
            payloads.add(await file.readAsString());
            throw StateError('Synthetic share failure');
          },
        );
        final recurringError = isA<MissingRecurringReferencesException>();
        await expectLater(
          repository.saveBackupLocally(),
          throwsA(recurringError),
        );
        await expectLater(repository.shareBackup(), throwsA(recurringError));
        expect(names, isEmpty);
        expect(repository.generationCalls, 2);

        Future<bool> approve(FormatException error) async {
          expect(error, recurringError);
          return true;
        }

        expect(
          await repository.saveBackupLocally(confirmUnverified: approve),
          isTrue,
        );
        await expectLater(
          repository.shareBackup(confirmUnverified: approve),
          throwsStateError,
        );
        expect(repository.generationCalls, 4);
        expect(payloads, [json, json]);
        expect(
          names,
          everyElement(
            matches(r'^finance_backup_unverified_\d{8}_\d{6}\.json$'),
          ),
        );
        expect(await shareFile!.exists(), isFalse);
      },
    );

    test(
      'local save sends generated UTF-8 bytes to the chosen-file flow',
      () async {
        Uint8List? receivedBytes;
        String? receivedFileName;
        var shareCalls = 0;
        final repository = _FixedJsonBackupRepository(
          localFileSaver: ({required fileName, required bytes}) async {
            receivedFileName = fileName;
            receivedBytes = bytes;
            return 'provider-result';
          },
          fileSharer: (_) async {
            shareCalls++;
          },
        );

        expect(await repository.saveBackupLocally(), isTrue);

        expect(repository.generationCalls, 1);
        expect(utf8.decode(receivedBytes!), _backupJson);
        expect(
          receivedFileName,
          matches(RegExp(r'^finance_backup_\d{8}_\d{6}\.json$')),
        );
        expect(shareCalls, 0);
      },
    );

    test('cancelled local save reports no saved document', () async {
      var shareCalls = 0;
      final repository = _FixedJsonBackupRepository(
        localFileSaver: ({required fileName, required bytes}) async => null,
        fileSharer: (_) async {
          shareCalls++;
        },
      );

      expect(await repository.saveBackupLocally(), isFalse);
      expect(repository.generationCalls, 1);
      expect(shareCalls, 0);
    });

    test(
      'share uses generated JSON in a temporary file and never saves locally',
      () async {
        Uint8List? receivedBytes;
        String? receivedFileName;
        File? sharedFile;
        var localSaveCalls = 0;
        final repository = _FixedJsonBackupRepository(
          localFileSaver: ({required fileName, required bytes}) async {
            localSaveCalls++;
            return 'unexpected';
          },
          fileSharer: (file) async {
            sharedFile = file;
            receivedBytes = await file.readAsBytes();
            receivedFileName = file.uri.pathSegments.last;
            expect(await file.exists(), isTrue);
          },
        );

        await repository.shareBackup();

        expect(repository.generationCalls, 1);
        expect(utf8.decode(receivedBytes!), _backupJson);
        expect(
          receivedFileName,
          matches(RegExp(r'^finance_backup_\d{8}_\d{6}\.json$')),
        );
        expect(localSaveCalls, 0);
        expect(await sharedFile!.exists(), isFalse);
      },
    );
  });

  group('backup export actions', () {
    for (final save in [true, false]) {
      testWidgets(
        'invalid export waits for a destination-specific choice (save: $save)',
        (tester) async {
          tester.view.physicalSize = const Size(320, 480);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final json = _fixture(broken: true);
          final saved = <String>[];
          final repository = _FixedJsonBackupRepository(
            json: json,
            localFileSaver: ({required fileName, required bytes}) async {
              expect(fileName, startsWith('finance_backup_unverified_'));
              saved.add(utf8.decode(bytes));
              return 'saved';
            },
            fileSharer: (_) async => fail('Unexpected native share'),
          );
          await _pumpScreen(tester, repository, textScale: 1.3);

          final action = find.text(
            save ? 'Save Backup Locally' : 'Share / Send Backup',
          );
          await tester.ensureVisible(action);
          await tester.tap(action);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(seconds: 30));

          expect(repository.generationCalls, 1);
          expect(saved, isEmpty);
          expect(find.text('Backup Needs Attention'), findsOneWidget);
          expect(find.textContaining('2 invalid references'), findsOneWidget);
          expect(find.byType(SelectableText), findsOneWidget);
          final paths = tester
              .widget<SelectableText>(find.byType(SelectableText))
              .data;
          expect(
            paths,
            contains(r'$.collections.recurringTransactions[0].accountId'),
          );
          expect(
            paths,
            contains(r'$.collections.recurringTransactions[0].categoryId'),
          );
          expect(find.textContaining(_privateNote), findsNothing);
          expect(find.textContaining(_missingId), findsNothing);
          expect(find.textContaining('12345'), findsNothing);
          expect(find.textContaining('Save Repair'), findsOneWidget);
          expect(tester.takeException(), isNull);
          expect(
            find.text(
              save
                  ? 'Share Unverified Recovery Copy'
                  : 'Save Unverified Recovery Copy',
            ),
            findsNothing,
          );

          await tester.tap(
            find.text(save ? 'Save Unverified Recovery Copy' : 'Cancel'),
          );
          await tester.pumpAndSettle();
          expect(repository.generationCalls, 1);
          expect(saved, save ? [json] : isEmpty);
          expect(find.text('Backup saved'), findsNothing);
          expect(find.text('Backup prepared for sharing'), findsNothing);
          expect(
            find.text('Unverified recovery copy saved'),
            save ? findsOneWidget : findsNothing,
          );
        },
      );
    }

    testWidgets('Save Backup Locally invokes save only and reports success', (
      tester,
    ) async {
      final repository = _FakeBackupRepository();
      await _pumpScreen(tester, repository);

      await tester.tap(find.text('Save Backup Locally'));
      await tester.pumpAndSettle();

      expect(repository.saveCalls, 1);
      expect(repository.shareCalls, 0);
      expect(find.text('Backup saved'), findsOneWidget);
    });

    testWidgets('cancelled save does not report success', (tester) async {
      final repository = _FakeBackupRepository()..save = () async => false;
      await _pumpScreen(tester, repository);

      await tester.tap(find.text('Save Backup Locally'));
      await tester.pumpAndSettle();

      expect(repository.saveCalls, 1);
      expect(find.text('Backup saved'), findsNothing);
      expect(repository.shareCalls, 0);
    });

    testWidgets('save error is shown without a success message', (
      tester,
    ) async {
      final repository = _FakeBackupRepository()
        ..save = () async => throw const FileSystemException('No write access');
      await _pumpScreen(tester, repository);

      await tester.tap(find.text('Save Backup Locally'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Unable to save the file'), findsOneWidget);
      expect(find.text('Backup saved'), findsNothing);
      expect(repository.shareCalls, 0);
    });

    testWidgets('Share / Send Backup invokes share only', (tester) async {
      final repository = _FakeBackupRepository();
      await _pumpScreen(tester, repository);

      await tester.tap(find.text('Share / Send Backup'));
      await tester.pumpAndSettle();

      expect(repository.shareCalls, 1);
      expect(repository.saveCalls, 0);
      expect(find.text('Backup prepared for sharing'), findsOneWidget);
    });

    testWidgets('share error is shown without a success message', (
      tester,
    ) async {
      final repository = _FakeBackupRepository()
        ..share = () async => throw const FileSystemException('Share failed');
      await _pumpScreen(tester, repository);

      await tester.tap(find.text('Share / Send Backup'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Unable to prepare the file for sharing'),
        findsOneWidget,
      );
      expect(find.text('Backup prepared for sharing'), findsNothing);
      expect(repository.saveCalls, 0);
    });

    testWidgets('rapid taps start only one export operation', (tester) async {
      final saveCompleter = Completer<bool>();
      final repository = _FakeBackupRepository()
        ..save = () => saveCompleter.future;
      await _pumpScreen(tester, repository);

      await tester.tap(find.text('Save Backup Locally'));
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(repository.saveCalls, 1);
      expect(repository.shareCalls, 0);

      saveCompleter.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('Backup saved'), findsOneWidget);
    });

    testWidgets('export actions remain available at 130% text scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpScreen(tester, _FakeBackupRepository(), textScale: 1.3);

      expect(find.text('Save Backup Locally'), findsOneWidget);
      expect(find.text('Share / Send Backup'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
