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
          isExpanded: true,
          key: ValueKey(
            selectedValue,
          ),
          style: const TextStyle(
            color: Color(0xFF244C40),
            fontSize: 16,
          ),
          initialValue:
              selectedValue,
          decoration: InputDecoration(
            labelText: 'Category',
            labelStyle: const TextStyle(
              color: Color(0xFF536B61),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: const TextStyle(
              color: Color(0xFF536B61),
              fontSize: 18.67,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: const Color(0xEEFFFFFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFBDDBD1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF3E8877),
                width: 1.6,
              ),
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value:
                  _allCategoriesValue,
              child: Text(
                'All Categories',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...categories.map(
              (CategoryModel category) {
                return DropdownMenuItem<String>(
                  value:
                      category.uuid,
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
