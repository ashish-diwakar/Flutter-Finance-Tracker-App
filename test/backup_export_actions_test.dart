import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:finance_tracker/features/backup/data/repositories/backup_repository.dart';
import 'package:finance_tracker/features/backup/presentation/providers/backup_repository_provider.dart';
import 'package:finance_tracker/features/backup/presentation/screens/backup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

const _backupJson = '{"format":"finance-tracker-backup","schemaVersion":2}';

class _UnusedIsar extends Fake implements Isar {}

class _FakeBackupRepository extends BackupRepository {
  _FakeBackupRepository() : super(_UnusedIsar());

  Future<bool> Function()? save;
  Future<void> Function()? share;
  int saveCalls = 0;
  int shareCalls = 0;

  @override
  Future<bool> saveBackupLocally() async {
    saveCalls++;
    final saveBackup = save;
    return saveBackup == null ? true : await saveBackup();
  }

  @override
  Future<void> shareBackup() async {
    shareCalls++;
    await share?.call();
  }
}

class _FixedJsonBackupRepository extends BackupRepository {
  _FixedJsonBackupRepository({
    required BackupLocalFileSaver localFileSaver,
    required BackupFileSharer fileSharer,
  }) : super(
         _UnusedIsar(),
         localFileSaver: localFileSaver,
         fileSharer: fileSharer,
       );

  int generationCalls = 0;

  @override
  Future<String> generateBackupJson() async {
    generationCalls++;
    return _backupJson;
  }
}

Future<void> _pumpScreen(
  WidgetTester tester,
  _FakeBackupRepository repository, {
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

      expect(find.textContaining('Unable to save:'), findsOneWidget);
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
        find.textContaining('Unable to prepare backup for sharing:'),
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
