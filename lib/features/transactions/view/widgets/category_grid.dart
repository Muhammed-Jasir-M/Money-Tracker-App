import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.selectedCategory,
    this.maxHeight = 220,
    this.embedded = false,
  });

  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel> onCategorySelected;
  final double maxHeight;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: MSizes.md),
        child: Center(
          child: Text(
            'No categories yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final grid = GridView.builder(
      shrinkWrap: true,
      physics: embedded
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: MSizes.sm,
        crossAxisSpacing: MSizes.sm,
        childAspectRatio: 1.05,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategory?.cId == category.cId;
        final color = Color(category.color);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onCategorySelected(category),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    categoryIcons[category.iconIndex],
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(height: MSizes.xs),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      category.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (embedded) {
      return grid;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: grid,
    );
  }
}

class CategoryAllOptionTile extends StatelessWidget {
  const CategoryAllOptionTile({
    super.key,
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.12)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apps, color: color, size: 18),
              const SizedBox(width: MSizes.sm),
              Text(
                'All categories',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected ? color : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
