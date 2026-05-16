import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'expense_provider.dart';
import 'income_provider.dart';

final totalBalanceProvider = Provider<int>((ref) {

  final income =
      ref.watch(totalIncomeProvider).value ?? 0;

  final expense =
      ref.watch(totalExpenseProvider).value ?? 0;

  return income - expense;
});