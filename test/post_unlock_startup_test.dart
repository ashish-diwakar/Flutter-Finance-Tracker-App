import 'dart:async';
import 'dart:collection';

import 'package:finance_tracker/features/security/presentation/providers/app_lock_provider.dart';
import 'package:finance_tracker/features/security/presentation/providers/post_unlock_startup_provider.dart';
import 'package:finance_tracker/features/security/presentation/screens/app_lock_screen.dart';
import 'package:finance_tracker/features/security/services/app_lock_service.dart';
import 'package:finance_tracker/features/security/services/post_unlock_startup_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuth extends AppLockService {
  _FakeAuth(Iterable<Future<bool> Function()> responses)
    : _responses = Queue.of(responses);

  final Queue<Future<bool> Function()> _responses;
  int calls = 0;

  @override
  Future<bool> authenticate() {
    calls++;
    return _responses.removeFirst()();
  }
}

class _FakeStartup implements PostUnlockStartup {
  _FakeStartup([this._work]);

  final Future<void> Function()? _work;
  int calls = 0;

  @override
  Future<void> run() {
    calls++;
    return _work?.call() ?? Future.value();
  }
}

void main() {
  setUp(() => dotenv.testLoad(fileInput: 'APP_NAME=Finance Tracker'));

  test(
    'coordinator awaits database, recurring, reminders, then budget',
    () async {
      final order = <String>[];
      final database = Object();
      final coordinator = PostUnlockStartupCoordinator<Object>(
        openDatabase: () async {
          order.add('database');
          return database;
        },
        processRecurring: (value) async {
          expect(value, same(database));
          order.add('recurring');
          return 2;
        },
        reconcileReminders: () async => order.add('reminders'),
        processBudgetAlerts: (value) async {
          expect(value, same(database));
          order.add('budget');
        },
      );

      await coordinator.run();
      expect(order, ['database', 'recurring', 'reminders', 'budget']);
    },
  );

  test('reminder failure is logged and budget work continues', () async {
    final order = <String>[];
    final coordinator = PostUnlockStartupCoordinator<Object>(
      openDatabase: () async {
        order.add('database');
        return Object();
      },
      processRecurring: (_) async {
        order.add('recurring');
        return 0;
      },
      reconcileReminders: () async {
        order.add('reminders');
        throw StateError('synthetic reminder failure');
      },
      processBudgetAlerts: (_) async => order.add('budget'),
    );

    await coordinator.run();
    expect(order, ['database', 'recurring', 'reminders', 'budget']);
  });

  for (final failedActivity in ['recurring', 'budget']) {
    test('$failedActivity failure stops startup and propagates', () async {
      final order = <String>[];
      final coordinator = PostUnlockStartupCoordinator<Object>(
        openDatabase: () async {
          order.add('database');
          return Object();
        },
        processRecurring: (_) async {
          order.add('recurring');
          if (failedActivity == 'recurring') {
            throw StateError('synthetic recurring failure');
          }
          return 0;
        },
        reconcileReminders: () async => order.add('reminders'),
        processBudgetAlerts: (_) async {
          order.add('budget');
          throw StateError('synthetic budget failure');
        },
      );

      await expectLater(coordinator.run(), throwsStateError);
      expect(
        order,
        failedActivity == 'recurring'
            ? ['database', 'recurring']
            : ['database', 'recurring', 'reminders', 'budget'],
      );
    });
  }

  Future<void> pumpLock(
    WidgetTester tester,
    _FakeAuth auth,
    _FakeStartup startup,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockServiceProvider.overrideWithValue(auth),
          postUnlockStartupProvider.overrideWithValue(startup),
        ],
        child: const MaterialApp(
          home: AppLockScreen(unlockedScreen: Text('Synthetic main screen')),
        ),
      ),
    );
  }

  testWidgets('success awaits startup once before replacing lock route', (
    tester,
  ) async {
    final completion = Completer<void>();
    final auth = _FakeAuth([() async => true]);
    final startup = _FakeStartup(() => completion.future);
    await pumpLock(tester, auth, startup);
    await tester.pump();

    expect(auth.calls, 1);
    expect(startup.calls, 1);
    expect(find.byType(AppLockScreen), findsOneWidget);
    expect(find.text('Synthetic main screen'), findsNothing);

    completion.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AppLockScreen), findsNothing);
    expect(find.text('Synthetic main screen'), findsOneWidget);
    expect(startup.calls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel stays locked; overlapping retry taps run startup once', (
    tester,
  ) async {
    final retryAuth = Completer<bool>();
    final auth = _FakeAuth([() async => false, () => retryAuth.future]);
    final startup = _FakeStartup();
    await pumpLock(tester, auth, startup);
    await tester.pumpAndSettle();

    expect(find.text('Authentication failed or cancelled.'), findsOneWidget);
    expect(startup.calls, 0);
    expect(find.byType(AppLockScreen), findsOneWidget);

    final retry = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Try Again'),
    );
    retry.onPressed!();
    retry.onPressed!();
    await tester.pump();
    expect(auth.calls, 2);
    expect(startup.calls, 0);

    retryAuth.complete(true);
    await tester.pumpAndSettle();
    expect(startup.calls, 1);
    expect(find.text('Synthetic main screen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('authentication exception keeps retry route without startup', (
    tester,
  ) async {
    final auth = _FakeAuth([
      () async => throw StateError('synthetic authentication failure'),
    ]);
    final startup = _FakeStartup();
    await pumpLock(tester, auth, startup);
    await tester.pumpAndSettle();

    expect(startup.calls, 0);
    expect(find.text('Authentication failed or cancelled.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.byType(AppLockScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('startup failure preserves the lock and retry path', (
    tester,
  ) async {
    final auth = _FakeAuth([() async => true]);
    final startup = _FakeStartup(
      () async => throw StateError('synthetic startup failure'),
    );
    await pumpLock(tester, auth, startup);
    await tester.pumpAndSettle();

    expect(startup.calls, 1);
    expect(find.text('Authentication failed or cancelled.'), findsOneWidget);
    expect(find.byType(AppLockScreen), findsOneWidget);
    expect(find.text('Synthetic main screen'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
