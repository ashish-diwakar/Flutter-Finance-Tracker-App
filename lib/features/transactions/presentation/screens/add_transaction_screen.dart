import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/transaction_validator.dart';
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../providers/transaction_repository_provider.dart';
import '../../../sync/presentation/providers/sync_provider.dart';

class AddTransactionScreen
    extends ConsumerStatefulWidget {

  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen>
      createState() =>
          _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {

  final formKey = GlobalKey<FormState>();

  final amountController =
      TextEditingController();

  final notesController =
      TextEditingController();

  String transactionType = 'expense';

  CategoryModel? selectedCategory;

  AccountModel? selectedAccount;

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {

    final categoriesAsync =
        ref.watch(
          categoriesProvider(transactionType),
        );

    final accountsAsync =
        ref.watch(accountsProvider);

    return Scaffold(

      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: formKey,

          child: ListView(
            children: [

              DropdownButtonFormField<String>(
                value: transactionType,

                items: const [

                  DropdownMenuItem(
                    value: 'income',
                    child: Text('Income'),
                  ),

                  DropdownMenuItem(
                    value: 'expense',
                    child: Text('Expense'),
                  ),
                ],

                onChanged: (value) {

                  setState(() {

                    transactionType = value!;

                    selectedCategory = null;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: amountController,

                keyboardType:
                    TextInputType.number,

                validator: (value) =>
                    TransactionValidator
                        .validateAmount(
                          value ?? '',
                        ),

                decoration:
                    const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              categoriesAsync.when(

                data: (categories) {

                  return DropdownButtonFormField<
                      CategoryModel>(

                    value: selectedCategory,

                    decoration:
                        const InputDecoration(
                      labelText: 'Category',
                      border:
                          OutlineInputBorder(),
                    ),

                    items: categories.map((e) {

                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      );
                    }).toList(),

                    onChanged: (value) {

                      setState(() {

                        selectedCategory =
                            value;
                      });
                    },
                  );
                },

                error: (e, s) =>
                    Text(e.toString()),

                loading: () =>
                    const CircularProgressIndicator(),
              ),

              const SizedBox(height: 16),

              accountsAsync.when(

                data: (accounts) {

                  return DropdownButtonFormField<
                      AccountModel>(

                    value: selectedAccount,

                    decoration:
                        const InputDecoration(
                      labelText: 'Account',
                      border:
                          OutlineInputBorder(),
                    ),

                    items: accounts.map((e) {

                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      );
                    }).toList(),

                    onChanged: (value) {

                      setState(() {

                        selectedAccount =
                            value;
                      });
                    },
                  );
                },

                error: (e, s) =>
                    Text(e.toString()),

                loading: () =>
                    const CircularProgressIndicator(),
              ),

              const SizedBox(height: 16),

              ListTile(

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                  side: const BorderSide(),
                ),

                title: const Text('Date'),

                subtitle:
                    Text(selectedDate.toString()),

                trailing:
                    const Icon(Icons.calendar_today),

                onTap: () async {

                  final picked =
                      await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate:
                        DateTime(2020),
                    lastDate:
                        DateTime(2100),
                  );

                  if (picked != null) {

                    setState(() {

                      selectedDate = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: notesController,

                maxLines: 3,

                decoration:
                    const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(

                onPressed: () async {

                  if (!formKey.currentState!
                      .validate()) {
                    return;
                  }

                  if (selectedCategory ==
                      null) {
                    return;
                  }

                  if (selectedAccount ==
                      null) {
                    return;
                  }

                  final repository =
                      await ref.read(
                    transactionRepositoryProvider
                        .future,
                  );

                  final amount =
                      (double.parse(
                                amountController
                                    .text,
                              ) *
                              100)
                          .toInt();

                  final transaction =
                      TransactionModel()

                        ..amount = amount
                        ..type =
                            transactionType
                        ..transactionDate =
                            selectedDate
                        ..categoryId =
                            selectedCategory!
                                .id
                        ..accountId =
                            selectedAccount!
                                .id
                        ..notes =
                            notesController
                                .text
                        ..isSynced = false
                        ..updatedAt =
                            DateTime.now();

                  await repository
                      .addTransaction(
                    transaction,
                  );

                  final syncService =
                      await ref.read(
                    syncServiceProvider.future,
                  );

                  await syncService.syncAll();

                  if (mounted) {
                    Navigator.pop(context);
                  }
                },

                child:
                    const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}