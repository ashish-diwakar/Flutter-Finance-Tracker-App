import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:finance_tracker/core/widgets/aurora_app_bar.dart';
import 'package:finance_tracker/features/support/presentation/screens/contact_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
// Test-only substitute for the platform behind the public url_launcher API.
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _RecordingLauncher extends UrlLauncherPlatform {
  final launches = <(String, PreferredLaunchMode)>[];
  bool shouldLaunch = false;
  bool throwOnLaunch = false;

  @override
  Null get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launches.add((url, options.mode));
    if (throwOnLaunch) throw PlatformException(code: 'no-email-handler');
    return shouldLaunch;
  }
}

void main() {
  const email = 'support-for-finance-tracker@example-company-support.com';
  const website = 'https://www.diwakarsoftwaresolutions.com/finance-tracker';

  setUpAll(() {
    dotenv.testLoad(
      fileInput:
          'APP_SUPPORT_EMAIL=$email\n'
          'APP_COMPANY_WEBSITE=https://www.diwakarsoftwaresolutions.com\n'
          'APP_COMPANY_WEBSITE_FINANCE_TRACKER=$website',
    );
  });

  testWidgets('company website opens the Finance Tracker URL on tap only', (
    tester,
  ) async {
    final previousLauncher = UrlLauncherPlatform.instance;
    final launcher = _RecordingLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previousLauncher);

    await tester.pumpWidget(const MaterialApp(home: ContactSupportScreen()));
    await tester.pumpAndSettle();
    expect(launcher.launches, isEmpty);

    final link = find.text(website);
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(launcher.launches, [
      (website, PreferredLaunchMode.externalApplication),
    ]);
    expect(find.text('Unable to open the website.'), findsOneWidget);
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets(
      'Aurora support page fills the viewport and scrolls at ${(scale * 100).round()}%',
      (tester) async {
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
          email,
          'Email Support',
          'When contacting support',
          'Describe the problem clearly.',
          'Mention your device model.',
          'Include your Android version.',
          'Include the app version.',
          'Explain the steps that caused the issue.',
          AppConstants.appCompanyName,
          website,
        ]) {
          final target = text == 'Email Support'
              ? find.text(text).last
              : find.text(text);
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          expect(target.hitTestable(), findsOneWidget);
        }
        expect(find.text(AppConstants.appCompanyWebsite), findsNothing);
        final emailCard = tester.widget<Card>(
          find
              .ancestor(of: find.text(email), matching: find.byType(Card))
              .first,
        );
        final guidanceCard = tester.widget<Card>(
          find
              .ancestor(
                of: find.text('When contacting support'),
                matching: find.byType(Card),
              )
              .first,
        );
        final companyCard = tester.widget<Card>(
          find
              .ancestor(of: find.text(website), matching: find.byType(Card))
              .first,
        );
        expect(guidanceCard.color, emailCard.color);
        expect(companyCard.color, emailCard.color);
        expect(guidanceCard.shape, emailCard.shape);
        expect(companyCard.shape, emailCard.shape);
        for (final text in [email, website]) {
          final paragraph = tester.renderObject<RenderParagraph>(
            find.text(text),
          );
          expect(paragraph.didExceedMaxLines, isFalse);
          final lines = paragraph
              .getBoxesForSelection(
                TextSelection(baseOffset: 0, extentOffset: text.length),
              )
              .map((box) => box.top)
              .toSet();
          expect(lines.length, greaterThan(1));
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
      },
    );
  }

  testWidgets('primary action opens a pre-addressed unsent email draft', (
    tester,
  ) async {
    final previousLauncher = UrlLauncherPlatform.instance;
    final launcher = _RecordingLauncher()..shouldLaunch = true;
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previousLauncher);

    final calls = <MethodCall>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method != 'Clipboard.setData') return null;
      calls.add(call);
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(const MaterialApp(home: ContactSupportScreen()));
    await tester.pumpAndSettle();
    expect(find.text(email), findsOneWidget);
    final card = find.byTooltip('Copy support email address');
    final cardIcon = find.descendant(
      of: card,
      matching: find.byIcon(Icons.copy_outlined),
    );
    final primary = find.text('Email Support').last;
    expect(find.text('Contact Support'), findsNothing);
    expect(launcher.launches, isEmpty);
    await tester.tap(primary);
    await tester.pumpAndSettle();
    expect(launcher.launches, [
      (
        'mailto:$email?subject=Finance%20Tracker%20-%20Support%20Request',
        PreferredLaunchMode.externalApplication,
      ),
    ]);
    expect(calls, isEmpty);
    expect(
      find.text('No email app available. You can copy the address.'),
      findsNothing,
    );

    await tester.tap(cardIcon);
    await tester.pumpAndSettle();
    expect(find.text('Support email copied'), findsOneWidget);
    expect(calls.map((call) => call.method), ['Clipboard.setData']);
    expect(calls.single.arguments, {'text': email});
  });

  testWidgets('failed mail launch offers explicit copy fallback', (
    tester,
  ) async {
    final previousLauncher = UrlLauncherPlatform.instance;
    final launcher = _RecordingLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previousLauncher);

    final calls = <MethodCall>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') calls.add(call);
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(const MaterialApp(home: ContactSupportScreen()));
    await tester.pumpAndSettle();
    final primary = find.text('Email Support').last;
    await tester.tap(primary);
    await tester.pumpAndSettle();
    expect(launcher.launches, hasLength(1));
    expect(calls, isEmpty);
    expect(
      find.text('No email app available. You can copy the address.'),
      findsOneWidget,
    );
    final fallback = find.text('Copy Email Address');
    expect(fallback, findsOneWidget);
    await tester.tap(fallback);
    await tester.pumpAndSettle();
    expect(calls, hasLength(1));
    expect(calls.single.arguments, {'text': email});
    expect(find.text('Support email copied'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    launcher.throwOnLaunch = true;
    await tester.tap(primary);
    await tester.pumpAndSettle();
    expect(launcher.launches, hasLength(2));
    expect(calls, hasLength(1));
    expect(
      find.text('No email app available. You can copy the address.'),
      findsOneWidget,
    );
  });
}
