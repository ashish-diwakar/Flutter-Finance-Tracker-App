import 'package:finance_tracker/features/categories/data/repositories/category_repository.dart';
import 'package:finance_tracker/features/categories/presentation/providers/category_repository_provider.dart';
import 'package:finance_tracker/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

class _FakeCategoryRepository implements CategoryRepository {
  final List<CategoryModel> categories = [];

  @override
  Isar get isar => throw UnimplementedError();

  @override
  Future<List<CategoryModel>> getAllCategories() async => List.of(categories);

  @override
  Future<List<CategoryModel>> getAllCategoriesIncludingDeleted() async =>
      List.of(categories);

  @override
  Future<List<CategoryModel>> getCategoriesByType(String type) async =>
      categories.where((category) => category.type == type).toList();

  @override
  Future<void> addCategory(CategoryModel category) async {
    categories.add(category);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {}

  @override
  Future<void> deleteCategory(CategoryModel category) async {
    categories.remove(category);
  }
}

class _TestCurrencyNotifier extends CurrencyNotifier {
  @override
  Future<void> loadCurrency() async {}
}

Future<void> _pumpCategoryScreen(
  WidgetTester tester,
  _FakeCategoryRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWith((ref) async => repository),
        currencyProvider.overrideWith((ref) => _TestCurrencyNotifier()),
      ],
      child: const MaterialApp(home: ManageCategoriesScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

CategoryModel _category({
  required String name,
  required String type,
  required int amount,
}) {
  return CategoryModel()
    ..uuid = name
    ..name = name
    ..type = type
    ..monthlyBudget = amount;
}

void main() {
  testWidgets(
    'dismissing the category dialog after editing the amount is safe',
    (tester) async {
      final repository = _FakeCategoryRepository();
      await _pumpCategoryScreen(tester, repository);

      await tester.tap(find.byTooltip('Add Category'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Temporary');
      await tester.enterText(find.byType(TextFormField).at(1), '1234.56');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(repository.categories, isEmpty);
      expect(find.text('Add Category'), findsNothing);
    },
  );

  testWidgets('saving closes the category dialog and refreshes the list', (
    tester,
  ) async {
    final repository = _FakeCategoryRepository();
    await _pumpCategoryScreen(tester, repository);

    await tester.tap(find.byTooltip('Add Category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Temporary');
    await tester.enterText(find.byType(TextFormField).at(1), '1234.56');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Add Category'), findsNothing);
    expect(find.text('Temporary'), findsOneWidget);
    expect(repository.categories.single.monthlyBudget, 123456);
  });

  testWidgets('editing without changing the amount preserves stored paise', (
    tester,
  ) async {
    final repository = _FakeCategoryRepository();
    final category = _category(
      name: 'Expense',
      type: 'expense',
      amount: 123456,
    );
    repository.categories.add(category);
    await _pumpCategoryScreen(tester, repository);

    await tester.tap(find.byTooltip('Edit Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(category.monthlyBudget, 123456);
    expect(find.text('Edit Category'), findsNothing);
  });

  testWidgets('editing an income target saves the changed paise amount', (
    tester,
  ) async {
    final repository = _FakeCategoryRepository();
    repository.categories.add(
      _category(name: 'Income', type: 'income', amount: 5000000),
    );
    await _pumpCategoryScreen(tester, repository);

    await tester.tap(find.byTooltip('Edit Category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '50000.01');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(repository.categories.single.monthlyBudget, 5000001);
    expect(find.text('Edit Category'), findsNothing);
  });
}
