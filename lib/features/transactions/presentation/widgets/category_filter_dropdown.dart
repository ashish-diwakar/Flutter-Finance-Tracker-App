import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/category_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../providers/transaction_filter_provider.dart';

class CategoryFilterDropdown extends ConsumerWidget {

  const CategoryFilterDropdown({
    super.key,
  });

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
            child: CircularProgressIndicator(),
          ),

      error: (_, __) =>
          const Text(
            'Unable to load categories',
          ),

      data: (categories) {

        return DropdownButtonFormField<String?>(

          value: filter.categoryId,

          decoration: const InputDecoration(

            labelText: 'Category',

            border: OutlineInputBorder(),
          ),

          items: [

            const DropdownMenuItem<String?>(

              value: null,

              child: Text(
                'All Categories',
              ),
            ),

            ...categories.map(

              (CategoryModel category) {

                return DropdownMenuItem<String?>(

                  value: category.uuid,

                  child: Text(
                    category.name,
                  ),
                );
              },
            ),
          ],

          onChanged: (value) {

            ref
                .read(
                  transactionFilterProvider.notifier,
                )
                .setCategoryId(
                  value,
                );
          },
        );
      },
    );
  }
}