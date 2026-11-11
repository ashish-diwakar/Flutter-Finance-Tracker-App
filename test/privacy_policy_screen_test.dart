import 'package:finance_tracker/core/widgets/aurora_app_bar.dart';
import 'package:finance_tracker/features/privacy/presentation/screens/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(
      fileInput:
          'APP_NAME=Finance Tracker\n'
          'APP_COMPANY_NAME=Test Company\n'
          'APP_VERSION=1.0.0\n'
          'APP_COMPANY_WEBSITE=https://example.com\n'
          'APP_SUPPORT_EMAIL=support@example.com',
    );
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('Aurora policy scrolls to its footer at ${scale * 100}% text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              viewPadding: const EdgeInsets.only(bottom: 24),
            ),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
                child: const Text('Open policy'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open policy'));
      await tester.pumpAndSettle();

      expect(find.byType(AuroraAppBar), findsOneWidget);
      expect(find.text('Privacy Policy'), findsNWidgets(2));
      final gradient = find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient is LinearGradient,
      );
      final scroll = find.byType(SingleChildScrollView);
      expect(tester.getRect(gradient), tester.getRect(scroll));
      final gradientValue =
          (tester.widget<DecoratedBox>(gradient).decoration as BoxDecoration)
                  .gradient!
              as LinearGradient;
      expect(gradientValue.colors, const [
        Color(0xFFB6D7CC),
        Color(0xFFDAEDE5),
        Color(0xFFF8FCFA),
      ]);

      final headings = [
        '1. Introduction',
        '2. Financial Information',
        '3. Local Storage',
        '4. Device Authentication',
        '5. Notifications',
        '6. Backup, Export and Sharing',
        '7. Network Connectivity',
        '8. Data Sharing',
        '9. Data Security',
        '10. Data Retention and Deletion',
        "11. Children's Privacy",
        '12. Changes to This Privacy Policy',
        '13. Contact Us',
      ];
      for (final heading in headings) {
        final target = find.text(heading);
        expect(target, findsOneWidget);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
      }

      for (final text in [
        'Support Email',
        'support@example.com',
        'Test Company',
        'https://example.com',
        'Last updated: ${DateTime.now().year}',
      ]) {
        final target = find.text(text);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
      }
      final footer = find.text('Last updated: ${DateTime.now().year}');
      expect(tester.getBottomLeft(footer).dy, lessThan(640 - 24));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open policy'), findsOneWidget);
    });
  }
}
