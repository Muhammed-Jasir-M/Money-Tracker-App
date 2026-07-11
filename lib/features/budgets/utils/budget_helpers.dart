import 'package:money_tracker_app/data/models/budget/budget_model.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/stats/utils/stats_helpers.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';

class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.title,
    required this.spent,
    required this.limit,
    required this.percent,
    required this.remaining,
    this.iconIndex,
    this.color,
  });

  final BudgetModel budget;
  final String title;
  final double spent;
  final double limit;
  final double percent;
  final double remaining;
  final int? iconIndex;
  final int? color;

  bool get isOverBudget => spent > limit;

  bool get isNearLimit => !isOverBudget && percent >= 80;

  String get statusLabel {
    if (isOverBudget) {
      return 'Over by ${(spent - limit).toStringAsFixed(0)}';
    }
    if (isNearLimit) {
      return '${percent.toStringAsFixed(0)}% used';
    }
    return '${remaining.toStringAsFixed(0)} left';
  }
}

class BudgetHelpers {
  BudgetHelpers._();

  static const monthlyFilters = TransactionFilters(
    dateFilter: TransactionDateFilter.thisMonth,
  );

  static List<BudgetProgress> computeProgress({
    required List<BudgetModel> budgets,
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    TransactionFilters periodFilters = monthlyFilters,
  }) {
    if (budgets.isEmpty) return [];

    final periodExpenses = StatsHelpers.filterByPeriod(transactions, periodFilters)
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final categoryMap = {
      for (final category in categories) category.cId: category,
    };

    final progressList = <BudgetProgress>[];

    for (final budget in budgets) {
      final limit = budget.amountLimit;
      if (limit <= 0) continue;

      final spent = budget.categoryId == null
          ? StatsHelpers.sumAmount(periodExpenses)
          : StatsHelpers.sumAmount(
              periodExpenses
                  .where((t) => t.category.cId == budget.categoryId)
                  .toList(),
            );

      final percent = limit <= 0 ? 0.0 : (spent / limit * 100).clamp(0, 999);
      final remaining = limit - spent;

      String title;
      int? iconIndex;
      int? color;

      if (budget.categoryId == null) {
        title = 'Total expenses';
      } else {
        final category = categoryMap[budget.categoryId];
        if (category == null) {
          title = 'Deleted category';
        } else {
          title = category.title;
          iconIndex = category.iconIndex;
          color = category.color;
        }
      }

      progressList.add(
        BudgetProgress(
          budget: budget,
          title: title,
          spent: spent,
          limit: limit,
          percent: percent.toDouble(),
          remaining: remaining,
          iconIndex: iconIndex,
          color: color,
        ),
      );
    }

    progressList.sort((a, b) {
      if (a.budget.categoryId == null) return -1;
      if (b.budget.categoryId == null) return 1;
      return b.percent.compareTo(a.percent);
    });

    return progressList;
  }

  static List<BudgetProgress> alertsFrom(List<BudgetProgress> progress) {
    return progress.where((item) => item.isNearLimit || item.isOverBudget).toList();
  }
}
