import 'dart:async';

import 'package:finance_tracker/features/security/presentation/providers/app_lock_provider.dart';
import 'package:finance_tracker/features/security/presentation/providers/app_lock_enabled_provider.dart';
import 'package:finance_tracker/features/security/presentation/providers/post_unlock_startup_provider.dart';
import 'package:finance_tracker/features/security/services/app_lock_service.dart';
import 'package:finance_tracker/features/security/services/post_unlock_startup_coordinator.dart';
import 'package:finance_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Test-only platform store substitute.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _Auth extends AppLockService {
  bool supported = true;
  bool accepted = true;
  bool throws = false;
  int supportCalls = 0;
  int authCalls = 0;
  int cancelCalls = 0;
  Completer<bool>? pending;
  Completer<bool>? pendingSupport;

  @override
  Future<bool> isDeviceSupported() async {
    supportCalls++;
    return pendingSupport?.future ?? supported;
  }

  @override
  Future<bool> authenticate() async {
    authCalls++;
    if (throws) throw StateError('synthetic auth failure');
    return pending?.future ?? accepted;
  }

  @override
  Future<void> cancelAuthentication() async {
    cancelCalls++;
    if (pending != null && !pending!.isCompleted) pending!.complete(false);
  }
}

class _RejectingStore extends InMemorySharedPreferencesStore {
  _RejectingStore() : super.withData({'flutter.app_lock_enabled': false});

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

class _UnverifiableStore extends InMemorySharedPreferencesStore {
  _UnverifiableStore({bool enabled = false})
    : super.withData({'flutter.app_lock_enabled': enabled});

  bool failReads = false;
  bool malformedReads = false;
  bool malformedOnWrite = false;
  Completer<void>? pendingWrite;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    await pendingWrite?.future;
    final result = await super.setValue(valueType, key, value);
    failReads = !malformedOnWrite;
    malformedReads = malformedOnWrite;
    return result;
  }

  @override
  Future<Map<String, Object>> getAll() async {
    if (failReads) throw StateError('synthetic reload failure');
    if (malformedReads) return {'flutter.app_lock_enabled': 'invalid'};
    return super.getAll();
  }
}

class _Startup implements PostUnlockStartup {
  int calls = 0;

