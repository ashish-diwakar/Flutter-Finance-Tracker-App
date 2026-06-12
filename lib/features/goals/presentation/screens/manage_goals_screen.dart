import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/financial_goal_model.dart';
import '../providers/goal_analytics_provider.dart';
import '../providers/goal_repository_provider.dart';
import '../../../../shared/providers/currency_provider.dart';

class ManageGoalsScreen
    extends ConsumerStatefulWidget {

  const ManageGoalsScreen({
    super.key,
  });

  @override
  ConsumerState<ManageGoalsScreen>
      createState() =>
          _ManageGoalsScreenState();
}

class _ManageGoalsScreenState
    extends ConsumerState<
        ManageGoalsScreen> {

  List<FinancialGoalModel>
      goals = [];

  bool loading = true;

  @override
  void initState() {

    super.initState();

    loadGoals();
  }

  Future<void> loadGoals()
  async {

    final repository =
        await ref.read(
      goalRepositoryProvider.future,
    );

    final result =
        await repository
            .getGoals();

    if (!mounted) {
      return;
    }

    setState(() {

      goals = result;

      loading = false;
    });
  }

  double calculateProgress(
    FinancialGoalModel goal,
  ) {

    if (goal.targetAmount <= 0) {
      return 0;
    }

    return (goal.currentAmount /
            goal.targetAmount)
        .clamp(
          0,
          1,
        );
  }

  Future<void> showGoalDialog({
    FinancialGoalModel? goal,
  }) async {

    final nameController =
        TextEditingController(
      text: goal?.name ?? '',
    );

    final descriptionController =
        TextEditingController(
      text:
          goal?.description ?? '',
    );

    final targetController =
        TextEditingController(
      text: goal == null
          ? ''
          : (goal.targetAmount /
                  100)
              .toStringAsFixed(
            2,
          ),
    );

    final currentController =
        TextEditingController(
      text: goal == null
          ? ''
          : (goal.currentAmount /
                  100)
              .toStringAsFixed(
            2,
          ),
    );

    final repository =
        await ref.read(
      goalRepositoryProvider.future,
    );

    if (!mounted) {
      return;
    }

    await showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: Text(

            goal == null

                ? 'Add Goal'

                : 'Edit Goal',
          ),

          content: SingleChildScrollView(

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                TextField(
                  controller:
                      nameController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Goal Name',
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      descriptionController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Description',
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      targetController,
                  keyboardType:
                      TextInputType
                          .number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Target Amount',
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      currentController,
                  keyboardType:
                      TextInputType
                          .number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Current Amount',
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                );
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(

              onPressed: () async {

                if (nameController
                    .text
                    .trim()
                    .isEmpty) {

                  return;
                }

                final targetAmount =
                    ((double.tryParse(
                                      targetController
                                          .text,
                                    ) ??
                                0) *
                            100)
                        .round();

                final currentAmount =
                    ((double.tryParse(
                                      currentController
                                          .text,
                                    ) ??
                                0) *
                            100)
                        .round();

                if (goal == null) {

                  final newGoal =
                      FinancialGoalModel()

                        ..name =
                            nameController
                                .text
                                .trim()

                        ..description =
                            descriptionController
                                .text
                                .trim()

                        ..targetAmount =
                            targetAmount

                        ..currentAmount =
                            currentAmount

                        ..isCompleted =
                            currentAmount >=
                                targetAmount;

                  await repository
                      .addGoal(
                    newGoal,
                  );

                } else {

                  goal.name =
                      nameController
                          .text
                          .trim();

                  goal.description =
                      descriptionController
                          .text
                          .trim();

                  goal.targetAmount =
                      targetAmount;

                  goal.currentAmount =
                      currentAmount;

                  goal.isCompleted =
                      goal.currentAmount >=
                          goal.targetAmount;

                  await repository
                      .updateGoal(
                    goal,
                  );
                }

                if (!mounted) {
                  return;
                }

                Navigator.pop(
                  context,
                );

                await loadGoals();
                ref.invalidate(
                  goalAnalyticsProvider,
                );
              },

              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final currency =
        ref.watch(
      currencyProvider,
    );
    
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Financial Goals',
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        onPressed: () {

          showGoalDialog();
        },

        child: const Icon(
          Icons.add,
        ),
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : goals.isEmpty

              ? const Center(
                  child: Text(
                    'No Goals Found',
                  ),
                )

              : ListView.builder(

                  itemCount:
                      goals.length,

                  itemBuilder:
                      (
                        context,
                        index,
                      ) {

                    final goal =
                        goals[index];

                    final progress =
                        calculateProgress(
                          goal,
                        );

                    return Card(

                      margin:
                          const EdgeInsets
                              .all(
                        12,
                      ),

                      child: Padding(

                        padding:
                            const EdgeInsets
                                .all(
                          16,
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              goal.name,
                              style:
                                  const TextStyle(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                              
                            ),
                            
                            if (goal.isCompleted)
                              const Padding(
                                padding:
                                    EdgeInsets.only(
                                  top: 4,
                                ),
                                child: Chip(
                                  label: Text(
                                    'Completed',
                                  ),
                                ),
                              ),

                            const SizedBox(
                              height: 12,
                            ),

                            LinearProgressIndicator(
                              value:
                                  progress,
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(

                                  CurrencyFormatter.format(

                                    amount:
                                        goal.currentAmount,

                                    currency:
                                        currency,
                                  ),

                                  style:
                                      const TextStyle(

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                Text(

                                  'Target: ${CurrencyFormatter.format(

                                    amount:
                                        goal.targetAmount,

                                    currency:
                                        currency,
                                  )}',
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  '${(progress * 100).toStringAsFixed(0)}% Complete',
                                ),
                              ],
                            ),

                            Row(

                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .end,

                              children: [

                                IconButton(

                                  onPressed: () {

                                    showGoalDialog(
                                      goal:
                                          goal,
                                    );
                                  },

                                  icon:
                                      const Icon(
                                    Icons.edit,
                                  ),
                                ),

                                IconButton(

                                  onPressed:
                                      () async {

                                    final repository =
                                        await ref.read(
                                      goalRepositoryProvider
                                          .future,
                                    );

                                    await repository
                                        .deleteGoal(
                                      goal,
                                    );

                                    await loadGoals();
                                  },

                                  icon:
                                      const Icon(
                                    Icons.delete,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}