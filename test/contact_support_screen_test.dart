import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:finance_tracker/core/widgets/aurora_app_bar.dart';
import 'package:finance_tracker/features/support/presentation/screens/contact_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Aurora support page fills the viewport and scrolls at 130%', (
    tester,
  ) async {
    dotenv.testLoad(fileInput: '');
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.3),
            viewPadding: const EdgeInsets.only(bottom: 24),
          ),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ContactSupportScreen(),
                ),
              ),
              child: const Text('Open support'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open support'));
    await tester.pumpAndSettle();

    expect(find.byType(AuroraAppBar), findsOneWidget);
    expect(find.text('Contact & Support'), findsOneWidget);
    expect(find.text('Need Help?'), findsOneWidget);
    for (final text in [
      AppConstants.appSupportEmail,
      'Contact Support',
      'When contacting support',
      AppConstants.appCompanyName,
      AppConstants.appCompanyWebsite,
    ]) {
      final target = find.text(text);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      expect(target.hitTestable(), findsOneWidget);
    }

    tester.view.physicalSize = const Size(400, 2200);
    await tester.pumpAndSettle();
    final gradient = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).gradient is LinearGradient,
    );
    final scroll = find.byType(SingleChildScrollView);
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    expect(position.maxScrollExtent, 0);
    expect(tester.getRect(gradient), tester.getRect(scroll));
    expect(tester.getBottomLeft(gradient).dy, 2200);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open support'), findsOneWidget);
  });
}
