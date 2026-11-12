import 'dart:io';

import 'package:finance_tracker/features/export/data/services/export_temporary_files.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  late Directory cache;
  late ExportTemporaryFiles temporaryFiles;

  setUp(() async {
    cache = await Directory.systemTemp.createTemp('synthetic_export_test_');
    temporaryFiles = ExportTemporaryFiles(cacheDirectory: () async => cache);
  });
  tearDown(() async {
    if (await cache.exists()) await cache.delete(recursive: true);
  });

  test(
    'overlapping CSV and PDF source files remain distinct and readable',
    () async {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(build: (_) => pw.Text('Synthetic report')));
      final pdfBytes = await pdf.save();
      for (final (name, contents) in [
        ('transactions.csv', 'Date,Amount\n2026-01-01,10'.codeUnits),
        ('finance_report.pdf', pdfBytes),
      ]) {
        final [first, second] = await Future.wait([
          temporaryFiles.createSource(name),
          temporaryFiles.createSource(name),
        ]);
        await first.writeAsBytes(contents);
        await second.writeAsBytes(contents);
        expect(first.path, isNot(second.path));
        expect(first.uri.pathSegments.last, name);
        expect(await first.readAsBytes(), contents);
        expect(await second.readAsBytes(), contents);

        // A consumer can read a source while another operation is active.
        await temporaryFiles.cleanSource(first);
        expect(await first.exists(), isFalse);
        expect(await second.readAsBytes(), contents);
        await temporaryFiles.cleanSource(second);
      }
    },
  );

  test('failure cleanup is scoped to its own source', () async {
    final first = await temporaryFiles.createSource('transactions.csv');
    final second = await temporaryFiles.createSource('transactions.csv');
    final unrelated = File(
      '${cache.path}${Platform.pathSeparator}unrelated.txt',
    );
    await first.writeAsString('first');
    await second.writeAsString('second');
    await unrelated.writeAsString('keep');

    try {
      expect(await first.readAsString(), 'first');
      throw StateError('synthetic share cancellation');
    } on StateError {
      await temporaryFiles.cleanSource(first);
    }
    expect(await first.exists(), isFalse);
    expect(await second.readAsString(), 'second');
    expect(await unrelated.readAsString(), 'keep');
    await temporaryFiles.cleanSource(unrelated);
    expect(await unrelated.exists(), isTrue);
    await temporaryFiles.cleanSource(second);
  });

  test(
    'user-selected destination and unrelated temporary files survive',
    () async {
      final userDirectory = await Directory.systemTemp.createTemp(
        'synthetic_user_destination_',
      );
      addTearDown(() async {
        if (await userDirectory.exists()) {
          await userDirectory.delete(recursive: true);
        }
      });
      final userOperation = Directory(
        '${userDirectory.path}${Platform.pathSeparator}operation_user',
      );
      await userOperation.create();
      final userExport = File(
        '${userOperation.path}${Platform.pathSeparator}transactions.csv',
      );
      final neighbor = File(
        '${userOperation.path}${Platform.pathSeparator}unrelated.txt',
      );
      await userExport.writeAsString('user-selected');
      await neighbor.writeAsString('keep');

      await temporaryFiles.cleanSource(userExport);

      expect(await userExport.readAsString(), 'user-selected');
      expect(await neighbor.readAsString(), 'keep');
    },
  );

  test('cleanup failure does not replace a primary share error', () async {
    var calls = 0;
    final failingCleanup = ExportTemporaryFiles(
      cacheDirectory: () async {
        if (calls++ == 0) return cache;
        throw const FileSystemException('synthetic cleanup failure');
      },
    );
    final source = await failingCleanup.createSource('transactions.csv');
    await source.writeAsString('synthetic');

    Future<void> failShare() async {
      try {
        expect(await source.readAsString(), 'synthetic');
        throw StateError('primary share error');
      } finally {
        await failingCleanup.cleanSource(source);
      }
    }

    await expectLater(failShare(), throwsA(isA<StateError>()));
    expect(await source.exists(), isTrue);
  });
}
