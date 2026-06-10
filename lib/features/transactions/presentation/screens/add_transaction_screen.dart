import 'package:finance_tracker/features/dashboard/presentation/providers/balance_provider.dart';
import 'package:finance_tracker/features/dashboard/presentation/providers/expense_provider.dart';
import 'package:finance_tracker/features/dashboard/presentation/providers/income_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/connectivity_provider.dart';
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
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

  String transactionType = 'expense';

  CategoryModel? selectedCategory;

  AccountModel? selectedAccount;

  DateTime selectedDate = DateTime.now();

  bool saving = false;

  String? categoryError;

  String? accountError;

  String? dateError;

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

      transactionType =
          transaction.type;

      selectedDate =
          transaction.transactionDate;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    notesController.dispose();
    super.dispose();
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
    final categoriesAsync = ref.watch(
      categoriesProvider(
        transactionType,
      ),
    );

    final accountsAsync = ref.watch(
      accountsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
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
                            accountError = null;
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

                categoriesAsync.when(
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
                                          final category = categories[index];

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
                          selectedCategory?.name ?? 'Select Category',
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
                          labelText: 'Account',
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

                InkWell(
                  onTap: saving
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
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
                              categoryError = selectedCategory == null
                                  ? 'Please select a category'
                                  : null;

                              accountError = selectedAccount == null
                                  ? 'Please select an account'
                                  : null;

                              dateError = selectedDate.isAfter(DateTime.now())
                                  ? 'Future dates are not allowed'
                                  : null;
                            });

                            final validForm = formKey.currentState!.validate();

                            if (!validForm ||
                                categoryError != null ||
                                accountError != null ||
                                dateError != null) {
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

                              final transaction = TransactionModel()
                                ..uuid = widget.transaction?.uuid ?? const Uuid().v4()
                                ..amount = amount
                                ..type = transactionType
                                ..transactionDate = selectedDate
                                ..categoryId = selectedCategory!.uuid
                                ..accountId = selectedAccount!.uuid
                                ..notes = notesController.text.trim()
                                ..isSynced = false
                                ..updatedAt = DateTime.now();

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

                              final syncService = await ref.read(
                                syncServiceProvider.future,
                              );

                              final connectivity = ref.read(
                                connectivityProvider,
                              );

                              connectivity.whenData(
                                (
                                  result,
                                ) async {
                                  final connected = result.any(
                                    (
                                      e,
                                    ) =>
                                        e != ConnectivityResult.none,
                                  );

                                  if (connected) {
                                    await syncService.syncAll();
                                  }
                                },
                              );

                              if (mounted) {
                                Navigator.pop(
                                  context,
                                );
                              }
                            } catch (e) {
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