import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/categories/view/add_category_screen.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCategoryScreen(),
            ),
          );
          if (context.mounted) {
            context.read<CategoryBloc>().add(LoadCategories());
          }
        },
        child: const Icon(FontAwesomeIcons.plus),
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            MHelperFunctions.showSnackBar(
              message: state.message,
              context: context,
              title: 'Error',
              bgColor: Colors.red,
              icon: Icons.error,
            );
          } else if (state is CategorySuccess) {
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
            _ => [],
          };

          if (categories.isEmpty) {
            return const Center(child: Text('No categories yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(MSizes.defaultSpace),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return MTransactionTile(
                icon: categoryIcons[category.iconIndex],
                title: category.title,
                showPriceDate: false,
                iconBgColor: Color(category.color),
              );
            },
          );
        },
      ),
    );
  }
}
