import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/recurring_transaction_model.dart';

import '../../../../shared/utils/provider_refresh_helper.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';

import '../providers/recurring_provider.dart';

class AddRecurringTransactionScreen
    extends ConsumerStatefulWidget {

  final RecurringTransactionModel?
      recurring;

  const AddRecurringTransactionScreen({
    super.key,
    this.recurring,
  });

  @override
  ConsumerState<
      AddRecurringTransactionScreen>
      createState() =>
          _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState
    extends ConsumerState<
        AddRecurringTransactionScreen> {

  final formKey =
      GlobalKey<FormState>();

  final amountController =
      TextEditingController();

  final notesController =
      TextEditingController();

  String type = 'expense';

  String frequency =
      'monthly';

  int interval = 1;

  DateTime startDate =
      DateTime.now().toUtc();

  DateTime? endDate;

  String? selectedCategoryId;

  String? selectedAccountId;

  bool active = true;

  bool saving = false;

  @override
  void initState() {

    super.initState();

    final recurring =
        widget.recurring;

    if (recurring != null) {

      amountController.text =
          (recurring.amount / 100)
              .toStringAsFixed(2);

      notesController.text =
          recurring.notes ?? '';

      type =
          recurring.type;

      frequency =
          recurring.frequency;

      interval =
          recurring.interval;

      startDate =
          recurring.startDate;

      endDate =
          recurring.endDate;

      selectedCategoryId =
          recurring.categoryId;

      selectedAccountId =
          recurring.accountId;

      active =
          recurring.isActive;
    }
  }

  @override
  void dispose() {

    amountController.dispose();

    notesController.dispose();

    super.dispose();
  }

  Future<void> saveRecurring()
  async {

    FocusScope.of(
      context,
    ).unfocus();

    if (!formKey
        .currentState!
        .validate()) {

      return;
    }

    if (selectedCategoryId ==
        null) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content: Text(
            'Select category',
          ),
        ),
      );

      return;
    }

    if (selectedAccountId ==
        null) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content: Text(
            'Select account',
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {

      final repository =
          await ref.read(
        recurringRepositoryProvider
            .future,
      );

      final amount =
          ((double.parse(
                        amountController
                            .text
                            .trim(),
                      ) *
                      100)
                  .round());

      final recurring =
          widget.recurring ??
              RecurringTransactionModel();
      recurring.uuid =
          widget.recurring?.uuid ??
              const Uuid().v4();

      recurring.amount =
          amount;

      recurring.type =
          type;

      recurring.categoryId =
          selectedCategoryId!;

      recurring.accountId =
          selectedAccountId!;

      recurring.notes =
          notesController.text
              .trim();

      recurring.frequency =
          frequency;

      recurring.interval =
          interval;

      recurring.startDate =
          startDate;

      recurring.endDate =
          endDate;

      if (widget.recurring == null) {

        recurring.nextRunDate =
            startDate;
      }

      recurring.isActive =
          active;

      recurring.updatedAt =
          DateTime.now().toUtc();

      recurring.isDeleted =
          false;

      recurring.isSynced =
          false;

      await repository
          .updateRecurring(
        recurring,
      );

      if (!mounted) {
        return;
      }

      await ProviderRefreshHelper
        .refreshRecurringTransactionData(ref);

      // ref.invalidate(
      //   recurringTransactionsProvider,
      // );

      Navigator.pop(
        context,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(

          content: Text(

            widget.recurring ==
                    null

                ? 'Recurring transaction added'

                : 'Recurring transaction updated',
          ),
        ),
      );

    } catch (_) {

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            'Unable to save recurring transaction',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final accountsAsync =
        ref.watch(
      accountsProvider,
    );

    final categoriesAsync =
        ref.watch(
      categoriesProvider(
        type,
      ),
    );

    return Scaffold(

      appBar: AppBar(

        title: Text(

          widget.recurring ==
                  null

              ? 'Add Recurring'

              : 'Edit Recurring',
        ),
      ),

      body: accountsAsync.when(

        data: (accounts) {

          return categoriesAsync.when(

            data: (categories) {

              return Form(

                key: formKey,

                child:
                    SingleChildScrollView(

                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    40,
                  ),

                  child: Column(

                    children: [

                      TextFormField(

                        controller:
                            amountController,

                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),

                        inputFormatters: [

                          FilteringTextInputFormatter
                              .allow(
                            RegExp(
                              r'^\d*\.?\d{0,2}',
                            ),
                          ),
                        ],

                        validator:
                            (value) {

                          if (value ==
                                  null ||
                              value
                                  .trim()
                                  .isEmpty) {

                            return 'Enter amount';
                          }

                          final amount =
                              double.tryParse(
                            value.trim(),
                          );

                          if (amount ==
                              null) {

                            return 'Invalid amount';
                          }

                          if (amount <=
                              0) {

                            return 'Amount must be greater than 0';
                          }

                          return null;
                        },

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Amount',

                          prefixText:
                              '₹ ',

                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      DropdownButtonFormField<
                          String>(

                        value: type,

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Type',

                          border:
                              OutlineInputBorder(),
                        ),

                        items: const [

                          DropdownMenuItem(

                            value:
                                'expense',

                            child: Text(
                              'Expense',
                            ),
                          ),

                          DropdownMenuItem(

                            value:
                                'income',

                            child: Text(
                              'Income',
                            ),
                          ),
                        ],

                        onChanged:
                            (value) {

                          if (value ==
                              null) {
                            return;
                          }

                          setState(() {

                            type =
                                value;

                            selectedCategoryId =
                                null;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      DropdownButtonFormField<
                          String>(

                        value:
                            selectedCategoryId,

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Category',

                          border:
                              OutlineInputBorder(),
                        ),

                        items:
                            categories.map(
                          (
                            CategoryModel
                                category,
                          ) {

                            return DropdownMenuItem(

                              value:
                                  category.uuid,

                              child: Text(
                                category.name,
                              ),
                            );
                          },
                        ).toList(),

                        onChanged:
                            (value) {

                          setState(() {

                            selectedCategoryId =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      DropdownButtonFormField<
                          String>(

                        value:
                            selectedAccountId,

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Account',

                          border:
                              OutlineInputBorder(),
                        ),

                        items:
                            accounts.map(
                          (
                            AccountModel
                                account,
                          ) {

                            return DropdownMenuItem(

                              value:
                                  account.uuid,

                              child: Text(
                                account.name,
                              ),
                            );
                          },
                        ).toList(),

                        onChanged:
                            (value) {

                          setState(() {

                            selectedAccountId =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextFormField(

                        controller:
                            notesController,

                        maxLines: 3,

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Notes',

                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      DropdownButtonFormField<
                          String>(

                        value:
                            frequency,

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Frequency',

                          border:
                              OutlineInputBorder(),
                        ),

                        items: const [

                          DropdownMenuItem(

                            value:
                                'daily',

                            child: Text(
                              'Daily',
                            ),
                          ),

                          DropdownMenuItem(

                            value:
                                'weekly',

                            child: Text(
                              'Weekly',
                            ),
                          ),

                          DropdownMenuItem(

                            value:
                                'monthly',

                            child: Text(
                              'Monthly',
                            ),
                          ),

                          DropdownMenuItem(

                            value:
                                'yearly',

                            child: Text(
                              'Yearly',
                            ),
                          ),
                        ],

                        onChanged:
                            (value) {

                          if (value ==
                              null) {
                            return;
                          }

                          setState(() {

                            frequency =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      DropdownButtonFormField<
                          int>(

                        value: interval,

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Interval',

                          border:
                              OutlineInputBorder(),
                        ),

                        items:
                            List.generate(
                          12,
                          (index) {

                            final value =
                                index + 1;

                            return DropdownMenuItem(

                              value:
                                  value,

                              child: Text(

                                  frequency == 'daily'

                                      ? 'Every $value day(s)'

                                      : frequency == 'weekly'

                                          ? 'Every $value week(s)'

                                          : frequency == 'monthly'

                                              ? 'Every $value month(s)'

                                              : 'Every $value year(s)',
                                ),
                            );
                          },
                        ),

                        onChanged:
                            (value) {

                          if (value ==
                              null) {
                            return;
                          }

                          setState(() {

                            interval =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      ListTile(

                        contentPadding:
                            EdgeInsets.zero,

                        title: const Text(
                          'Start Date',
                        ),

                        subtitle: Text(
                          DateFormat(
                            'dd MMM yyyy',
                          ).format(
                            startDate,
                          ),
                        ),

                        trailing:
                            const Icon(
                          Icons.calendar_today,
                        ),

                        onTap: () async {

                          final picked =
                              await showDatePicker(

                            context:
                                context,

                            initialDate:
                                startDate,

                            firstDate:
                                DateTime(2020),

                            lastDate:
                                DateTime(2100),
                          );

                          if (picked !=
                              null) {

                            setState(() {

                              startDate =
                                  picked;
                            });
                          }
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      SwitchListTile(

                        value: active,

                        title: const Text(
                          'Active',
                        ),

                        onChanged:
                            (value) {

                          setState(() {

                            active =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      SizedBox(

                        width:
                            double.infinity,

                        child:
                            ElevatedButton(

                          onPressed:
                              saving
                                  ? null
                                  : saveRecurring,

                          child: saving

                              ? const SizedBox(

                                  height:
                                      20,

                                  width:
                                      20,

                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )

                              : Text(

                                  widget.recurring ==
                                          null

                                      ? 'Add Recurring'

                                      : 'Update Recurring',
                                ),
                        ),
                      ),
                      
                      const SizedBox(
                        height: 24,
                      ),

                    ],
                  ),
                ),
              );
            },

            error: (_, __) =>

                const Center(
                  child: Text(
                    'Unable to load categories',
                  ),
                ),

            loading: () =>

                const Center(
                  child:
                      CircularProgressIndicator(),
                ),
          );
        },

        error: (_, __) =>

            const Center(
              child: Text(
                'Unable to load accounts',
              ),
            ),

        loading: () =>

            const Center(
              child:
                  CircularProgressIndicator(),
            ),
      ),
    );
  }
}