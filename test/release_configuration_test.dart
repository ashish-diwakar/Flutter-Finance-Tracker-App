import 'package:finance_tracker/core/config/release_configuration.dart';
import 'package:finance_tracker/features/support/presentation/support_contact_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// Test-only platform substitute.
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../tool/check_release_config.dart' as preflight;

class _Launcher extends UrlLauncherPlatform {
  int calls = 0;
  @override
  Null get linkDelegate => null;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    calls++;
    return false;
  }
}

void main() {
  test(
    'email normalization rejects injection and accepts common mailboxes',
    () {
      for (final bad in [
        null,
        '',
        '  ',
        'a@b',
        'a@b..com',
        'a@example.com,b@example.com',
        'a@example.com;b@example.com',
        'a b@example.com',
        'a@example.com\nsubject=bad',
        'a?x@example.com',
      ]) {
        expect(ReleaseConfiguration.email(bad), isEmpty);
      }
      expect(
        ReleaseConfiguration.email('  name+tag@example.com  '),
        'name+tag@example.com',
      );
    },
  );

  test('websites reject unsafe schemes and malformed hosts', () {
    for (final bad in [
      null,
      '',
      '  ',
      'http://example.com',
      'javascript:alert(1)',
      'file:///tmp/a',
      'https://user@example.com',
      'https://bad..com',
      'https://-bad.com',
      'https://example.com/a b',
      'https://example.com\n/a',
    ]) {
      expect(ReleaseConfiguration.website(bad), isEmpty);
    }
    expect(
      ReleaseConfiguration.website(' https://example.com/finance-tracker '),
      'https://example.com/finance-tracker',
    );
  });

  test('revision requires a real fixed date', () {
    for (final bad in [
      null,
      '',
      ' ',
      '31 February 2026',
      '29 February 2025',
      '2026-11-12',
      '12 Foo 2026',
      '12 November 0000',
    ]) {
      expect(ReleaseConfiguration.revision(bad), isEmpty);
    }
    expect(
      ReleaseConfiguration.revision(' 12 November 2026 '),
      '12 November 2026',
    );
    expect(
      ReleaseConfiguration.revision('29 February 2024'),
      '29 February 2024',
    );
  });

  test('preflight checks synthetic missing, duplicate and malformed values', () {
    const good =
        'APP_SUPPORT_EMAIL=support@example.com\n'
        'APP_COMPANY_WEBSITE=https://example.com\n'
        'APP_COMPANY_WEBSITE_FINANCE_TRACKER=https://example.com/finance-tracker\n'
        'APP_PRIVACY_POLICY_LAST_UPDATED=12 November 2026\n';
    expect(preflight.validateEnvironment(good), isEmpty);
    expect(preflight.validateEnvironment(null), isNotEmpty);
    final invalid = preflight.validateEnvironment(
      '$good\nAPP_SUPPORT_EMAIL=bad,other@example.com\nAPP_PRIVACY_POLICY_LAST_UPDATED=31 February 2026',
    );
    expect(
      invalid.any((error) => error.contains('duplicate declaration')),
      isTrue,
    );
    expect(
      invalid.any((error) => error.contains('APP_PRIVACY_POLICY_LAST_UPDATED')),
      isTrue,
    );
    expect(invalid.join(), isNot(contains('bad,other@example.com')));
  });

  testWidgets('invalid contact actions never launch or copy', (tester) async {
    final previous = UrlLauncherPlatform.instance;
    final launcher = _Launcher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previous);
    var clipboardCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') clipboardCalls++;
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Ready'))),
    );
    const actions = SupportContactActions(
      supportEmail: 'a@example.com,b@example.com',
      companyWebsite: 'http://example.com',
    );
    final context = tester.element(find.byType(Scaffold));
    await actions.copySupportEmail(context);
    await actions.openSupportEmail(context);
    await actions.openCompanyWebsite(context);
    expect(clipboardCalls, 0);
    expect(launcher.calls, 0);
  });
}
