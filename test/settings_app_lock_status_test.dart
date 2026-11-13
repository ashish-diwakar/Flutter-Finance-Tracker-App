import 'package:finance_tracker/features/about/presentation/screens/about_screen.dart';
import 'package:finance_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(fileInput: 'APP_NAME=Finance Tracker');
    PackageInfo.setMockInitialValues(
      appName: 'Finance Tracker',
      packageName: 'example.test',
      version: '1.2.3',
      buildNumber: '4',
      buildSignature: '',
    );
  });

  for (final enabled in [true, false]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets(
        'App Lock $enabled status stays read-only at ${scale}x text scale',
        (tester) async {
          if (!enabled) {
            SharedPreferences.setMockInitialValues({'app_lock_enabled': false});
          }
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: const SettingsScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final status = find.byKey(const Key('app-lock-status'));
          await tester.scrollUntilVisible(status, 200);
          await tester.ensureVisible(status);
          await tester.pumpAndSettle();
          expect(find.text('Security'), findsOneWidget);
          expect(find.text('App Lock'), findsOneWidget);
          expect(find.text(enabled ? 'On · required' : 'Off'), findsOneWidget);
          expect(
            tester
                .widget<Icon>(
                  find.descendant(of: status, matching: find.byType(Icon)),
                )
                .icon,
            enabled ? Icons.lock_outline : Icons.lock_open_outlined,
          );
          expect(
            find.text(
              enabled
                  ? 'A fresh launch requires device authentication to enter Finance Tracker.'
                  : 'A fresh launch does not require device authentication.',
            ),
            findsOneWidget,
          );
          expect(
            find.text('Changing this setting is not available yet.'),
            findsOneWidget,
          );
          expect(
            find.text(
              'When enabled, App Lock limits entry to the app. It does not encrypt the local database or exported JSON backups.',
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(of: status, matching: find.byType(Switch)),
            findsNothing,
          );
          expect(
            find.descendant(of: status, matching: find.byType(InkWell)),
            findsNothing,
          );
          final semantics = tester.ensureSemantics();
          expect(
            tester
                .getSemantics(find.byType(MergeSemantics))
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isFalse,
          );
          semantics.dispose();
          await tester.tapAt(tester.getCenter(status));
          await tester.pumpAndSettle();
          expect(find.byType(SettingsScreen), findsOneWidget);
          expect(
            (await SharedPreferences.getInstance()).getBool('app_lock_enabled'),
            enabled ? isNull : isFalse,
          );

          final about = find.widgetWithText(ListTile, 'About Finance Tracker');
          await tester.scrollUntilVisible(about, 300);
          await tester.ensureVisible(about);
          await tester.pumpAndSettle();
          final routeSemantics = tester.ensureSemantics();
          expect(
            tester
                .getSemantics(about)
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isTrue,
          );
          routeSemantics.dispose();
          await tester.tap(about);
          await tester.pumpAndSettle();
          expect(find.byType(AboutScreen), findsOneWidget);
          await tester.pageBack();
          await tester.pumpAndSettle();
          expect(find.byType(SettingsScreen), findsOneWidget);
          final lastOption = find.widgetWithText(
            ListTile,
            'Open Source Licenses',
          );
          await tester.scrollUntilVisible(lastOption, 300);
          await tester.ensureVisible(lastOption);
          await tester.pumpAndSettle();
          expect(lastOption.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
