import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../../shared/models/financial_goal_model.dart';
import '../providers/goal_analytics_provider.dart';
import '../providers/goal_repository_provider.dart';
import '../../../../shared/providers/currency_provider.dart';

class ManageGoalsScreen extends ConsumerStatefulWidget {
  const ManageGoalsScreen({super.key});

  @override
  ConsumerState<ManageGoalsScreen> createState() => _ManageGoalsScreenState();
}

class _ManageGoalsScreenState extends ConsumerState<ManageGoalsScreen> {
  List<FinancialGoalModel> goals = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadGoals();
  }

  Future<void> loadGoals() async {
    final repository = await ref.read(goalRepositoryProvider.future);

    final result = await repository.getGoals();

    if (!mounted) {
      return;
    }

    setState(() {
      goals = result;

      loading = false;
    });
  }

  double calculateProgress(FinancialGoalModel goal) {
    if (goal.targetAmount <= 0) {
      return 0;
    }

    return (goal.currentAmount / goal.targetAmount).clamp(0, 1);
  }

  Future<void> showGoalDialog({FinancialGoalModel? goal}) async {
    final nameController = TextEditingController(text: goal?.name ?? '');

    final descriptionController = TextEditingController(
      text: goal?.description ?? '',
    );

    final targetController = TextEditingController(
      text: goal == null ? '' : (goal.targetAmount / 100).toStringAsFixed(2),
    );

    final currentController = TextEditingController(
      text: goal == null ? '' : (goal.currentAmount / 100).toStringAsFixed(2),
    );

    final repository = await ref.read(goalRepositoryProvider.future);

    if (!mounted) {
      return;
    }

    await showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          title: Text(goal == null ? 'Add Goal' : 'Edit Goal'),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target Amount'),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: currentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current Amount',
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  return;
                }

                final targetAmount =
                    ((double.tryParse(targetController.text) ?? 0) * 100)
                        .round();

                final currentAmount =
                    ((double.tryParse(currentController.text) ?? 0) * 100)
                        .round();

                if (targetAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Target amount must be greater than 0'),
                    ),
                  );
                  return;
                }

                if (currentAmount < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Current amount cannot be negative'),
                    ),
                  );
                  return;
                }

                if (goal == null) {
                  final newGoal = FinancialGoalModel()
                    ..name = nameController.text.trim()
                    ..description = descriptionController.text.trim()
                    ..targetAmount = targetAmount
                    ..currentAmount = currentAmount
                    ..isCompleted = currentAmount >= targetAmount;

                  await repository.addGoal(newGoal);
                } else {
                  goal.name = nameController.text.trim();

                  goal.description = descriptionController.text.trim();

                  goal.targetAmount = targetAmount;

                  goal.currentAmount = currentAmount;

                  goal.isCompleted = goal.currentAmount >= goal.targetAmount;

                  await repository.updateGoal(goal);
                }

                if (!mounted) {
                  return;
                }

                Navigator.pop(context);

                await loadGoals();
                ref.invalidate(goalAnalyticsProvider);
              },

              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Financial Goals')),

      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Goal',
        backgroundColor: const Color(0xFF17664F),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        onPressed: () {
          showGoalDialog();
        },

        child: const Icon(Icons.add, size: 24),
      ),

      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFB6D7CC), Color(0xFFDAEDE5), Color(0xFFF8FCFA)],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : goals.isEmpty
            ? const Center(child: Text('No Goals Found'))
            : ListView.builder(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 100,
                ),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];

                  final progress = calculateProgress(goal);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: const Color(0xFFF0F8F2),
                    surfaceTintColor: Colors.transparent,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: Color(0xFFB8D8CA)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: const TextStyle(
                              color: Color(0xFF244D3F),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (goal.isCompleted)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDFF1E5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Color(0xFF237F50),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            CurrencyFormatter.format(
                              amount: goal.currentAmount,
                              currency: currency,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF17664F),
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Target:',
                                style: TextStyle(
                                  color: Color(0xFF536B61),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  CurrencyFormatter.format(
                                    amount: goal.targetAmount,
                                    currency: currency,
                                  ),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    color: Color(0xFF244D3F),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              valueColor: goal.isCompleted
                                  ? const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF17664F),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% Complete',
                            style: const TextStyle(
                              color: Color(0xFF536B61),
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton.filledTonal(
                                tooltip: 'Edit Goal',
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFDDEFE5),
                                  foregroundColor: const Color(0xFF17664F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                onPressed: () {
                                  showGoalDialog(goal: goal);
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              const SizedBox(width: 12),
                              IconButton.filledTonal(
                                tooltip: 'Delete Goal',
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFFBE8E3),
                                  foregroundColor: const Color(0xFFB54C44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Delete Goal?'),
                                        content: Text(
                                          'Are you sure you want to delete "${goal.name}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(
                                                dialogContext,
                                              ).pop(false);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(
                                                dialogContext,
                                              ).pop(true);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmed != true) {
                                    return;
                                  }

                                  final repository = await ref.read(
                                    goalRepositoryProvider.future,
                                  );

                                  await repository.deleteGoal(goal);

                                  await loadGoals();

                                  ref.invalidate(goalAnalyticsProvider);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
