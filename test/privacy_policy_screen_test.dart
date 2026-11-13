import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:finance_tracker/core/widgets/aurora_app_bar.dart';
import 'package:finance_tracker/features/privacy/presentation/screens/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
// Test-only substitute for the platform behind the public launcher API.
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _RecordingLauncher extends UrlLauncherPlatform {
  final launches = <(String, PreferredLaunchMode)>[];
  bool shouldLaunch = false;

  @override
  Null get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launches.add((url, options.mode));
    return shouldLaunch;
  }
}

void main() {
  const policyRevision = '3 March 2025';
  const email = 'support-for-finance-tracker@example-company-support.com';
  const generalWebsite = 'https://www.example-company-software-solutions.com';
  const website =
      'https://www.example-company-software-solutions.com/finance-tracker';

  setUp(() {
    dotenv.testLoad(
      fileInput:
          'APP_NAME=Finance Tracker\n'
          'APP_COMPANY_NAME=Test Company\n'
          'APP_VERSION=1.0.0\n'
          'APP_PRIVACY_POLICY_LAST_UPDATED=$policyRevision\n'
          'APP_COMPANY_WEBSITE=$generalWebsite\n'
          'APP_COMPANY_WEBSITE_FINANCE_TRACKER=$website\n'
          'APP_SUPPORT_EMAIL=$email',
    );
    // These existing branding fields are static finals; initialize from the
    // normal fixture before a test swaps the contact configuration.
    expect(AppConstants.appCompanyName, 'Test Company');
  });

  testWidgets('invalid contact and revision configuration shows unavailable', (
    tester,
  ) async {
    dotenv.testLoad(
      fileInput:
          'APP_SUPPORT_EMAIL=  \nAPP_COMPANY_WEBSITE_FINANCE_TRACKER=javascript:bad\nAPP_PRIVACY_POLICY_LAST_UPDATED=31 February 2026',
    );
    addTearDown(
      () => dotenv.testLoad(
        fileInput:
            'APP_NAME=Finance Tracker\nAPP_COMPANY_NAME=Test Company\nAPP_VERSION=1.0.0\nAPP_PRIVACY_POLICY_LAST_UPDATED=$policyRevision\nAPP_COMPANY_WEBSITE=$generalWebsite\nAPP_COMPANY_WEBSITE_FINANCE_TRACKER=$website\nAPP_SUPPORT_EMAIL=$email',
      ),
    );
    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Support email unavailable'), findsOneWidget);
    expect(find.text('Company website unavailable'), findsWidgets);
    expect(find.text('Email Support'), findsNothing);
    expect(find.text('Last updated: unavailable'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new), findsNothing);
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('Aurora policy scrolls to its footer at ${scale * 100}% text', (
      tester,
    ) async {
      PackageInfo.setMockInitialValues(
        appName: 'Finance Tracker',
        packageName: 'com.example.finance_tracker',
        version: '2.8.5',
        buildNumber: '17',
        buildSignature: '',
      );
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
      expect(find.text('Finance Tracker • App version 2.8.5'), findsOneWidget);
      expect(find.text('Finance Tracker • Version 1.0.0'), findsNothing);
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
      final allTexts = tester.widgetList<Text>(find.byType(Text)).toList();
      final paragraphs = allTexts
          .where((text) => text.textAlign == TextAlign.left)
          .toList();
      expect(paragraphs, hasLength(13));
      const deviceAuthDisclosure =
          'When App Lock is enabled, Finance Tracker requests device authentication on a fresh launch. Changing the App Lock setting also requires successful device authentication. App Lock does not automatically relock the app when returning to an already-running session. The application does not receive or store your fingerprint, face data, PIN, password, or other biometric credentials. Authentication is handled by the operating system.';
      expect(paragraphs[3].data, deviceAuthDisclosure);
      const exportDisclosure =
          "Exporting or sharing financial information may create temporary or cached files on your device. Files saved or shared with other applications or services may remain outside Finance Tracker's control. Finance Tracker does not currently add its own password protection or encryption to exported files.";
      const retentionDisclosure =
          "Financial information is primarily stored in the application's local database. Some deletion actions may mark records as deleted or hide them from normal views without immediately removing them from the database. Deleted or archived records may also be included in exported backups.\n\n"
          "Files previously exported or shared are separate from the application's database and may remain where they were saved or shared. Clearing application data or uninstalling the application does not necessarily remove those external copies or copies retained by operating-system backup services.\n\n"
          'Active recurring schedules may continue generating new financial records until they are disabled or deleted.';
      expect(paragraphs[5].data!.split('\n\n'), hasLength(2));
      expect(paragraphs[5].data!.split('\n\n').last, exportDisclosure);
      expect(paragraphs[9].data, retentionDisclosure);
      expect(
        find.textContaining('they remain on the device until they are deleted'),
        findsNothing,
      );
      for (var i = 0; i < headings.length; i++) {
        final headingIndex = allTexts.indexWhere(
          (text) => text.data == headings[i],
        );
        final paragraphIndex = allTexts.indexOf(paragraphs[i]);
        expect(headingIndex, lessThan(paragraphIndex));
        if (i + 1 < headings.length) {
          final nextHeadingIndex = allTexts.indexWhere(
            (text) => text.data == headings[i + 1],
          );
          expect(paragraphIndex, lessThan(nextHeadingIndex));
        }
        expect(paragraphs[i].data, isNotEmpty);
        expect(paragraphs[i].style?.height, 1.5);
      }
      for (final heading in headings) {
        final target = find.text(heading);
        expect(target, findsOneWidget);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
      }

      for (final text in [
        'Support Email',
        email,
        'Test Company',
        website,
        'Last updated: $policyRevision',
      ]) {
        final target = find.text(text);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
      }
      expect(find.text(generalWebsite), findsNothing);
      final emailCard = find.ancestor(
        of: find.text(email),
        matching: find.byType(Card),
      );
      final companyCard = find.ancestor(
        of: find.text(website),
        matching: find.byType(Card),
      );
      expect(emailCard, findsOneWidget);
      expect(companyCard, findsOneWidget);
      expect(
        tester.widget<Text>(find.text(website)).style?.decoration,
        TextDecoration.underline,
      );
      expect(
        find.descendant(
          of: companyCard,
          matching: find.byIcon(Icons.open_in_new),
        ),
        findsOneWidget,
      );
      expect(tester.getRect(emailCard).left, 20);
      expect(tester.getRect(companyCard).left, 20);
      expect(
        tester.getRect(emailCard).width,
        tester.getRect(companyCard).width,
      );
      for (final value in [email, website]) {
        final target = find.text(value);
        final paragraph = tester.renderObject<RenderParagraph>(target);
        expect(paragraph.didExceedMaxLines, isFalse);
        final lines = paragraph
            .getBoxesForSelection(
              TextSelection(baseOffset: 0, extentOffset: value.length),
            )
            .map((box) => box.top)
            .toSet();
        expect(lines.length, greaterThan(1));
        expect(
          find.ancestor(of: target, matching: find.byType(InkWell)),
          findsOneWidget,
        );
      }
      final footer = find.text('Last updated: $policyRevision');
      expect(tester.getBottomLeft(footer).dy, lessThan(640 - 24));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open policy'), findsOneWidget);
    });
  }

  testWidgets(
    'unavailable package version never uses the policy or env version',
    (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Finance Tracker',
        packageName: 'com.example.finance_tracker',
        version: '',
        buildNumber: '',
        buildSignature: '',
      );
      await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyScreen()));
      await tester.pumpAndSettle();
      expect(
        find.text('Finance Tracker • App version unavailable'),
        findsOneWidget,
      );
      expect(find.textContaining('Version 1.0.0'), findsNothing);
      expect(find.text('Last updated: $policyRevision'), findsOneWidget);
    },
  );

  testWidgets('policy email and website use shared user-initiated actions', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'Finance Tracker',
      packageName: 'com.example.finance_tracker',
      version: '2.8.5',
      buildNumber: '17',
      buildSignature: '',
    );
    final previousLauncher = UrlLauncherPlatform.instance;
    final launcher = _RecordingLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previousLauncher);
    final copied = <String?>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String?);
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyScreen()));
    await tester.pumpAndSettle();
    final emailButton = find.text('Email Support');
    await tester.ensureVisible(emailButton);
    await tester.tap(emailButton);
    await tester.pumpAndSettle();
    expect(copied, isEmpty);
    expect(launcher.launches, hasLength(1));
    final mailto = Uri.parse(launcher.launches.single.$1);
    expect(mailto.scheme, 'mailto');
    expect(mailto.path, email);
    expect(
      mailto.queryParameters['subject'],
      'Finance Tracker - Support Request',
    );
    expect(
      launcher.launches.single.$2,
      PreferredLaunchMode.externalApplication,
    );
    expect(find.text('Copy Email Address'), findsOneWidget);
    await tester.tap(find.text('Copy Email Address'));
    await tester.pumpAndSettle();
    expect(copied, [email]);

    final emailText = find.text(email);
    await tester.ensureVisible(emailText);
    await tester.tap(emailText);
    await tester.pump();
    expect(copied, [email, email]);

    final websiteText = find.text(website);
    await tester.ensureVisible(websiteText);
    await tester.tap(websiteText);
    await tester.pump();
    expect(launcher.launches.last, (
      website,
      PreferredLaunchMode.externalApplication,
    ));
  });
}
