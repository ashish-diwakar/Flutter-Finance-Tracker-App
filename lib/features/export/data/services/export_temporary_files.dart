import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../core/services/logger_service.dart';

/// Owns only per-export source files under the app's temporary directory.
class ExportTemporaryFiles {
  ExportTemporaryFiles({Future<Directory> Function()? cacheDirectory})
    : _cacheDirectory = cacheDirectory ?? getTemporaryDirectory;

  final Future<Directory> Function() _cacheDirectory;

  Future<File> createSource(String fileName) async {
    if (fileName != 'transactions.csv' && fileName != 'finance_report.pdf') {
      throw ArgumentError.value(fileName, 'fileName');
    }
    final cache = await _cacheDirectory();
    final root = Directory(
      '${cache.path}${Platform.pathSeparator}finance_tracker_exports',
    );
    await root.create(recursive: true);
    final operation = await root.createTemp('operation_');
    return File('${operation.path}${Platform.pathSeparator}$fileName');
  }

  Future<void> cleanSource(File source) async {
    try {
      final cache = await _cacheDirectory();
      final root = Directory(
        '${cache.path}${Platform.pathSeparator}finance_tracker_exports',
      );
      final operation = source.parent;
      if (operation.parent.absolute.path != root.absolute.path ||
          !operation.uri.pathSegments
              .where((part) => part.isNotEmpty)
              .last
              .startsWith('operation_') ||
          (source.uri.pathSegments.last != 'transactions.csv' &&
              source.uri.pathSegments.last != 'finance_report.pdf')) {
        LoggerService.error('Refused to clean an unowned export source.');
        return;
      }
      if (await operation.exists()) await operation.delete(recursive: true);
    } catch (_) {
      LoggerService.error('Unable to clean temporary export source.');
    }
  }
}
