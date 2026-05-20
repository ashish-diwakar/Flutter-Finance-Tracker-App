import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/category_model.dart';
import '../providers/category_repository_provider.dart';

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

    final repository =
        await ref.read(
      categoryRepositoryProvider.future,
    );

    final result =
        await repository
            .getAllCategories();

    setState(() {

      categories = result;

      loading = false;
    });
  }

  Future<void> showCategoryDialog({
    CategoryModel? category,
  }) async {

    final nameController =
        TextEditingController(
      text: category?.name ?? '',
    );

    String type =
        category?.type ?? 'expense';

    final repository =
        await ref.read(
      categoryRepositoryProvider.future,
    );

    if (!mounted) {
      return;
    }

    await showDialog(
      context: context,

      builder: (_) {

        return StatefulBuilder(

          builder: (
            context,
            setDialogState,
          ) {

            return AlertDialog(

              title: Text(
                category == null
                    ? 'Add Category'
                    : 'Edit Category',
              ),

              content: Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  TextField(
                    controller:
                        nameController,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Category Name',
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  DropdownButton<String>(

                    value: type,

                    isExpanded: true,

                    items: const [

                      DropdownMenuItem(
                        value:
                            'expense',
                        child:
                            Text(
                          'Expense',
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            'income',
                        child:
                            Text(
                          'Income',
                        ),
                      ),
                    ],

                    onChanged: (value) {

                      setDialogState(() {

                        type = value!;
                      });
                    },
                  ),
                ],
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

                    if (category ==
                        null) {

                      final newCategory =
                          CategoryModel()

                            ..name =
                                nameController
                                    .text
                                    .trim()

                            ..type = type

                            ..isDefault =
                                false

                            ..isSynced =
                                false

                            ..updatedAt =
                                DateTime.now();

                      await repository
                          .addCategory(
                        newCategory,
                      );

                    } else {

                      category.name =
                          nameController
                              .text
                              .trim();

                      category.type =
                          type;

                      await repository
                          .updateCategory(
                        category,
                      );
                    }

                    if (mounted) {

                      Navigator.pop(
                        context,
                      );

                      await loadCategories();
                    }
                  },

                  child: const Text(
                    'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Manage Categories',
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        onPressed: () {

          showCategoryDialog();
        },

        child: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView.builder(

              itemCount:
                  categories.length,

              itemBuilder:
                  (context, index) {

                final category =
                    categories[index];

                return ListTile(

                  title: Text(
                    category.name,
                  ),

                  subtitle: Text(
                    category.type,
                  ),

                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      if (!category
                          .isDefault)
                          
                        IconButton(

                          onPressed: () {

                            showCategoryDialog(
                              category:
                                  category,
                            );
                          },

                          icon: const Icon(
                            Icons.edit,
                          ),
                        ),

                      if (!category
                          .isDefault)

                        IconButton(

                          onPressed:
                              () async {

                            final repository =
                                await ref.read(
                              categoryRepositoryProvider
                                  .future,
                            );

                            await repository
                                .deleteCategory(
                              category.id,
                            );

                            await loadCategories();
                          },

                          icon:
                              const Icon(
                            Icons.delete,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}