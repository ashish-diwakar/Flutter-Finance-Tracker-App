import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:finance_tracker/features/about/presentation/screens/open_source_licenses_screen.dart';
import 'package:finance_tracker/features/about/presentation/screens/about_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
// Test-only substitute for the launcher behind the public url_launcher API.
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _RecordingLauncher extends UrlLauncherPlatform {
  final launches = <(String, PreferredLaunchMode)>[];

  @override
  Null get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launches.add((url, options.mode));
    return false;
  }
}

void main() {
  setUpAll(() {
    dotenv.testLoad(
      fileInput:
          'APP_VERSION=1.0.0\nAPP_COMPANY_WEBSITE=https://www.diwakarsoftwaresolutions.com',
    );
    LicenseRegistry.addLicense(() async* {
      yield const LicenseEntryWithLineBreaks([
        'Aurora test package',
      ], 'First synthetic attribution.\n\nSecond synthetic attribution.');
    });
  });

  testWidgets('shows a neutral fallback when package info is unavailable', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'Finance Tracker',
      packageName: 'com.example.finance_tracker',
      version: '',
      buildNumber: '',
      buildSignature: '',
    );
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Version unavailable'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets(
      'About cards align and scroll at ${(scale * 100).round()}% on a narrow screen',
      (tester) async {
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
            home: const AboutScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Version 2.8.5 (Build 17)'), findsOneWidget);
        expect(find.text('Version 1.0.0'), findsNothing);
        final description = tester.widget<Text>(
          find.text(AppConstants.appDescription),
        );
        expect(description.textAlign, TextAlign.left);
        final cards = find.byType(Card);
        expect(cards, findsNWidgets(4));
        final expected = tester.getRect(cards.first);
        for (var index = 1; index < 4; index++) {
          final rect = tester.getRect(cards.at(index));
          expect(rect.left, expected.left);
          expect(rect.right, expected.right);
        }
        for (final label in [
          'Company Website',
          AppConstants.appCompanyWebsite,
          'Open Source Licenses',
          '© ${DateTime.now().year} ${AppConstants.appCompanyName}',
          'All rights reserved.',
        ]) {
          final target = find.text(label);
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          expect(target.hitTestable(), findsOneWidget);
        }
        final url = find.text(AppConstants.appCompanyWebsite);
        expect(
          tester.renderObject<RenderParagraph>(url).didExceedMaxLines,
          isFalse,
        );
        expect(tester.widget<Text>(url).overflow, isNot(TextOverflow.ellipsis));
        expect(
          tester.getBottomLeft(find.text('All rights reserved.')).dy,
          lessThanOrEqualTo(640 - 24),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('website uses the configured URL and licenses opens its route', (
    tester,
  ) async {
    final original = UrlLauncherPlatform.instance;
    final launcher = _RecordingLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = original);
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.pumpAndSettle();

    expect(launcher.launches, isEmpty);
    expect(find.byType(OpenSourceLicensesScreen), findsNothing);
    final website = find.widgetWithText(ListTile, 'Company Website');
    await tester.ensureVisible(website);
    await tester.tap(website);
    await tester.pumpAndSettle();
    expect(launcher.launches, [
      (AppConstants.appCompanyWebsite, PreferredLaunchMode.externalApplication),
    ]);
    expect(find.text('Unable to open the website.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final licenses = find.widgetWithText(ListTile, 'Open Source Licenses');
    await tester.ensureVisible(licenses);
    await tester.tap(licenses);
    await tester.pumpAndSettle();
    expect(find.byType(OpenSourceLicensesScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);
    expect(launcher.launches, hasLength(1));
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets(
      'registry licenses retain details and Back at ${scale}x text scale',
      (tester) async {
        PackageInfo.setMockInitialValues(
          appName: 'Finance Tracker',
          packageName: 'com.example.finance_tracker',
          version: '9.8.7',
          buildNumber: '42',
          buildSignature: '',
        );
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
            home: const AboutScreen(),
          ),
        );
        await tester.pumpAndSettle();

        final entry = find.widgetWithText(ListTile, 'Open Source Licenses');
        await tester.ensureVisible(entry);
        await tester.tap(entry);
        await tester.pumpAndSettle();

        expect(find.text('Version 9.8.7'), findsOneWidget);
        expect(find.text('Open Source Licenses'), findsOneWidget);
        expect(find.text('Powered by Flutter'), findsOneWidget);
        expect(find.text('Aurora test package'), findsOneWidget);

        await tester.tap(find.text('Aurora test package'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('First synthetic attribution.'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Second synthetic attribution.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Aurora test package'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(AboutScreen), findsOneWidget);
        expect(find.byType(OpenSourceLicensesScreen), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
