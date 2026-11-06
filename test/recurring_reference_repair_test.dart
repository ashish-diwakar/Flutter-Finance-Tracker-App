import 'package:finance_tracker/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:finance_tracker/features/categories/presentation/providers/categories_provider.dart';
import 'package:finance_tracker/features/recurring/data/recurring_repository.dart';
import 'package:finance_tracker/features/recurring/presentation/providers/recurring_provider.dart';
import 'package:finance_tracker/features/recurring/presentation/screens/add_recurring_transaction_screen.dart';
import 'package:finance_tracker/shared/models/account_model.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/recurring_transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

class _UnusedIsar extends Fake implements Isar {}

class _RecordingRepository extends RecurringRepository {
  _RecordingRepository() : super(_UnusedIsar());

  final repairs = <(String, String)>[];

  @override
  Future<void> relinkRecurring(
    RecurringTransactionModel original, {
    required String accountId,
    required String categoryId,
  }) async {
    repairs.add((accountId, categoryId));
  }
}

const _accountWarning =
    'Previously selected account is unavailable. Choose an account.';
const _categoryWarning =
    'Previously selected category is unavailable. Choose a category.';
const _longAccount =
    'Archived account with a deliberately long synthetic label';
const _longCategory =
    'Expense category with a deliberately long synthetic label';

Future<_RecordingRepository> _openEditor(
  WidgetTester tester, {
  required String accountId,
  required String categoryId,
}) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repository = _RecordingRepository();
  final schedule = RecurringTransactionModel()
    ..accountId = accountId
    ..categoryId = categoryId
    ..uuid = 'schedule'
    ..type = 'expense'
    ..amount = 1234
    ..frequency = 'monthly'
    ..interval = 1
    ..startDate = DateTime.utc(2026)
    ..isActive = true;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accountsProvider.overrideWith(
          (ref) async => [
            AccountModel()
              ..uuid = 'archived'
              ..name = _longAccount
              ..isArchived = true,
            AccountModel()
              ..uuid = 'deleted-account'
              ..name = 'Deleted account'
              ..isDeleted = true,
          ],
        ),
        categoriesProvider.overrideWith(
          (ref, type) async => [
            CategoryModel()
              ..uuid = 'expense'
              ..name = _longCategory
              ..type = 'expense',
            CategoryModel()
              ..uuid = 'income'
              ..name = 'Income category'
              ..type = 'income',
            CategoryModel()
              ..uuid = 'deleted-category'
              ..name = 'Deleted category'
              ..type = 'expense'
              ..isDeleted = true,
          ],
        ),
        recurringRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      AddRecurringTransactionScreen(recurring: schedule),
                ),
              ),
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets(
    'both missing references require deliberate selections and Save',
    (tester) async {
      final repository = await _openEditor(
        tester,
        accountId: 'missing',
        categoryId: 'missing',
      );
      final save = find.widgetWithText(FilledButton, 'Save Repair');
      expect(find.text(_accountWarning), findsOneWidget);
      expect(find.text(_categoryWarning), findsOneWidget);
      expect(find.text('Amount'), findsNothing);
      expect(tester.widget<FilledButton>(save).onPressed, isNull);

      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();
      expect(find.text('Income category'), findsNothing);
      expect(find.text('Deleted category'), findsNothing);
      await tester.tap(find.text(_longCategory).last);
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(save).onPressed, isNull);

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(find.text('Deleted account'), findsNothing);
      await tester.tap(find.text(_longAccount).last);
      await tester.pumpAndSettle();
      expect(repository.repairs, isEmpty);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repository.repairs, [('archived', 'expense')]);
    },
  );

  testWidgets(
    'one unavailable account preserves the category and Cancel writes nothing',
    (tester) async {
      final repository = await _openEditor(
        tester,
        accountId: 'deleted-account',
        categoryId: 'expense',
      );
      expect(find.text(_accountWarning), findsOneWidget);
      expect(find.text(_categoryWarning), findsNothing);
      expect(find.text(_longCategory), findsOneWidget);
      final cancel = find.widgetWithText(OutlinedButton, 'Cancel');
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(find.text('Open editor'), findsOneWidget);
      expect(repository.repairs, isEmpty);
    },
  );

  for (final invalidCategory in ['deleted-category', 'income']) {
    testWidgets(
      'unavailable category $invalidCategory preserves account and Back writes nothing',
      (tester) async {
        final repository = await _openEditor(
          tester,
          accountId: 'archived',
          categoryId: invalidCategory,
        );
        expect(find.text(_accountWarning), findsNothing);
        expect(find.text(_categoryWarning), findsOneWidget);
        expect(find.text(_longAccount), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Open editor'), findsOneWidget);
        expect(repository.repairs, isEmpty);
      },
    );
  }

  testWidgets('valid selections retain the regular editor', (tester) async {
    await _openEditor(tester, accountId: 'archived', categoryId: 'expense');
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text(_accountWarning), findsNothing);
    expect(find.text(_categoryWarning), findsNothing);
    expect(find.text(_longAccount), findsOneWidget);
    expect(find.text(_longCategory), findsOneWidget);
    expect(find.text('Save Repair'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
