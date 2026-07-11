import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/features/categories/view/add_category_screen.dart';
import 'package:money_tracker_app/features/transactions/view/widgets/category_grid.dart';

Future<Object?> showCategoryPickerSheet({
  required BuildContext context,
  required List<CategoryModel> categories,
  CategoryModel? selectedCategory,
  TransactionType? filterType,
  bool allowAllOption = false,
  bool showAddButton = true,
  bool showTypeBadge = true,
  String title = 'Select category',
}) {
  final visibleCategories = filterType == null
      ? categories
      : categories.where((category) => category.type == filterType).toList();

  return showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.82;

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                MSizes.defaultSpace,
                MSizes.md,
                MSizes.defaultSpace,
                MSizes.defaultSpace,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: Theme.of(sheetContext)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (showTypeBadge && filterType != null) ...[
                            const SizedBox(width: MSizes.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (filterType == TransactionType.income
                                        ? Colors.green
                                        : Colors.red)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                filterType == TransactionType.income
                                    ? 'Income'
                                    : 'Expense',
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color:
                                          filterType == TransactionType.income
                                              ? Colors.green
                                              : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: MSizes.md),
                if (allowAllOption) ...[
                  CategoryAllOptionTile(
                    selected: selectedCategory == null,
                    onTap: () => Navigator.pop(sheetContext, 'all'),
                  ),
                  const SizedBox(height: MSizes.sm),
                ],
                if (visibleCategories.isEmpty && !allowAllOption)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: MSizes.lg),
                    child: Center(
                      child: Text(
                        filterType == null
                            ? 'No categories yet'
                            : 'No ${filterType.name} categories yet',
                        style: Theme.of(sheetContext).textTheme.bodyLarge,
                      ),
                    ),
                  )
                else
                  CategoryGrid(
                    categories: visibleCategories,
                    selectedCategory: selectedCategory,
                    embedded: true,
                    onCategorySelected: (category) {
                      Navigator.pop(sheetContext, category);
                    },
                  ),
                if (showAddButton) ...[
                  const SizedBox(height: MSizes.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCategoryScreen(
                              initialType: filterType,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add category'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
