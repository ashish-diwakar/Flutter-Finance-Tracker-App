import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:finance_tracker/features/about/presentation/screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'APP_VERSION=1.0.0');
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

  testWidgets('shows package version and scrolls at 130% on a narrow screen', (
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
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
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
    for (final label in [
      'Company Website',
      'Open Source Licenses',
      'All rights reserved.',
    ]) {
      final target = find.text(label);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      expect(target.hitTestable(), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
