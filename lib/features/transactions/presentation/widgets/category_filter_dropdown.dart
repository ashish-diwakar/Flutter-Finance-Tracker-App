import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/category_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../providers/transaction_filter_provider.dart';

class CategoryFilterDropdown extends ConsumerWidget {
  const CategoryFilterDropdown({
    super.key,
  });

  static const String _allCategoriesValue =
      '__all_categories__';

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final categoriesAsync =
        ref.watch(
      allCategoriesProvider,
    );

    final filter =
        ref.watch(
      transactionFilterProvider,
    );

    return categoriesAsync.when(
      loading: () =>
          const Center(
        child:
            CircularProgressIndicator(),
      ),
      error: (_, _) =>
          const Text(
        'Unable to load categories',
      ),
      data: (categories) {
        final selectedValue =
            filter.categoryId ??
                _allCategoriesValue;

        return DropdownButtonFormField<String>(
          key: ValueKey(
            selectedValue,
          ),
          initialValue:
              selectedValue,
          decoration:
              const InputDecoration(
            labelText:
                'Category',
            border:
                OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String>(
              value:
                  _allCategoriesValue,
              child: Text(
                'All Categories',
              ),
            ),
            ...categories.map(
              (CategoryModel category) {
                return DropdownMenuItem<String>(
                  value:
                      category.uuid,
                  child: Text(
                    category.name,
                  ),
                );
              },
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            ref
                .read(
                  transactionFilterProvider.notifier,
                )
                .setCategoryId(
                  value ==
                          _allCategoriesValue
                      ? null
                      : value,
                );
          },
        );
      },
    );
  }
}
