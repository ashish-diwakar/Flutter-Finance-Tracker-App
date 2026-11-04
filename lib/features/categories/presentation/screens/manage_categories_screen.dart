import 'package:finance_tracker/features/categories/presentation/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../../shared/models/category_model.dart';
import '../providers/category_repository_provider.dart';
import '../../../../shared/providers/currency_provider.dart';

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  ConsumerState<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState
    extends ConsumerState<ManageCategoriesScreen> {
  List<CategoryModel> categories = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadCategories();
  }

  Future<void> loadCategories() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      final repository = await ref.read(categoryRepositoryProvider.future);

      final result = await repository.getAllCategories();

      if (!mounted) {
        return;
      }

      setState(() {
        categories = result;

        loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load categories')),
      );
    }
  }

  InputDecoration _categoryInputDecoration({
    required String labelText,
    String? hintText,
    String? prefixText,
  }) {
    const enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFFB5D9CA)),
    );
    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFF3E8877), width: 1.6),
    );
    const errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFFB54C44)),
    );

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      filled: true,
      fillColor: const Color(0xFFFCFEFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      labelStyle: const TextStyle(color: Color(0xFF536B61), fontSize: 16),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF315F53),
        fontSize: 21,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(color: Color(0xFF6C8A80), fontSize: 16),
      prefixStyle: const TextStyle(color: Color(0xFF244C40), fontSize: 18),
      errorStyle: const TextStyle(color: Color(0xFF9E3F38), fontSize: 14),
      errorMaxLines: 2,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: focusedBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFB54C44), width: 1.6),
      ),
    );
  }

  Future<void> showCategoryDialog({CategoryModel? category}) async {
    final formKey = GlobalKey<FormState>();
    final budgetNumberFormat = NumberFormat('#,##,##0.00', 'en_IN');

    final nameController = TextEditingController(text: category?.name ?? '');

    final initialBudgetInput = category?.monthlyBudget == null
        ? null
        : (category!.monthlyBudget! / 100).toStringAsFixed(2);
    final budgetController = TextEditingController(
      text: category?.monthlyBudget != null
          ? (category!.monthlyBudget! / 100).toString()
          : '',
    );
    final budgetFocusNode = FocusNode();
    budgetFocusNode.addListener(() {
      final text = budgetController.text;
      if (text.isEmpty) {
        return;
      }

      if (budgetFocusNode.hasFocus) {
        final selectionOffset = budgetController.selection.extentOffset;
        if (text.contains(',')) {
          final commasBeforeSelection = selectionOffset < 0
              ? 0
              : ','.allMatches(text.substring(0, selectionOffset)).length;
          final ungrouped = text.replaceAll(',', '');
          budgetController.value = TextEditingValue(
            text: ungrouped,
            selection: TextSelection.collapsed(
              offset: selectionOffset < 0
                  ? ungrouped.length
                  : (selectionOffset - commasBeforeSelection).clamp(
                      0,
                      ungrouped.length,
                    ),
            ),
          );
        }
      } else {
        final normalized = text.replaceAll(',', '');
        final amount = double.tryParse(normalized);
        if (amount != null) {
          budgetController.value = TextEditingValue(
            text: budgetNumberFormat.format(amount),
            selection: TextSelection.collapsed(
              offset: budgetNumberFormat.format(amount).length,
            ),
          );
        }
      }
    });

    String type = category?.type ?? 'expense';

    bool saving = false;

    final repository = await ref.read(categoryRepositoryProvider.future);

    // final syncService = await ref.read(
    //     syncServiceProvider.future,
    // );

    if (!mounted) {
      budgetFocusNode.dispose();
      nameController.dispose();
      budgetController.dispose();
      return;
    }

    Future<dynamic>? dialogRouteCompleted;

    await showDialog(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        dialogRouteCompleted ??= ModalRoute.of(dialogContext)!.completed;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveCategory() async {
              FocusScope.of(context).unfocus();

              if (!formKey.currentState!.validate()) {
                return;
              }

              if (saving) {
                return;
              }
              setDialogState(() {
                saving = true;
              });

              try {
                final normalizedBudget = budgetController.text
                    .trim()
                    .replaceAll(',', '');
                final parsedBudget = double.tryParse(normalizedBudget);
                final budget =
                    category?.monthlyBudget != null &&
                        normalizedBudget == initialBudgetInput
                    ? category!.monthlyBudget
                    : parsedBudget != null
                    ? (parsedBudget * 100).toInt()
                    : null;

                if (category == null) {
                  final newCategory = CategoryModel()
                    ..uuid = const Uuid().v4()
                    ..name = nameController.text.trim()
                    ..type = type
                    ..monthlyBudget = budget
                    ..isDefault = false
                    ..isDeleted = false
                    ..isSynced = false
                    ..updatedAt = DateTime.now().toUtc();

                  await repository.addCategory(newCategory);

                  ref.invalidate(categoriesProvider('income'));
                  ref.invalidate(categoriesProvider('expense'));
                  ref.invalidate(allCategoriesProvider);
                } else {
                  // final updatedCategory =
                  //   CategoryModel()

                  //     ..uuid = category.uuid

                  //     ..name =
                  //         nameController.text
                  //             .trim()

                  //     ..type = type

                  //     ..monthlyBudget =
                  //         budget

                  //     ..isDefault =
                  //         category.isDefault

                  //     ..isDeleted =
                  //         category.isDeleted

                  //     ..isSynced = false

                  //     ..updatedAt =
                  //         DateTime.now().toUtc();

                  // await repository
                  //     .updateCategory(
                  //   updatedCategory,
                  // );

                  category
                    ..name = nameController.text.trim()
                    ..type = type
                    ..monthlyBudget = budget
                    ..isSynced = false
                    ..updatedAt = DateTime.now().toUtc();

                  await repository.updateCategory(category);

                  ref.invalidate(categoriesProvider('income'));
                  ref.invalidate(categoriesProvider('expense'));
                  ref.invalidate(allCategoriesProvider);
                  //await syncService.syncAll();
                }

                if (!mounted) {
                  return;
                }

                await loadCategories();

                if (!mounted) {
                  return;
                }

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      category == null
                          ? 'Category added successfully'
                          : 'Category updated successfully',
                    ),
                  ),
                );

                // } catch (_) {

                //   if (!mounted) {
                //     return;
                //   }

                //   try {

                //     setDialogState(() {
                //       saving = false;
                //     });

                //   } catch (_) {}

                //   ScaffoldMessenger.of(
                //     this.context,
                //   ).showSnackBar(

                //     const SnackBar(

                //       content: Text(
                //         'Unable to save category',
                //       ),
                //     ),
                //   );
                // }
              } catch (e, stackTrace) {
                debugPrint('SAVE CATEGORY ERROR: $e');

                debugPrint(stackTrace.toString());

                if (!mounted) {
                  return;
                }

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Unable to save category')),
                );
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFFF3FAF5),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              constraints: const BoxConstraints(maxWidth: 440),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              scrollable: true,
              titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              actionsOverflowButtonSpacing: 8,
              title: Text(
                category == null ? 'Add Category' : 'Edit Category',
                style: const TextStyle(
                  color: Color(0xFF315F53),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        enabled: !saving,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          color: Color(0xFF244C40),
                          fontSize: 18,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Category name is required';
                          }

                          final trimmedName = value.trim();

                          if (trimmedName.length < 2) {
                            return 'Minimum 2 characters required';
                          }

                          final normalizedName = trimmedName.toLowerCase();

                          final isDuplicate = categories.any((existing) {
                            return existing.uuid != category?.uuid &&
                                existing.type == type &&
                                existing.name.trim().toLowerCase() ==
                                    normalizedName;
                          });

                          if (isDuplicate) {
                            return 'Category name already exists for this type';
                          }

                          return null;
                        },
                        decoration: _categoryInputDecoration(
                          labelText: 'Category Name',
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
                        decoration: _categoryInputDecoration(
                          labelText: 'Category Type',
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
                        onChanged: saving
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }

                                setDialogState(() {
                                  type = value;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: budgetController,
                        focusNode: budgetFocusNode,
                        enabled: !saving,
                        style: const TextStyle(
                          color: Color(0xFF244C40),
                          fontSize: 18,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }

                          final amount = double.tryParse(
                            value.trim().replaceAll(',', ''),
                          );

                          if (amount == null) {
                            return type == 'expense'
                                ? 'Enter valid budget'
                                : 'Enter valid income target';
                          }

                          if (amount < 0) {
                            return type == 'expense'
                                ? 'Budget cannot be negative'
                                : 'Income target cannot be negative';
                          }

                          if (amount > 999999999) {
                            return type == 'expense'
                                ? 'Budget is too large'
                                : 'Income target is too large';
                          }

                          return null;
                        },
                        decoration: _categoryInputDecoration(
                          labelText: type == 'expense'
                              ? 'Monthly Budget'
                              : 'Monthly Income Target',
                          hintText: type == 'expense'
                              ? 'Optional spending limit'
                              : 'Optional income target',
                          prefixText: '₹ ',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },

                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF315F53),
                    minimumSize: const Size(88, 48),
                    side: const BorderSide(color: Color(0xFFB5D9CA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: saving
                      ? null
                      : () {
                          saveCategory();
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF17664F),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(88, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    await dialogRouteCompleted!;
    budgetFocusNode.dispose();
    nameController.dispose();
    budgetController.dispose();
  }

  Future<void> deleteCategory(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF3FAF5),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          constraints: const BoxConstraints(maxWidth: 440),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          scrollable: true,
          titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          actionsOverflowButtonSpacing: 8,
          title: const Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFBE6E3),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.delete_outline, color: Color(0xFFB54C44)),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Category',
                  style: TextStyle(
                    color: Color(0xFF315F53),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Text(
              'Delete "${category.name}"?',
              style: const TextStyle(color: Color(0xFF244C40), fontSize: 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF315F53),
                minimumSize: const Size(88, 48),
                side: const BorderSide(color: Color(0xFFB5D9CA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB54C44),
                foregroundColor: Colors.white,
                minimumSize: const Size(104, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      final repository = await ref.read(categoryRepositoryProvider.future);

      await repository.deleteCategory(category);

      await loadCategories();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Category deleted')));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Manage Categories')),

      floatingActionButton: FloatingActionButton(
        heroTag: 'managecategories_fab',
        tooltip: 'Add Category',
        backgroundColor: const Color(0xFF17664F),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        onPressed: () {
          showCategoryDialog();
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
            : categories.isEmpty
            ? const Center(child: Text('No categories found'))
            : ListView.builder(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 100,
                ),

                itemCount: categories.length,

                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isIncome = category.type == 'income';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    color: const Color(0xFFF1F8F2),
                    surfaceTintColor: Colors.transparent,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFB8D8CA)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        color: Color(0xFF244D3F),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isIncome
                                            ? const Color(0xFFDFF1E5)
                                            : const Color(0xFFFBE8E3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        category.type.toUpperCase(),
                                        style: TextStyle(
                                          color: isIncome
                                              ? const Color(0xFF237F50)
                                              : const Color(0xFFB54C44),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filledTonal(
                                tooltip: 'Edit Category',
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
                                  showCategoryDialog(category: category);
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              if (!category.isDefault)
                                const SizedBox(width: 12),
                              if (!category.isDefault)
                                IconButton.filledTonal(
                                  tooltip: 'Delete Category',
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFFBE9E5),
                                    foregroundColor: const Color(0xFFB54C44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  onPressed: () {
                                    deleteCategory(category);
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                            ],
                          ),
                          if (category.monthlyBudget != null) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFD5E6DC)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  isIncome ? 'Income Target' : 'Budget',
                                  style: const TextStyle(
                                    color: Color(0xFF536B61),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(
                                    amount: category.monthlyBudget!,
                                    currency: currency,
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF244D3F),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
