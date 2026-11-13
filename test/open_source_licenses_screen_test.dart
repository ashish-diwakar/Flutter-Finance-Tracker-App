import 'dart:async';

import 'package:finance_tracker/features/about/presentation/screens/open_source_licenses_screen.dart';
import 'package:finance_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const shared = LicenseEntryWithLineBreaks([
    'Zulu',
    'Alpha',
  ], 'Heading\n\n    Indented attribution.\n\nFinal attribution.');
  const extra = LicenseEntryWithLineBreaks([
    'Alpha',
  ], 'Additional complete license.');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(fileInput: 'APP_NAME=Finance Tracker');
    PackageInfo.setMockInitialValues(
      appName: 'Finance Tracker',
      packageName: 'example.test',
      version: '7.6.5',
      buildNumber: '9',
      buildSignature: '',
    );
  });

  testWidgets(
    'Settings shortcut opens Aurora licenses and returns to Settings',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );
      await tester.pumpAndSettle();
      final shortcut = find.widgetWithText(ListTile, 'Open Source Licenses');
      await tester.scrollUntilVisible(shortcut, 300);
      await tester.ensureVisible(shortcut);
      await tester.pumpAndSettle();
      await tester.tap(shortcut);
      await tester.pumpAndSettle();
      expect(find.byType(OpenSourceLicensesScreen), findsOneWidget);
      expect(find.byType(LicensePage), findsNothing);
      expect(find.text('Version 7.6.5'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(OpenSourceLicensesScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'registry bindings match stock first-package ordering and entry counts',
    () async {
      final data = await RegistryLicenses.load(
        Stream.fromIterable([shared, extra]),
      );
      expect(data.packages, ['Zulu', 'Alpha']);
      expect(data.bindings, {
        'Zulu': [0],
        'Alpha': [0, 1],
      });
      final original = shared.paragraphs.toList();
      expect(
        data.paragraphs[0].map((p) => (p.text, p.indent)),
        original.map((p) => (p.text, p.indent)),
      );
      expect(data.paragraphs[1].single.text, 'Additional complete license.');
    },
  );

  for (final scale in [1.0, 1.3]) {
    testWidgets('complete shared licenses scroll and return at $scale scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: OpenSourceLicensesScreen(
            licenses: () => Stream.fromIterable([
              shared,
              extra,
              LicenseEntryWithLineBreaks(
                ['Alpha'],
                '${List.filled(30, 'Long synthetic legal paragraph.').join('\n\n')}\n\nEnd of complete license.',
              ),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Version 7.6.5'), findsOneWidget);
      final tile = find.widgetWithText(ListTile, 'Alpha');
      await tester.scrollUntilVisible(tile, 150);
      expect(find.text('3 licenses.'), findsOneWidget);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.byType(SelectionArea), findsOneWidget);
      expect(find.text('Indented attribution.'), findsOneWidget);
      expect(find.text('Additional complete license.'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('End of complete license.'),
        300,
      );
      expect(
        find.text('End of complete license.').hitTestable(),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Open Source Licenses'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('loading and registry failures retain background and retry', (
    tester,
  ) async {
    final pending = StreamController<LicenseEntry>();
    addTearDown(pending.close);
    await tester.pumpWidget(
      MaterialApp(
        home: OpenSourceLicensesScreen(licenses: () => pending.stream),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.addError(StateError('synthetic registry failure'));
    await tester.pumpAndSettle();
    expect(
      find.text('Unable to load licenses. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
