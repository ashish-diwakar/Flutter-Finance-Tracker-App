import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/recurring_transaction_model.dart';

import '../../../../shared/utils/provider_refresh_helper.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';

import '../../data/recurring_repository.dart';
import '../providers/recurring_provider.dart';

class AddRecurringTransactionScreen extends ConsumerStatefulWidget {
  final RecurringTransactionModel? recurring;

  const AddRecurringTransactionScreen({super.key, this.recurring});

  @override
  ConsumerState<AddRecurringTransactionScreen> createState() =>
      _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState
    extends ConsumerState<AddRecurringTransactionScreen> {
  final formKey = GlobalKey<FormState>();

  final amountController = TextEditingController();

  final notesController = TextEditingController();

  String type = 'expense';

  String frequency = 'monthly';

  int interval = 1;

  DateTime startDate = DateTime.now();

  DateTime? endDate;

  String? selectedCategoryId;

  String? selectedAccountId;

  bool active = true;

  bool saving = false;
  bool? repairingReferences;
  String? relinkError;

  InputDecoration _auroraInputDecoration({
    required String labelText,
    String? prefixText,
  }) {
    const borderRadius = BorderRadius.all(Radius.circular(14));
    const enabledBorder = Color(0xFFB5D9CA);
    const focusedBorder = Color(0xFF3E8877);

    OutlineInputBorder outlineBorder(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: labelText,
      prefixText: prefixText,
      filled: true,
      fillColor: const Color(0xFFFCFEFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      labelStyle: const TextStyle(
        color: Color(0xFF315F53),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF315F53),
        fontSize: 21.34,
        fontWeight: FontWeight.w600,
      ),
      prefixStyle: const TextStyle(color: Color(0xFF244C40), fontSize: 18),
      errorStyle: const TextStyle(color: Color(0xFF9E3F38), fontSize: 14),
      errorMaxLines: 2,
      border: outlineBorder(enabledBorder),
      enabledBorder: outlineBorder(enabledBorder),
      focusedBorder: outlineBorder(focusedBorder, width: 1.6),
      errorBorder: outlineBorder(const Color(0xFFB54C44)),
      focusedErrorBorder: outlineBorder(const Color(0xFFB54C44), width: 1.6),
    );
  }

  @override
  void initState() {
    super.initState();

    final recurring = widget.recurring;

    if (recurring != null) {
      amountController.text = (recurring.amount / 100).toStringAsFixed(2);

      notesController.text = recurring.notes ?? '';

      type = recurring.type;

      frequency = recurring.frequency;

      interval = recurring.interval;

      startDate = recurring.startDate.toLocal();

      endDate = recurring.endDate?.toLocal();

      selectedCategoryId = recurring.categoryId;

      selectedAccountId = recurring.accountId;

      active = recurring.isActive;
    }
  }

  @override
  void dispose() {
    amountController.dispose();

    notesController.dispose();

    super.dispose();
  }

  Future<void> saveRecurring(String? accountId, String? categoryId) async {
    if (saving) return;
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select category')));

      return;
    }

    if (accountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select account')));

      return;
    }

    setState(() {
      saving = true;
      relinkError = null;
    });

    try {
      final repository = await ref.read(recurringRepositoryProvider.future);
      if (!mounted) return;

      if (repairingReferences == true) {
        await repository.relinkRecurring(
          widget.recurring!,
          accountId: accountId,
          categoryId: categoryId,
        );
      } else {
        final amount = ((double.parse(amountController.text.trim()) * 100)
            .round());

        final recurring = widget.recurring ?? RecurringTransactionModel();
        recurring.uuid = widget.recurring?.uuid ?? const Uuid().v4();

        recurring.amount = amount;

        recurring.type = type;

        recurring.categoryId = categoryId;

        recurring.accountId = accountId;

        recurring.notes = notesController.text.trim();

        recurring.frequency = frequency;

        recurring.interval = interval;

        recurring.startDate = startDate;

        recurring.endDate = endDate;

        if (widget.recurring == null) {
          recurring.nextRunDate = startDate;
        }

        recurring.isActive = active;

        recurring.updatedAt = DateTime.now().toUtc();

        recurring.isDeleted = false;

        recurring.isSynced = false;

        await repository.updateRecurring(recurring);
      }

      if (!mounted) {
        return;
      }

      await ProviderRefreshHelper.refreshRecurringTransactionData(ref);

      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);

      Navigator.pop(context);

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.recurring == null
                ? 'Recurring transaction added'
                : repairingReferences == true
                ? 'Recurring references repaired'
                : 'Recurring transaction updated',
          ),
        ),
      );
    } on RecurringRelinkException catch (error) {
      if (!mounted) return;
      setState(() => relinkError = error.message);
      ref.invalidate(accountsProvider);
      ref.invalidate(categoriesProvider(type));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save recurring transaction')),
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
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    final categoriesAsync = ref.watch(categoriesProvider(type));

    final screen = Scaffold(
      appBar: AuroraAppBar(
        title: Text(
          widget.recurring == null ? 'Add Recurring' : 'Edit Recurring',
        ),
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
        child: SafeArea(
          child: accountsAsync.when(
            data: (availableAccounts) {
              return categoriesAsync.when(
                data: (availableCategories) {
                  final accounts = availableAccounts.where(
                    (account) => !account.isDeleted,
                  );
                  final categories = availableCategories.where(
                    (category) => !category.isDeleted && category.type == type,
                  );
                  final accountId =
                      accounts.any(
                        (account) => account.uuid == selectedAccountId,
                      )
                      ? selectedAccountId
                      : null;
                  final categoryId =
                      categories.any(
                        (category) => category.uuid == selectedCategoryId,
                      )
                      ? selectedCategoryId
                      : null;
                  if (repairingReferences == null) {
                    repairingReferences =
                        widget.recurring != null &&
                        (accountId == null || categoryId == null);
                    selectedAccountId = accountId;
                    selectedCategoryId = categoryId;
                  }
                  final repairing = repairingReferences!;
                  return Form(
                    key: formKey,

                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),

                      child: Column(
                        children: [
                          if (repairing) ...[
                            const Text(
                              'Repair schedule references',
                              style: TextStyle(
                                color: Color(0xFF315F53),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Choose the account and category for this schedule. Saving updates its links and preserves its schedule details.',
                            ),
                          ] else ...[
                            TextFormField(
                              controller: amountController,
                              style: const TextStyle(
                                color: Color(0xFF244C40),
                                fontSize: 18,
                              ),

                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),

                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],

                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter amount';
                                }

                                final amount = double.tryParse(value.trim());

                                if (amount == null) {
                                  return 'Invalid amount';
                                }

                                if (amount <= 0) {
                                  return 'Amount must be greater than 0';
                                }

                                return null;
                              },

                              decoration: _auroraInputDecoration(
                                labelText: 'Amount',
                                prefixText: '₹ ',
                              ),
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              initialValue: type,
                              isExpanded: true,
                              style: const TextStyle(
                                color: Color(0xFF244C40),
                                fontSize: 18,
                              ),
                              decoration: _auroraInputDecoration(
                                labelText: 'Type',
                              ),

                              items: const [
                                DropdownMenuItem(
                                  value: 'expense',

                                  child: Text('Expense'),
                                ),

                                DropdownMenuItem(
                                  value: 'income',

                                  child: Text('Income'),
                                ),
                              ],

                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }

                                setState(() {
                                  type = value;

                                  selectedCategoryId = null;
                                });
                              },
                            ),
                          ],

                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            key: ValueKey(('category', categoryId)),
                            initialValue: categoryId,
                            isExpanded: true,
                            style: const TextStyle(
                              color: Color(0xFF244C40),
                              fontSize: 18,
                            ),
                            decoration:
                                _auroraInputDecoration(
                                  labelText: 'Category',
                                ).copyWith(
                                  helperText: repairing && categoryId == null
                                      ? 'Previously selected category is unavailable. Choose a category.'
                                      : null,
                                  helperMaxLines: 3,
                                ),

                            items: categories.map((CategoryModel category) {
                              return DropdownMenuItem(
                                value: category.uuid,

                                child: Text(
                                  category.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),

                            onChanged: saving
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedCategoryId = value;
                                    });
                                  },
                          ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            key: ValueKey(('account', accountId)),
                            initialValue: accountId,
                            isExpanded: true,
                            style: const TextStyle(
                              color: Color(0xFF244C40),
                              fontSize: 18,
                            ),
                            decoration:
                                _auroraInputDecoration(
                                  labelText: 'Account',
                                ).copyWith(
                                  helperText: repairing && accountId == null
                                      ? 'Previously selected account is unavailable. Choose an account.'
                                      : null,
                                  helperMaxLines: 3,
                                ),

                            items: accounts.map((AccountModel account) {
                              return DropdownMenuItem(
                                value: account.uuid,

                                child: Text(
                                  account.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),

                            onChanged: saving
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedAccountId = value;
                                    });
                                  },
                          ),

                          const SizedBox(height: 16),

                          if (!repairing) ...[
                            TextFormField(
                              controller: notesController,
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF244C40),
                                fontSize: 18,
                              ),
                              decoration: _auroraInputDecoration(
                                labelText: 'Notes',
                              ),
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              initialValue: frequency,
                              isExpanded: true,
                              style: const TextStyle(
                                color: Color(0xFF244C40),
                                fontSize: 18,
                              ),
                              decoration: _auroraInputDecoration(
                                labelText: 'Frequency',
                              ),

                              items: const [
                                DropdownMenuItem(
                                  value: 'daily',

                                  child: Text('Daily'),
                                ),

                                DropdownMenuItem(
                                  value: 'weekly',

                                  child: Text('Weekly'),
                                ),

                                DropdownMenuItem(
                                  value: 'monthly',

                                  child: Text('Monthly'),
                                ),

                                DropdownMenuItem(
                                  value: 'yearly',

                                  child: Text('Yearly'),
                                ),
                              ],

                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }

                                setState(() {
                                  frequency = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<int>(
                              initialValue: interval,
                              isExpanded: true,
                              style: const TextStyle(
                                color: Color(0xFF244C40),
                                fontSize: 18,
                              ),
                              decoration: _auroraInputDecoration(
                                labelText: 'Interval',
                              ),

                              items: List.generate(12, (index) {
                                final value = index + 1;

                                return DropdownMenuItem(
                                  value: value,
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
                              }),

                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }

                                setState(() {
                                  interval = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );

                                if (picked != null) {
                                  setState(() {
                                    startDate = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: _auroraInputDecoration(
                                  labelText: 'Start Date',
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat(
                                          'dd MMM yyyy',
                                        ).format(startDate),
                                        style: const TextStyle(
                                          color: Color(0xFF244C40),
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFF315F53),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Material(
                              color: const Color(0xFFFCFEFC),
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(color: Color(0xFFB5D9CA)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(14),
                                ),
                              ),
                              child: SwitchListTile(
                                value: active,
                                title: const Text(
                                  'Active',
                                  style: TextStyle(
                                    color: Color(0xFF315F53),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                activeTrackColor: const Color(0xFF17664F),
                                onChanged: (value) {
                                  setState(() {
                                    active = value;
                                  });
                                },
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          if (relinkError case final error?) ...[
                            Text(
                              error,
                              style: const TextStyle(color: Color(0xFF9E3F38)),
                            ),
                            const SizedBox(height: 12),
                          ],
                          SizedBox(
                            width: double.infinity,

                            child: FilledButton(
                              onPressed:
                                  saving ||
                                      (repairing &&
                                          (accountId == null ||
                                              categoryId == null))
                                  ? null
                                  : () => saveRecurring(accountId, categoryId),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF17664F),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: saving
                                  ? const SizedBox(
                                      height: 20,

                                      width: 20,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      widget.recurring == null
                                          ? 'Add Recurring'
                                          : repairing
                                          ? 'Save Repair'
                                          : 'Update Recurring',
                                    ),
                            ),
                          ),

                          if (repairing)
                            OutlinedButton(
                              onPressed: saving
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },

                error: (_, _) =>
                    const Center(child: Text('Unable to load categories')),

                loading: () => const Center(child: CircularProgressIndicator()),
              );
            },

            error: (_, _) =>
                const Center(child: Text('Unable to load accounts')),

            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
    return PopScope(canPop: !saving, child: screen);
  }
}
