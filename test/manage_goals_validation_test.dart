import 'package:finance_tracker/features/goals/data/repositories/goal_repository.dart';
import 'package:finance_tracker/features/goals/presentation/providers/goal_repository_provider.dart';
import 'package:finance_tracker/features/goals/presentation/screens/manage_goals_screen.dart';
import 'package:finance_tracker/shared/models/financial_goal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

class _FakeGoalRepository implements GoalRepository {
  final List<FinancialGoalModel> goals = [];
  int addCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;

  @override
  Isar get isar => throw UnimplementedError();

  @override
  Future<List<FinancialGoalModel>> getGoals() async => List.of(goals);

  @override
  Future<void> addGoal(FinancialGoalModel goal) async {
    addCalls++;
    goals.add(goal);
  }

  @override
  Future<void> updateGoal(FinancialGoalModel goal) async {
    updateCalls++;
  }

  @override
  Future<void> deleteGoal(FinancialGoalModel goal) async {
    deleteCalls++;
    goals.remove(goal);
  }
}

void main() {
  Future<_FakeGoalRepository> pumpGoalScreen(
    WidgetTester tester, {
    FinancialGoalModel? goal,
  }) async {
    final repository = _FakeGoalRepository();
    if (goal != null) {
      repository.goals.add(goal);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goalRepositoryProvider.overrideWith((ref) async => repository),
        ],
        child: const MaterialApp(home: ManageGoalsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    return repository;
  }

  Future<void> openAddDialog(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Add Goal'));
    await tester.pumpAndSettle();
  }

  Future<void> saveDialog(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('empty goal name shows inline error and does not save', (
    tester,
  ) async {
    final repository = await pumpGoalScreen(tester);
    await openAddDialog(tester);

    await tester.enterText(find.byType(TextFormField).at(2), '100');
    await saveDialog(tester);

    expect(find.text('Goal name is required'), findsOneWidget);
    expect(repository.addCalls, 0);
  });

  testWidgets('missing and invalid target amounts show inline errors', (
    tester,
  ) async {
    final repository = await pumpGoalScreen(tester);
    await openAddDialog(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Vacation');
    await saveDialog(tester);
    expect(find.text('Target amount is required'), findsOneWidget);
    expect(repository.addCalls, 0);

    await tester.enterText(find.byType(TextFormField).at(2), 'not-a-number');
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid target amount'), findsOneWidget);
    await saveDialog(tester);
    expect(repository.addCalls, 0);
  });

  testWidgets('correcting target allows save with blank current amount', (
    tester,
  ) async {
    final repository = await pumpGoalScreen(tester);
    await openAddDialog(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Vacation');
    await tester.enterText(find.byType(TextFormField).at(2), '100.25');
    await saveDialog(tester);

    expect(repository.addCalls, 1);
    expect(repository.goals.single.targetAmount, 10025);
    expect(repository.goals.single.currentAmount, 0);
  });

  testWidgets('zero current amount is valid and negative amount is reported', (
    tester,
  ) async {
    final repository = await pumpGoalScreen(tester);
    await openAddDialog(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Emergency fund');
    await tester.enterText(find.byType(TextFormField).at(2), '50');
    await tester.enterText(find.byType(TextFormField).at(3), '-1');
    await saveDialog(tester);

    expect(find.text('Current amount cannot be negative'), findsOneWidget);
    expect(repository.addCalls, 0);

    await tester.enterText(find.byType(TextFormField).at(3), '0');
    await saveDialog(tester);

    expect(repository.addCalls, 1);
    expect(repository.goals.single.currentAmount, 0);
  });

  testWidgets('saving an unchanged edit preserves both goal amounts', (
    tester,
  ) async {
    final goal = FinancialGoalModel()
      ..name = 'Bike'
      ..description = 'New bicycle'
      ..targetAmount = 15000000
      ..currentAmount = 15500000
      ..isCompleted = true;
    final repository = await pumpGoalScreen(tester, goal: goal);

    await tester.tap(find.byTooltip('Edit Goal'));
    await tester.pumpAndSettle();
    await saveDialog(tester);

    expect(repository.updateCalls, 1);
    expect(goal.targetAmount, 15000000);
    expect(goal.currentAmount, 15500000);
  });

  testWidgets('canceling goal deletion does not delete the goal', (
    tester,
  ) async {
    final goal = FinancialGoalModel()
      ..name = 'Bike'
      ..description = 'New bicycle'
      ..targetAmount = 15000000
      ..currentAmount = 15500000
      ..isCompleted = true;
    final repository = await pumpGoalScreen(tester, goal: goal);

    await tester.tap(find.byTooltip('Delete Goal'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Goal?'), findsOneWidget);
    expect(find.text('Bike'), findsNWidgets(2));
    expect(find.text('Current Savings'), findsOneWidget);
    expect(find.text('Target Amount'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, 0);
    expect(repository.goals, contains(same(goal)));
  });

  testWidgets('explicit delete confirmation invokes the existing delete path', (
    tester,
  ) async {
    final goal = FinancialGoalModel()
      ..name = 'Bike'
      ..targetAmount = 15000000
      ..currentAmount = 15500000
      ..isCompleted = true;
    final repository = await pumpGoalScreen(tester, goal: goal);

    await tester.tap(find.byTooltip('Delete Goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, 1);
    expect(repository.goals, isNot(contains(same(goal))));
  });
}
