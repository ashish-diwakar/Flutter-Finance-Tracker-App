// import 'package:finance_tracker/features/dashboard/presentation/providers/balance_provider.dart';
// import 'package:finance_tracker/features/dashboard/presentation/providers/expense_provider.dart';
// import 'package:finance_tracker/features/dashboard/presentation/providers/income_provider.dart';
//import 'package:finance_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../providers/transaction_repository_provider.dart';
class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel?
      transaction;
  const AddTransactionScreen({
    super.key,
    this.transaction,
  });
  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}
class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  final counterpartyController = TextEditingController();
  String transactionType = 'expense';
  CategoryModel? selectedCategory;
  AccountModel? selectedAccount;
  AccountModel? selectedToAccount;
  DateTime selectedDate = DateTime.now().toUtc();
  DateTime? selectedDueDate;
  bool saving = false;
  String? categoryError;
  String? accountError;
  String? toAccountError;
  String? counterpartyError;
  String? dateError;
  String? dueDateError;
  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      amountController.text =
          (transaction.amount / 100)
              .toString();
      notesController.text =
          transaction.notes ?? '';
      counterpartyController.text =
          transaction.counterpartyName ?? '';
      transactionType =
          transaction.type;
      selectedDate =
          transaction.transactionDate;
      selectedDueDate =
          transaction.dueDate;
      loadSelectedValues();
    }
  }
  @override
  void dispose() {
    amountController.dispose();
    notesController.dispose();
    counterpartyController.dispose();
    super.dispose();
  }
  Future<void> loadSelectedValues()
      async {
    final transaction =
        widget.transaction;
    if (transaction == null) {
      return;
    }
    final requiresCategory =
        transaction.type == 'income' ||
        transaction.type == 'expense';
    List<CategoryModel> categories =
        <CategoryModel>[];
    if (requiresCategory &&
        transaction.categoryId != null) {
      categories = await ref.read(
        categoriesProvider(
          transaction.type,
        ).future,
      );
    }
    final accounts =
        await ref.read(
      accountsProvider.future,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      selectedCategory =
          categories.cast<CategoryModel?>().firstWhere(
        (c) => c?.uuid == transaction.categoryId,
        orElse: () => null,
      );
      selectedAccount =
          accounts.cast<AccountModel?>().firstWhere(
        (a) => a?.uuid == transaction.accountId,
        orElse: () => null,
      );
      selectedToAccount =
          accounts.cast<AccountModel?>().firstWhere(
        (a) => a?.uuid == transaction.toAccountId,
        orElse: () => null,
      );
    });
  }
  void showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final requiresCategory =
        transactionType == 'income' ||
        transactionType == 'expense';
    final isTransfer =
        transactionType == 'transfer';
    final isBorrowOrLend =
        transactionType == 'borrowed' ||
        transactionType == 'lent';
    final accountsAsync = ref.watch(
      accountsProvider,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? 'Add Transaction'
              : 'Edit Transaction',
          ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: transactionType,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'income',
                      child: Text(
                        'Income',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'expense',
                      child: Text(
                        'Expense',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text(
                        'Transfer',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'borrowed',
                      child: Text(
                        'Borrowed',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'lent',
                      child: Text(
                        'Lent',
                      ),
                    ),
                  ],
                  onChanged: saving
                      ? null
                      : (value) {
                          if (value == null || transactionType == value) {
                            return;
                          }
                          setState(() {
                            transactionType = value;
                            selectedCategory = null;
                            categoryError = null;
                            selectedAccount = null;
                            selectedToAccount = null;
                            accountError = null;
                            toAccountError = null;
                            counterpartyController.clear();
                            counterpartyError = null;
                            selectedDueDate = null;
                            dueDateError = null;
                          });
                        },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(
                        r'^\d*\.?\d{0,2}',
                      ),
                    ),
                  ],
                  validator: (value) {
                    final amount = double.tryParse(
                      value?.trim() ?? '',
                    );
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    if (amount == null) {
                      return 'Enter valid amount';
                    }
                    if (amount <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    if (amount > 999999999) {
                      return 'Amount is too large';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                if (requiresCategory) ...[
                  ref.watch(
                    categoriesProvider(
                      transactionType,
                    ),
                  ).when(
                    data: (categories) {
                      return InkWell(
                        onTap: saving
                            ? null
                            : () async {
                                final result =
                                    await showModalBottomSheet<CategoryModel>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) {
                                    return SafeArea(
                                      child: SizedBox(
                                        height: 400,
                                        child: ListView.builder(
                                          itemCount: categories.length,
                                          itemBuilder: (
                                            context,
                                            index,
                                          ) {
                                            final category =
                                                categories[index];
                                            return ListTile(
                                              title: Text(
                                                category.name,
                                              ),
                                              onTap: () {
                                                Navigator.pop(
                                                  context,
                                                  category,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                                if (result != null) {
                                  setState(() {
                                    selectedCategory = result;
                                    categoryError = null;
                                  });
                                }
                              },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: const OutlineInputBorder(),
                            errorText: categoryError,
                          ),
                          child: Text(
                            selectedCategory?.name ??
                                'Select Category',
                            style: TextStyle(
                              color: selectedCategory == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                    error: (e, s) => const Text(
                      'Unable to load categories',
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
                accountsAsync.when(
                  data: (accounts) {
                    return InkWell(
                      onTap: saving
                          ? null
                          : () async {
                              final result =
                                  await showModalBottomSheet<AccountModel>(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) {
                                  return SafeArea(
                                    child: SizedBox(
                                      height: 400,
                                      child: ListView.builder(
                                        itemCount: accounts.length,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          final account = accounts[index];
                                          return ListTile(
                                            title: Text(
                                              account.name,
                                            ),
                                            onTap: () {
                                              Navigator.pop(
                                                context,
                                                account,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                              if (result != null) {
                                setState(() {
                                  selectedAccount = result;
                                  accountError = null;
                                });
                              }
                            },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: isTransfer
                              ? 'From Account'
                              : 'Account',
                          border: const OutlineInputBorder(),
                          errorText: accountError,
                        ),
                        child: Text(
                          selectedAccount?.name ?? 'Select Account',
                          style: TextStyle(
                            color: selectedAccount == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                  error: (e, s) => const Text(
                    'Unable to load accounts',
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                if (isTransfer) ...[
                  accountsAsync.when(
                    data: (accounts) {
                      return InkWell(
                        onTap: saving
                            ? null
                            : () async {
                                final result =
                                    await showModalBottomSheet<AccountModel>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) {
                                    return SafeArea(
                                      child: SizedBox(
                                        height: 400,
                                        child: ListView.builder(
                                          itemCount: accounts.length,
                                          itemBuilder: (
                                            context,
                                            index,
                                          ) {
                                            final account =
                                                accounts[index];
                                            return ListTile(
                                              title: Text(
                                                account.name,
                                              ),
                                              onTap: () {
                                                Navigator.pop(
                                                  context,
                                                  account,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                                if (result != null) {
                                  setState(() {
                                    selectedToAccount = result;
                                    toAccountError = null;
                                  });
                                }
                              },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'To Account',
                            border: const OutlineInputBorder(),
                            errorText: toAccountError,
                          ),
                          child: Text(
                            selectedToAccount?.name ??
                                'Select Destination Account',
                            style: TextStyle(
                              color: selectedToAccount == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                    error: (e, s) => const Text(
                      'Unable to load accounts',
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
                if (isBorrowOrLend) ...[
                  TextFormField(
                    controller: counterpartyController,
                    maxLength: 100,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: transactionType == 'borrowed'
                          ? 'Borrowed From'
                          : 'Lent To',
                      hintText: 'Person, business, bank, etc.',
                      border: const OutlineInputBorder(),
                      errorText: counterpartyError,
                    ),
                    onChanged: (_) {
                      if (counterpartyError != null) {
                        setState(() {
                          counterpartyError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  InkWell(
                    onTap: saving
                        ? null
                        : () async {
                            final now = DateTime.now();
                            final initialDate =
                                selectedDueDate ??
                                now.add(
                                  const Duration(days: 30),
                                );
                            final picked =
                                await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                              ),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDueDate = picked;
                                dueDateError = null;
                              });
                            }
                          },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Due Date (Optional)',
                        border: const OutlineInputBorder(),
                        errorText: dueDateError,
                        suffixIcon: selectedDueDate == null
                            ? const Icon(
                                Icons.calendar_today,
                              )
                            : IconButton(
                                tooltip: 'Clear due date',
                                onPressed: saving
                                    ? null
                                    : () {
                                        setState(() {
                                          selectedDueDate = null;
                                          dueDateError = null;
                                        });
                                      },
                                icon: const Icon(
                                  Icons.clear,
                                ),
                              ),
                      ),
                      child: Text(
                        selectedDueDate == null
                            ? 'No due date'
                            : selectedDueDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                        style: TextStyle(
                          color: selectedDueDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
                InkWell(
                  onTap: saving
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().toUtc(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                              dateError = null;
                            });
                          }
                        },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: const OutlineInputBorder(),
                      errorText: dateError,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate.toLocal().toString().split(' ')[0],
                        ),
                        const Icon(
                          Icons.calendar_today,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  maxLength: 250,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional notes',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              categoryError =
                                  requiresCategory &&
                                          selectedCategory == null
                                      ? 'Please select a category'
                                      : null;
                              accountError =
                                  selectedAccount == null
                                      ? 'Please select an account'
                                      : null;
                              toAccountError =
                                  isTransfer &&
                                          selectedToAccount == null
                                      ? 'Please select a destination account'
                                      : isTransfer &&
                                              selectedAccount != null &&
                                              selectedToAccount != null &&
                                              selectedAccount!.uuid ==
                                                  selectedToAccount!.uuid
                                          ? 'From and To accounts must be different'
                                          : null;
                              counterpartyError =
                                  isBorrowOrLend &&
                                          counterpartyController
                                              .text
                                              .trim()
                                              .isEmpty
                                      ? transactionType == 'borrowed'
                                          ? 'Please enter who you borrowed from'
                                          : 'Please enter who you lent to'
                                      : null;
                              dateError =
                                  selectedDate.isAfter(
                                    DateTime.now().toUtc(),
                                  )
                                      ? 'Future dates are not allowed'
                                      : null;
                              dueDateError =
                                  isBorrowOrLend &&
                                          selectedDueDate != null &&
                                          selectedDueDate!.isBefore(
                                            DateTime(
                                              selectedDate.year,
                                              selectedDate.month,
                                              selectedDate.day,
                                            ),
                                          )
                                      ? 'Due date cannot be before transaction date'
                                      : null;
                            });
                            final validForm =
                                formKey.currentState!.validate();
                            if (!validForm ||
                                categoryError != null ||
                                accountError != null ||
                                toAccountError != null ||
                                counterpartyError != null ||
                                dateError != null ||
                                dueDateError != null) {
                              return;
                            }
                            final parsedAmount = double.tryParse(
                              amountController.text.trim(),
                            );
                            if (parsedAmount == null) {
                              showMessage(
                                'Invalid amount',
                              );
                              return;
                            }
                            setState(() {
                              saving = true;
                            });
                            try {
                              final repository = await ref.read(
                                transactionRepositoryProvider.future,
                              );
                              final amount = (parsedAmount * 100).toInt();
                              final transaction =
                                  widget.transaction ??
                                  TransactionModel()
                                    ..uuid = const Uuid().v4();
                              transaction
                                ..amount = amount
                                ..type = transactionType
                                ..transactionDate = selectedDate
                                ..categoryId = requiresCategory
                                    ? selectedCategory?.uuid
                                    : null
                                ..accountId = selectedAccount!.uuid
                                ..toAccountId = isTransfer
                                    ? selectedToAccount?.uuid
                                    : null
                                ..counterpartyName = isBorrowOrLend
                                    ? counterpartyController.text.trim()
                                    : null
                                ..dueDate = isBorrowOrLend
                                    ? selectedDueDate
                                    : null
                                ..notes = notesController.text.trim()
                                ..updatedAt = DateTime.now().toUtc()
                                ..isSynced = false;
                              LoggerService.info(
                                'IsarId=${transaction.id}, UUID=${transaction.uuid}',
                              );
                              if (widget.transaction == null) {
                                await repository.addTransaction(
                                  transaction,
                                );
                              } else {
                                transaction.uuid = widget.transaction!.uuid;
                                await repository.updateTransaction(
                                  transaction,
                                );
                              }
                              await ProviderRefreshHelper
                                .refreshAllFinancialData(ref);
                              // Commented Sync
                              // final syncService = await ref.read(
                              //   syncServiceProvider.future,
                              // );
                              // final connectivity = ref.read(
                              //   connectivityProvider,
                              // );
                              // connectivity.whenData(
                              //   (
                              //     result,
                              //   ) async {
                              //     final connected = result.any(
                              //       (
                              //         e,
                              //       ) =>
                              //           e != ConnectivityResult.none,
                              //     );
                              //     if (connected) {
                              //       await syncService.syncAll();
                              //     }
                              //   },
                              // );
                              if (mounted) {
                                Navigator.pop(
                                  context,
                                );
                              }
                            } catch (e) {
                              LoggerService.exception(
                                'Error saving transaction',
                                e,
                                StackTrace.current,
                              );
                              showMessage(
                                'Unable to save transaction. Please try again.',
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  saving = false;
                                });
                              }
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
