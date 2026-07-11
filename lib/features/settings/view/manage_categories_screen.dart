import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/categories/view/add_category_screen.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/button.dart';
import 'package:money_tracker_app/shared/widgets/confirm_dialog.dart';
import 'package:money_tracker_app/shared/widgets/empty_state.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  Future<void> _openAdd(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCategoryScreen(),
      ),
    );

    if (context.mounted) {
      context.read<CategoryBloc>().add(LoadCategories());
    }
  }

  Future<void> _openEdit(BuildContext context, CategoryModel category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryScreen(category: category),
      ),
    );

    if (context.mounted) {
      context.read<CategoryBloc>().add(LoadCategories());
    }
  }

  Future<void> _confirmDelete(BuildContext context, CategoryModel category) async {
    final confirmed = await MConfirmDialog.show(
      context: context,
      title: 'Delete category?',
      message: 'Delete "${category.title}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    context.read<CategoryBloc>().add(DeleteCategory(category));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MAppBar(
        showBackArrow: true,
        title: Text(
          'Manage Categories',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<CategoryBloc, CategoryState>(
              listener: (context, state) {
                if (state is CategoryError) {
                  MHelperFunctions.showSnackBar(
                    message: state.message,
                    context: context,
                    title: 'Error',
                    bgColor: Colors.red,
                    icon: Icons.error,
                  );
                } else if (state is CategorySuccess &&
                    state.message.contains('deleted')) {
                  MHelperFunctions.showSnackBar(
                    message: state.message,
                    context: context,
                    title: 'Success',
                    bgColor: Colors.green,
                    icon: Icons.check_circle,
                  );
                }
              },
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = switch (state) {
                  CategoryLoaded(:final categories) => categories,
                  CategorySuccess(:final categories) => categories,
                  _ => <CategoryModel>[],
                };

                if (categories.isEmpty) {
                  return MEmptyState(
                    icon: Icons.category_outlined,
                    title: 'No categories yet',
                    subtitle: 'Add categories to organize your transactions',
                    actionLabel: 'Add category',
                    onAction: () => _openAdd(context),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(MSizes.defaultSpace),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return MTransactionTile(
                      icon: categoryIcons[category.iconIndex],
                      title: category.title,
                      note: category.type == TransactionType.income
                          ? 'Income'
                          : 'Expense',
                      showPriceDate: false,
                      iconBgColor: Color(category.color),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _openEdit(context, category),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Delete',
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => _confirmDelete(context, category),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(MSizes.defaultSpace),
              child: MButton(
                btnTitle: 'Add category',
                width: double.infinity,
                height: 50,
                onTap: () => _openAdd(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
