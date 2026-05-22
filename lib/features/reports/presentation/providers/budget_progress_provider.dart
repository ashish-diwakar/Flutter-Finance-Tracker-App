import 'package:isar/isar.dart';
//import 'dart:convert';
import 'package:finance_tracker/shared/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
//import 'package:finance_tracker/shared/models/category_model.dart';

import '../../domain/models/budget_progress_data.dart';
import '../../../categories/presentation/providers/category_repository_provider.dart';



final budgetProgressProvider =
    FutureProvider<
        List<BudgetProgressData>>(
  (ref) async {


    final isar =
        await ref.read(
      isarProvider.future,
    );
    
    final repository =
        await ref.read(
      categoryRepositoryProvider.future,
    );

    final expenseTransactions =
        await isar.transactionModels
            .filter()
            .typeEqualTo('expense')
            .isDeletedEqualTo(false)
            .findAll();

    final categories =
        await repository
            .getAllCategories();

          
    final incomeTransactions =
        await isar.transactionModels
            .filter()
            .typeEqualTo('income')
            .isDeletedEqualTo(false)
            .findAll();  

    final Map<String, double>
        totals = {};

    // Sum all amounts starting from 0.0
    var totalIncome = incomeTransactions.fold<double>(
      0.0, 
      (sum, transaction) => sum + (transaction.amount ?? 0.0),
    );

    // if(totalIncome > 0.0) {
    //   totalIncome = totalIncome / 100;
    // }
    
    for (final transaction
        in expenseTransactions) {

      final matchingCategories =
          categories.where(
        (c) =>
            c.id ==
            transaction.categoryId,
      );

      if (matchingCategories.isEmpty) {
        print('No category found for transaction with categoryId: ${transaction.categoryId}');
        continue;
      }

      final category = matchingCategories.first;

      final amount =
          transaction.amount / 100;

      totals.update(
        category.name,
        (value) =>
            value + amount,

        ifAbsent: () => amount,
      );
    }
    
    var result = totals.entries.map((e) {

      // final simulatedBudget =
      //     e.value * 1.2;

      final category =
          categories.firstWhere(
        (c) =>
            c.name == e.key,
      );

      final simulatedBudget =
          (category.monthlyBudget ??
                  totalIncome) /
              100;
      //final simulatedBudget = totalIncome;
      

      var budgetData = BudgetProgressData(

        category: e.key,

        spent: e.value,

        budget:
            simulatedBudget,
      );

      return budgetData;

    }).toList();
    return result;
  },
);