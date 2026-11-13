import 'dart:async';
import 'dart:collection';

import 'package:finance_tracker/features/security/presentation/providers/app_lock_enabled_provider.dart';
import 'package:finance_tracker/features/security/presentation/providers/app_lock_provider.dart';
import 'package:finance_tracker/features/security/presentation/providers/post_unlock_startup_provider.dart';
import 'package:finance_tracker/features/security/presentation/screens/app_entry_gate.dart';
import 'package:finance_tracker/features/security/presentation/screens/app_lock_screen.dart';
import 'package:finance_tracker/features/security/services/app_lock_service.dart';
import 'package:finance_tracker/features/security/services/post_unlock_startup_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Test-only platform substitute for an unreadable preference store.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _Auth extends AppLockService {
  _Auth(Iterable<Future<bool> Function()> responses)
    : _responses = Queue.of(responses);

  final Queue<Future<bool> Function()> _responses;
  int calls = 0;

  @override
  Future<bool> authenticate() {
    calls++;
    return _responses.removeFirst()();
  }
}

class _Startup implements PostUnlockStartup {
  _Startup(Iterable<Future<void> Function()> responses)
    : _responses = Queue.of(responses);

  final Queue<Future<void> Function()> _responses;
  int calls = 0;

  @override
  Future<void> run() {
    calls++;
    return _responses.removeFirst()();
  }
}

class _UnreadableStore extends InMemorySharedPreferencesStore {
  _UnreadableStore() : super.empty();

  @override
  Future<Map<String, Object>> getAll() async =>
      throw StateError('synthetic preference read failure');
}

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'APP_NAME=Finance Tracker');
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpGate(
    WidgetTester tester,
    _Auth auth,
    _Startup startup, {
    List<Override> extraOverrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockServiceProvider.overrideWithValue(auth),
          postUnlockStartupProvider.overrideWithValue(startup),
          ...extraOverrides,
        ],
        child: const MaterialApp(
          home: AppEntryGate(unlockedScreen: Text('Synthetic main screen')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('preference loading shows no financial or unlocked content', (
    tester,
  ) async {
    final preference = Completer<bool>();
    final auth = _Auth([]);
    final startup = _Startup([() async {}]);
    await pumpGate(
      tester,
      auth,
      startup,
      extraOverrides: [
        appLockEnabledProvider.overrideWith((ref) => preference.future),
      ],
    );
    expect(find.text('Checking app security…'), findsOneWidget);
    expect(find.text('Synthetic main screen'), findsNothing);
    expect(auth.calls, 0);
    expect(startup.calls, 0);

    preference.complete(false);
    await tester.pumpAndSettle();
    expect(find.text('Synthetic main screen'), findsOneWidget);
    expect(startup.calls, 1);
  });

  for (final (description, value) in <(String, Map<String, Object>)>[
    ('missing', {}),
    ('stored true', {'app_lock_enabled': true}),
    ('malformed', {'app_lock_enabled': 'false'}),
  ]) {
    testWidgets('$description preference requires auth before startup', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(value);
      final result = Completer<bool>();
      final auth = _Auth([() => result.future]);
      final startup = _Startup([() async {}]);
      await pumpGate(tester, auth, startup);

      expect(find.byType(AppLockScreen), findsOneWidget);
      expect(auth.calls, 1);
      expect(startup.calls, 0);
      expect(find.text('Synthetic main screen'), findsNothing);

      result.complete(false);
      await tester.pumpAndSettle();
      expect(find.text('Authentication failed or cancelled.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(startup.calls, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('unreadable preference fails closed to authentication', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final originalStore = SharedPreferencesStorePlatform.instance;
    SharedPreferencesStorePlatform.instance = _UnreadableStore();
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = originalStore;
      SharedPreferences.setMockInitialValues({});
    });
    final result = Completer<bool>();
    final auth = _Auth([() => result.future]);
    final startup = _Startup([() async {}]);
    await pumpGate(tester, auth, startup);

    expect(find.byType(AppLockScreen), findsOneWidget);
    expect(auth.calls, 1);
    expect(startup.calls, 0);
    result.complete(false);
    await tester.pumpAndSettle();
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('stored true awaits auth and one startup run before main', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_lock_enabled': true});
    final authResult = Completer<bool>();
    final startupResult = Completer<void>();
    final auth = _Auth([() => authResult.future]);
    final startup = _Startup([() => startupResult.future]);
    await pumpGate(tester, auth, startup);
    expect(startup.calls, 0);

    authResult.complete(true);
    await tester.pump();
    expect(startup.calls, 1);
    expect(find.text('Synthetic main screen'), findsNothing);

    startupResult.complete();
    await tester.pumpAndSettle();
    expect(find.text('Synthetic main screen'), findsOneWidget);
    expect(startup.calls, 1);
  });

  testWidgets('stored false skips auth and awaits one startup run', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_lock_enabled': false});
    final startupResult = Completer<void>();
    final auth = _Auth([]);
    final startup = _Startup([() => startupResult.future]);
    await pumpGate(tester, auth, startup);

    expect(find.byType(AppLockScreen), findsNothing);
    expect(find.text('Preparing Finance Tracker…'), findsOneWidget);
    expect(find.text('Synthetic main screen'), findsNothing);
    expect(auth.calls, 0);
    expect(startup.calls, 1);
    await tester.pump();
    expect(startup.calls, 1);

    startupResult.complete();
    await tester.pumpAndSettle();
    expect(find.text('Synthetic main screen'), findsOneWidget);
    expect(auth.calls, 0);
    expect(startup.calls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stored false fatal failure retains safe retry without overlap', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_lock_enabled': false});
    final retryResult = Completer<void>();
    final auth = _Auth([]);
    final startup = _Startup([
      () async => throw StateError('synthetic startup failure'),
      () => retryResult.future,
    ]);
    await pumpGate(tester, auth, startup);
    await tester.pumpAndSettle();

    expect(find.text('Unable to prepare Finance Tracker.'), findsOneWidget);
    expect(find.text('Synthetic main screen'), findsNothing);
    expect(startup.calls, 1);
    expect(auth.calls, 0);

    final retry = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Try Again'),
    );
    retry.onPressed!();
    retry.onPressed!();
    await tester.pump();
    expect(startup.calls, 2);
    expect(find.text('Synthetic main screen'), findsNothing);

    retryResult.complete();
    await tester.pumpAndSettle();
    expect(find.text('Synthetic main screen'), findsOneWidget);
    expect(auth.calls, 0);
    expect(startup.calls, 2);
    expect(tester.takeException(), isNull);
  });
}
