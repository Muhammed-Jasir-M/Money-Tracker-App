import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';

class CategoryBreakdownItem {
  const CategoryBreakdownItem({
    required this.title,
    required this.color,
    required this.amount,
    required this.percentage,
  });

  final String title;
  final int color;
  final double amount;
  final double percentage;
}

class MonthlyTrendPoint {
  const MonthlyTrendPoint({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;
}

class StatsHelpers {
  StatsHelpers._();

  static List<TransactionModel> filterByPeriod(
    List<TransactionModel> transactions,
    TransactionDateFilter period,
  ) {
    return TransactionFilters(dateFilter: period).apply(transactions);
  }

  static double sumAmount(List<TransactionModel> transactions) {
    return transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  static List<CategoryBreakdownItem> groupByCategory(
    List<TransactionModel> transactions,
  ) {
    if (transactions.isEmpty) {
      return [];
    }

    final categoryMap = <String, ({double amount, int color})>{};
    for (final transaction in transactions) {
      final title = transaction.category.title;
      final existing = categoryMap[title];
      if (existing == null) {
        categoryMap[title] = (
          amount: transaction.amount,
          color: transaction.category.color,
        );
      } else {
        categoryMap[title] = (
          amount: existing.amount + transaction.amount,
          color: existing.color,
        );
      }
    }

    final total = sumAmount(transactions);
    return categoryMap.entries
        .map(
          (entry) => CategoryBreakdownItem(
            title: entry.key,
            color: entry.value.color,
            amount: entry.value.amount,
            percentage: total > 0 ? (entry.value.amount / total) * 100 : 0,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  static List<MonthlyTrendPoint> groupByMonth(
    List<TransactionModel> transactions,
  ) {
    final incomeByMonth = <String, double>{};
    final expenseByMonth = <String, double>{};

    for (final transaction in transactions) {
      final key =
          '${transaction.dateTime.year}-${transaction.dateTime.month.toString().padLeft(2, '0')}';
      final map = switch (transaction.type) {
        TransactionType.income => incomeByMonth,
        TransactionType.expense => expenseByMonth,
      };
      map.update(
        key,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final months = <String>{
      ...incomeByMonth.keys,
      ...expenseByMonth.keys,
    }.toList()
      ..sort();

    return months.map((month) {
      final parts = month.split('-');
      final year = int.parse(parts[0]);
      final monthNumber = int.parse(parts[1]);
      return MonthlyTrendPoint(
        label: '$monthNumber/$year',
        income: incomeByMonth[month] ?? 0,
        expense: expenseByMonth[month] ?? 0,
      );
    }).toList();
  }
}
