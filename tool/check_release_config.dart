import 'dart:io';

import 'package:finance_tracker/core/config/release_configuration.dart';

/// Returns only key names and reasons, never configured values.
List<String> validateEnvironment(String? contents) {
  if (contents == null) return ['.env: required asset is missing'];
  final values = <String, String>{};
  final errors = <String>[];
  for (final line in contents.split(RegExp(r'\r?\n'))) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final match = RegExp(
      r'^(?:export\s+)?([A-Za-z_][A-Za-z_0-9]*)\s*=\s*(.*)$',
    ).firstMatch(trimmed);
    if (match == null) {
      errors.add('.env: malformed declaration');
      continue;
    }
    final key = match[1]!;
    if (!ReleaseConfiguration.requiredKeys.contains(key)) continue;
    if (values.containsKey(key)) errors.add('$key: duplicate declaration');
    var value = match[2]!;
    if (value.startsWith('"') || value.startsWith("'")) {
      final quote = value[0];
      final end = value.indexOf(quote, 1);
      if (end < 0 ||
          (value.substring(end + 1).trim().isNotEmpty &&
              !value.substring(end + 1).trim().startsWith('#'))) {
        errors.add('$key: malformed quoted value');
        value = '';
      } else {
        value = value.substring(1, end);
      }
    } else {
      value = value.split(RegExp(r'\s+#')).first;
    }
    values[key] = value;
  }
  for (final key in ReleaseConfiguration.requiredKeys) {
    final error = ReleaseConfiguration.errorFor(key, values[key]);
    if (error != null) errors.add('$key: $error');
  }
  return errors;
}

void main(List<String> args) {
  if (args.length > 1) {
    stderr.writeln('Usage: dart run tool/check_release_config.dart [env-file]');
    exitCode = 1;
    return;
  }
  final errors = <String>[];
  try {
    final env = File(args.isEmpty ? '.env' : args.single);
    errors.addAll(
      validateEnvironment(env.existsSync() ? env.readAsStringSync() : null),
    );
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync() ||
        !RegExp(r'^\s+-\s+\.env\s*$', multiLine: true)
            .hasMatch(pubspec.readAsStringSync())) {
      errors.add('pubspec.yaml: declare .env in Flutter assets');
    }
  } on FileSystemException {
    errors.add('configuration: unable to read required files');
  }
  if (errors.isEmpty) {
    stdout.writeln(
      'PASS: required configuration formats and .env asset declaration',
    );
  } else {
    for (final error in errors) {
      stderr.writeln('FAIL: $error');
    }
    exitCode = 1;
  }
}
