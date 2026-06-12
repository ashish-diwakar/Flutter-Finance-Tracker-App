import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/category_model.dart';
import '../providers/category_repository_provider.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../../../shared/providers/currency_provider.dart';

class ManageCategoriesScreen
    extends ConsumerStatefulWidget {

  const ManageCategoriesScreen({
    super.key,
  });

  @override
  ConsumerState<ManageCategoriesScreen>
      createState() =>
          _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState
    extends ConsumerState<
        ManageCategoriesScreen> {

  List<CategoryModel> categories =
      [];

  bool loading = true;

  @override
  void initState() {

    super.initState();

    loadCategories();
  }

  Future<void> loadCategories()
  async {

    if (mounted) {

      setState(() {
        loading = true;
      });
    }

    try {

      final repository =
          await ref.read(
        categoryRepositoryProvider
            .future,
      );

      final result =
          await repository
              .getAllCategories();

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content: Text(
            'Unable to load categories',
          ),
        ),
      );
    }
  }

  Future<void> showCategoryDialog({
    CategoryModel? category,
  }) async {

    final formKey =
        GlobalKey<FormState>();

    final nameController =
        TextEditingController(
      text: category?.name ?? '',
    );

    final budgetController =
        TextEditingController(
      text:
          category?.monthlyBudget !=
                  null
              ? (category!
                          .monthlyBudget! /
                      100)
                  .toString()
              : '',
    );

    String type =
        category?.type ??
            'expense';

    bool saving = false;

    final repository =
        await ref.read(
      categoryRepositoryProvider
          .future,
    );
    
    // final syncService = await ref.read(
    //     syncServiceProvider.future,
    // );

    if (!mounted) {
      return;
    }

    await showDialog(

      context: context,

      barrierDismissible:
          false,

      builder:
          (dialogContext) {

        return StatefulBuilder(

          builder: (
            context,
            setDialogState,
          ) {

            Future<void>
                saveCategory()
            async {

              FocusScope.of(
                context,
              ).unfocus();

              if (!formKey
                  .currentState!
                  .validate()) {

                return;
              }

              if (saving) {
                return;
              }
              setDialogState(() {
                saving = true;
              });

              try {

                final parsedBudget =
                    double.tryParse(
                  budgetController.text
                      .trim(),
                );


                final budget =
                    parsedBudget !=
                            null
                        ? (parsedBudget *
                                100)
                            .toInt()
                        : null;


                if (category ==
                    null) {

                  final newCategory =
                      CategoryModel()
                        ..uuid = const Uuid().v4()

                        ..name =
                            nameController
                                .text
                                .trim()

                        ..type =
                            type

                        ..monthlyBudget =
                            budget

                        ..isDefault =
                            false

                        ..isDeleted =
                            false

                        ..isSynced =
                            false

                        ..updatedAt =
                            DateTime.now().toUtc();

                  await repository
                      .addCategory(
                    newCategory,
                  );

                  //await syncService.syncAll();

                } else {

                  final updatedCategory =
                    CategoryModel()

                      ..uuid = category.uuid

                      ..name =
                          nameController.text
                              .trim()

                      ..type = type

                      ..monthlyBudget =
                          budget

                      ..isDefault =
                          category.isDefault

                      ..isDeleted =
                          category.isDeleted

                      ..isSynced = false

                      ..updatedAt =
                          DateTime.now().toUtc();

                  await repository
                      .updateCategory(
                    updatedCategory,
                  );

                  //await syncService.syncAll();
                }

                if (!mounted) {
                  return;
                }

                await loadCategories();

                if (!mounted) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop();

                ScaffoldMessenger.of(
                  this.context,
                ).showSnackBar(

                  SnackBar(

                    content: Text(
                      category == null
                          ? 'Category added successfully'
                          : 'Category updated successfully',
                    ),
                  ),
                );

              } catch (_) {

                if (!mounted) {
                  return;
                }

                try {

                  setDialogState(() {
                    saving = false;
                  });

                } catch (_) {}
                
                ScaffoldMessenger.of(
                  this.context,
                ).showSnackBar(

                  const SnackBar(

                    content: Text(
                      'Unable to save category',
                    ),
                  ),
                );
              }
            }


            return AlertDialog(

              title: Text(
                category == null
                    ? 'Add Category'
                    : 'Edit Category',
              ),

              content:
                  SingleChildScrollView(

                child: Form(

                  key: formKey,

                  child: Column(

                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      TextFormField(

                        controller:
                            nameController,

                        enabled:
                            !saving,

                        textCapitalization:
                            TextCapitalization
                                .words,

                        validator:
                            (value) {

                          if (value ==
                                  null ||
                              value
                                  .trim()
                                  .isEmpty) {

                            return 'Category name is required';
                          }

                          if (value
                                  .trim()
                                  .length <
                              2) {

                            return 'Minimum 2 characters required';
                          }

                          return null;
                        },

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Category Name',

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
                              'Category Type',

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
                            saving
                                ? null
                                : (value) {

                                    if (value ==
                                        null) {
                                      return;
                                    }

                                    setDialogState(() {
                                      type =
                                          value;
                                    });
                                  },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextFormField(

                        controller:
                            budgetController,

                        enabled:
                            !saving,

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

                            return null;
                          }

                          final amount =
                              double.tryParse(
                            value.trim(),
                          );

                          if (amount ==
                              null) {

                            return 'Enter valid budget';
                          }

                          if (amount <
                              0) {

                            return 'Budget cannot be negative';
                          }

                          if (amount >
                              999999999) {

                            return 'Budget is too large';
                          }

                          return null;
                        },

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Monthly Budget',

                          hintText:
                              'Optional',

                          prefixText:
                              '₹ ',

                          border:
                              OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [

                TextButton(

                  onPressed:
                      saving
                          ? null
                          : () {
                              Navigator.of(
                                dialogContext,
                              ).pop();
                            },

                  child: const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(

                  onPressed:
                      saving
                          ? null
                          : () {
                            saveCategory();                            
                          },

                  child: saving

                      ? const SizedBox(

                          height: 20,
                          width: 20,

                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )

                      : const Text(
                          'Save',
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    //nameController.dispose();

    //budgetController.dispose();
  }

  Future<void> deleteCategory(
    CategoryModel category,
  ) async {

    final confirm =
        await showDialog<bool>(

      context: context,

      builder:
          (dialogContext) {

        return AlertDialog(

          title: const Text(
            'Delete Category',
          ),

          content: Text(
            'Delete "${category.name}"?',
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.of(
                  dialogContext,
                ).pop(false);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(

              onPressed: () {

                Navigator.of(
                  dialogContext,
                ).pop(true);
              },

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {

      final repository =
          await ref.read(
        categoryRepositoryProvider
            .future,
      );

      await repository
          .deleteCategory(
        category,
      );

      await loadCategories();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content: Text(
            'Category deleted',
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
            'Unable to delete category',
          ),
        ),
      );
    }
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
          'Manage Categories',
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

          heroTag:
            'managecategories_fab',

          onPressed: () {

            showCategoryDialog();
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

          : categories.isEmpty

              ? const Center(
                  child: Text(
                    'No categories found',
                  ),
                )

              : ListView.builder(

                  padding:
                      const EdgeInsets.only(
                    bottom: 100,
                  ),

                  itemCount:
                      categories.length,

                  itemBuilder:
                      (
                    context,
                    index,
                  ) {

                    final category =
                        categories[
                            index];

                    print('``````````````````category``````````````````````````````');
                    print('``````````````````title: ${category.name}``````````````````````````````');
                    print('``````````````````type: ${category.type}``````````````````````````````');
                    print('``````````````````monthlyBudget: ${category.monthlyBudget}``````````````````````````````');
                    print('``````````````````category``````````````````````````````');

                    return Card(

                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      child: ListTile(

                        title: Text(
                          category.name,
                        ),

                        subtitle: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              category.type
                                  .toUpperCase(),
                            ),

                            if (category
                                    .monthlyBudget !=
                                null)

                              Padding(

                                padding:
                                    const EdgeInsets.only(
                                  top: 4,
                                ),

                                child: Text(

                                  'Budget: ${
                                      CurrencyFormatter.format(
                                      amount: category.monthlyBudget!,
                                      currency: currency,
                                      )
                                    }',

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        trailing: Row(

                          mainAxisSize:
                              MainAxisSize.min,

                          children: [

                            IconButton(

                              onPressed: () {

                                showCategoryDialog(
                                  category:
                                      category,
                                );
                              },

                              icon:
                                  const Icon(
                                Icons.edit,
                              ),
                            ),

                            if (!category
                                .isDefault)

                              IconButton(

                                onPressed:
                                    () {

                                  deleteCategory(
                                    category,
                                  );
                                },

                                icon:
                                    const Icon(
                                  Icons.delete,
                                ),
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