  @override
  Future<void> run() async {
    calls++;
  }
}

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'APP_NAME=Finance Tracker');
    SharedPreferences.setMockInitialValues({});
  });

  final startup = _Startup();

  Future<void> pumpSettings(
    WidgetTester tester,
    _Auth auth, {
    bool enabled = true,
  }) async {
    SharedPreferences.setMockInitialValues({'app_lock_enabled': enabled});
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockServiceProvider.overrideWithValue(auth),
          postUnlockStartupProvider.overrideWithValue(startup),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('app-lock-switch')),
      200,
    );
    await tester.pumpAndSettle();
  }

  Future<bool?> stored() async =>
      (await SharedPreferences.getInstance()).getBool('app_lock_enabled');

  Future<void> pumpInContainer(
    WidgetTester tester,
    ProviderContainer container, {
    bool settings = true,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: settings ? const SettingsScreen() : const SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (settings) {
      await tester.scrollUntilVisible(
        find.byKey(const Key('app-lock-status')),
        200,
      );
      await tester.pumpAndSettle();
    }
  }

  testWidgets('disable requires confirmation then authentication', (
    tester,
  ) async {
    final auth = _Auth();
    await pumpSettings(tester, auth);
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Turn off App Lock?'), findsOneWidget);
    expect(await stored(), isTrue);
    expect(auth.authCalls, 0);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await stored(), isTrue);
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(auth.authCalls, 1);
    expect(startup.calls, 0);
    expect(await stored(), isFalse);
    expect(
      tester.widget<Switch>(find.byKey(const Key('app-lock-switch'))).value,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled or failed authentication never saves', (tester) async {
    final auth = _Auth()..accepted = false;
    await pumpSettings(tester, auth);
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(await stored(), isTrue);
    expect(
      find.textContaining('Authentication was not completed'),
      findsOneWidget,
    );
  });

  testWidgets('enable checks support and authenticates before saving', (
    tester,
  ) async {
    final auth = _Auth()..supported = false;
    await pumpSettings(tester, auth, enabled: false);
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pumpAndSettle();
    expect(auth.supportCalls, 1);
    expect(auth.authCalls, 0);
    expect(await stored(), isFalse);
    auth.supported = true;
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pumpAndSettle();
    expect(auth.authCalls, 1);
    expect(startup.calls, 0);
    expect(await stored(), isTrue);
  });

  testWidgets('auth exception and repeated taps do not write or overlap', (
    tester,
  ) async {
    final auth = _Auth()..throws = true;
    await pumpSettings(tester, auth, enabled: false);
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pumpAndSettle();
    expect(await stored(), isFalse);
    auth.throws = false;
    auth.pending = Completer<bool>();
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pump();
    expect(
      tester.widget<Switch>(find.byKey(const Key('app-lock-switch'))).onChanged,
      isNull,
    );
    expect(auth.authCalls, 2);
    auth.pending!.complete(false);
    await tester.pumpAndSettle();
    expect(await stored(), isFalse);
  });

  testWidgets('closing Settings cancels an active authentication prompt', (
    tester,
  ) async {
    final auth = _Auth()..pending = Completer<bool>();
    await pumpSettings(tester, auth, enabled: false);
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pump();
    expect(auth.authCalls, 1);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
    expect(auth.cancelCalls, 1);
    expect(await stored(), isFalse);
  });

  testWidgets('closing Settings during support check never starts auth', (
    tester,
  ) async {
    final auth = _Auth()..pendingSupport = Completer<bool>();
    await pumpSettings(tester, auth, enabled: false);
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pump();
    expect(auth.supportCalls, 1);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    auth.pendingSupport!.complete(true);
    await tester.pump();
    expect(auth.authCalls, 0);
    expect(await stored(), isFalse);
  });

  testWidgets('rejected storage write is not shown as success', (tester) async {
    final original = SharedPreferencesStorePlatform.instance;
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = original;
      SharedPreferences.setMockInitialValues({});
    });
    final auth = _Auth();
    await pumpSettings(tester, auth, enabled: false);
    SharedPreferencesStorePlatform.instance = _RejectingStore();
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pumpAndSettle();
    expect(find.textContaining('could not be changed'), findsOneWidget);
    expect(await stored(), isFalse);
  });

  testWidgets('unverifiable write hides state until explicit recheck', (
    tester,
  ) async {
    final original = SharedPreferencesStorePlatform.instance;
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = original;
      SharedPreferences.setMockInitialValues({});
    });
    final auth = _Auth();
    await pumpSettings(tester, auth, enabled: false);
    final store = _UnverifiableStore();
    SharedPreferencesStorePlatform.instance = store;
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pumpAndSettle();
    expect(find.text('Unverified'), findsOneWidget);
    expect(find.byKey(const Key('app-lock-switch')), findsNothing);
    expect(find.text('Check status'), findsOneWidget);
    store.failReads = false;
    await tester.tap(find.text('Check status'));
    await tester.pumpAndSettle();
    expect(find.text('On'), findsOneWidget);
    expect(
      tester.widget<Switch>(find.byKey(const Key('app-lock-switch'))).value,
      isTrue,
    );
  });

  for (final initial in [true, false]) {
    testWidgets(
      'verified ${initial ? 'disable' : 'enable'} survives Settings remount',
      (tester) async {
        SharedPreferences.setMockInitialValues({'app_lock_enabled': initial});
        final auth = _Auth();
        final container = ProviderContainer(
          overrides: [
            appLockServiceProvider.overrideWithValue(auth),
            postUnlockStartupProvider.overrideWithValue(startup),
          ],
        );
        addTearDown(container.dispose);
        await pumpInContainer(tester, container);
        await tester.tap(find.byKey(const Key('app-lock-switch')));
        if (initial) {
          await tester.pump(const Duration(milliseconds: 300));
          await tester.tap(find.text('Continue'));
        }
        await tester.pumpAndSettle();
        expect(await stored(), !initial);
        await pumpInContainer(tester, container, settings: false);
        await pumpInContainer(tester, container);
        expect(find.text(initial ? 'Off' : 'On'), findsOneWidget);
        expect(
          tester.widget<Switch>(find.byKey(const Key('app-lock-switch'))).value,
          !initial,
        );
        expect(container.read(appLockVerificationRequiredProvider), isFalse);
      },
    );

    testWidgets(
      'unverified ${initial ? 'disable' : 'enable'} survives remount and strict rechecks',
      (tester) async {
        SharedPreferences.setMockInitialValues({'app_lock_enabled': initial});
        final original = SharedPreferencesStorePlatform.instance;
        addTearDown(() {
          SharedPreferencesStorePlatform.instance = original;
          SharedPreferences.setMockInitialValues({});
        });
        final auth = _Auth();
        final container = ProviderContainer(
          overrides: [
            appLockServiceProvider.overrideWithValue(auth),
            postUnlockStartupProvider.overrideWithValue(startup),
          ],
        );
        addTearDown(container.dispose);
        await pumpInContainer(tester, container);
        final store = _UnverifiableStore(enabled: initial);
        SharedPreferencesStorePlatform.instance = store;
        await tester.tap(find.byKey(const Key('app-lock-switch')));
        if (initial) {
          await tester.pump(const Duration(milliseconds: 300));
          await tester.tap(find.text('Continue'));
        }
        await tester.pumpAndSettle();
        expect(container.read(appLockVerificationRequiredProvider), isTrue);
        await pumpInContainer(tester, container, settings: false);
        await pumpInContainer(tester, container);
        expect(find.text('Unverified'), findsOneWidget);
        expect(find.byKey(const Key('app-lock-switch')), findsNothing);
        // The previously cached Boolean must not replace the warning.
        expect(container.read(appLockEnabledProvider).valueOrNull, initial);
        await tester.tap(find.text('Check status'));
        await tester.pumpAndSettle();
        expect(find.text('Unverified'), findsOneWidget);
        store.failReads = false;
        store.malformedReads = true;
        await tester.tap(find.text('Check status'));
        await tester.pumpAndSettle();
        expect(find.text('Unverified'), findsOneWidget);
        store.malformedReads = false;
        await tester.tap(find.text('Check status'));
        await tester.pumpAndSettle();
        expect(find.text(initial ? 'Off' : 'On'), findsOneWidget);
        expect(
          tester.widget<Switch>(find.byKey(const Key('app-lock-switch'))).value,
          !initial,
        );
        expect(container.read(appLockVerificationRequiredProvider), isFalse);
      },
    );
  }

  testWidgets(
    'late write completion after Settings disposal remains unverified',
    (tester) async {
      SharedPreferences.setMockInitialValues({'app_lock_enabled': false});
      final original = SharedPreferencesStorePlatform.instance;
      addTearDown(() {
        SharedPreferencesStorePlatform.instance = original;
        SharedPreferences.setMockInitialValues({});
      });
      final auth = _Auth();
      final container = ProviderContainer(
        overrides: [appLockServiceProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);
      await pumpInContainer(tester, container);
      final store = _UnverifiableStore()..pendingWrite = Completer<void>();
      SharedPreferencesStorePlatform.instance = store;
      await tester.tap(find.byKey(const Key('app-lock-switch')));
      await tester.pump();
      expect(container.read(appLockVerificationRequiredProvider), isTrue);
      await pumpInContainer(tester, container, settings: false);
      store.pendingWrite!.complete();
      await tester.pump();
      await pumpInContainer(tester, container);
      expect(find.text('Unverified'), findsOneWidget);
      expect(find.byKey(const Key('app-lock-switch')), findsNothing);
    },
  );

  testWidgets('malformed direct readback cannot verify a write', (
    tester,
  ) async {
    final original = SharedPreferencesStorePlatform.instance;
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = original;
      SharedPreferences.setMockInitialValues({});
    });
    final auth = _Auth();
    await pumpSettings(tester, auth, enabled: false);
    SharedPreferencesStorePlatform.instance = _UnverifiableStore()
      ..malformedOnWrite = true;
    await tester.tap(find.byKey(const Key('app-lock-switch')));
    await tester.pumpAndSettle();
    expect(find.text('Unverified'), findsOneWidget);
    expect(find.byKey(const Key('app-lock-switch')), findsNothing);
  });
}
