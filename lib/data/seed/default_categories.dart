import 'package:money_tracker_app/core/constants/category_colors.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/repositories/category_repository.dart';

class DefaultCategoriesSeeder {
  DefaultCategoriesSeeder._();

  static Future<void> seedIfEmpty({
    required CategoryRepository categoryRepository,
  }) async {
    final existing = await categoryRepository.getAll();
    if (existing.isNotEmpty) {
      return;
    }

    for (final category in _defaults()) {
      await categoryRepository.add(category);
    }
  }

  static List<CategoryModel> _defaults() {
    return [
      CategoryModel(
        cId: 'default_food',
        title: 'Food',
        iconIndex: 0,
        color: categoryColorSwatches[2].toARGB32(),
        type: TransactionType.expense,
      ),
      CategoryModel(
        cId: 'default_travel',
        title: 'Travel',
        iconIndex: 4,
        color: categoryColorSwatches[0].toARGB32(),
        type: TransactionType.expense,
      ),
      CategoryModel(
        cId: 'default_shopping',
        title: 'Shopping',
        iconIndex: 1,
        color: categoryColorSwatches[3].toARGB32(),
        type: TransactionType.expense,
      ),
      CategoryModel(
        cId: 'default_health',
        title: 'Health',
        iconIndex: 6,
        color: categoryColorSwatches[1].toARGB32(),
        type: TransactionType.expense,
      ),
      CategoryModel(
        cId: 'default_bills',
        title: 'Bills',
        iconIndex: 8,
        color: categoryColorSwatches[9].toARGB32(),
        type: TransactionType.expense,
      ),
      CategoryModel(
        cId: 'default_entertainment',
        title: 'Entertainment',
        iconIndex: 3,
        color: categoryColorSwatches[7].toARGB32(),
        type: TransactionType.expense,
      ),
      CategoryModel(
        cId: 'default_salary',
        title: 'Salary',
        iconIndex: 18,
        color: categoryColorSwatches[1].toARGB32(),
        type: TransactionType.income,
      ),
      CategoryModel(
        cId: 'default_freelance',
        title: 'Freelance',
        iconIndex: 20,
        color: categoryColorSwatches[0].toARGB32(),
        type: TransactionType.income,
      ),
      CategoryModel(
        cId: 'default_investment',
        title: 'Investment',
        iconIndex: 17,
        color: categoryColorSwatches[6].toARGB32(),
        type: TransactionType.income,
      ),
    ];
  }
}
