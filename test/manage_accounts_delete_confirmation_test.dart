import 'package:finance_tracker/features/accounts/data/repositories/account_repository.dart';
import 'package:finance_tracker/features/accounts/presentation/providers/account_balances_provider.dart';
import 'package:finance_tracker/features/accounts/presentation/providers/account_repository_provider.dart';
import 'package:finance_tracker/features/accounts/presentation/screens/manage_accounts_screen.dart';
import 'package:finance_tracker/shared/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

class _FakeAccountRepository implements AccountRepository {
  final List<AccountModel> accounts = [];
  int deleteCalls = 0;

  @override
  Isar get isar => throw UnimplementedError();

  @override
  Future<List<AccountModel>> getAccounts() async => List.of(accounts);

  @override
  Future<void> addAccount(AccountModel account) async {
    accounts.add(account);
  }

  @override
  Future<void> updateAccount(AccountModel account) async {}

  @override
  Future<void> deleteAccount(AccountModel account) async {
    deleteCalls++;
    accounts.remove(account);
  }
}

void main() {
  Future<(_FakeAccountRepository, AccountModel)> pumpAccountScreen(
    WidgetTester tester,
  ) async {
    final repository = _FakeAccountRepository();
    final account = AccountModel()
      ..uuid = 'test-account'
      ..name = 'Test wallet'
      ..type = 'cash'
      ..currentBalance = 2500;
    repository.accounts.add(account);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountRepositoryProvider.overrideWith((ref) async => repository),
          accountBalancesProvider.overrideWithValue(
            const AsyncData(<String, int>{}),
          ),
        ],
        child: const MaterialApp(home: ManageAccountsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    return (repository, account);
  }

  testWidgets('Cancel leaves the selected account unchanged', (tester) async {
    final (repository, account) = await pumpAccountScreen(tester);
    await tester.tap(find.byTooltip('Delete Account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Account?'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Test wallet'), findsNWidgets(2));
    expect(find.text('Type'), findsOneWidget);
    expect(find.text('Cash'), findsNWidgets(2));
    expect(find.text('Current Balance'), findsNWidgets(2));
    expect(find.text('₹25.00'), findsNWidgets(2));
    expect(
      find.text(
        'Deleting an account may affect financial records associated with it.',
      ),
      findsOneWidget,
    );
    expect(repository.deleteCalls, 0);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, 0);
    expect(repository.accounts, contains(same(account)));
    expect(find.text('Test wallet'), findsOneWidget);
  });

  testWidgets('explicit confirmation calls the existing delete path', (
    tester,
  ) async {
    final (repository, account) = await pumpAccountScreen(tester);
    await tester.tap(find.byTooltip('Delete Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, 1);
    expect(repository.accounts, isNot(contains(same(account))));
  });
}
