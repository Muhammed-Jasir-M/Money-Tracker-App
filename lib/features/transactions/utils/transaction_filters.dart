import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';

enum TransactionDateFilter { all, thisWeek, thisMonth }

class TransactionFilters {
  const TransactionFilters({
    this.searchQuery = '',
    this.type,
    this.category,
    this.dateFilter = TransactionDateFilter.all,
  });

  final String searchQuery;
  final TransactionType? type;
  final CategoryModel? category;
  final TransactionDateFilter dateFilter;

  TransactionFilters copyWith({
    String? searchQuery,
    TransactionType? type,
    bool clearType = false,
    CategoryModel? category,
    bool clearCategory = false,
    TransactionDateFilter? dateFilter,
  }) {
    return TransactionFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      type: clearType ? null : (type ?? this.type),
      category: clearCategory ? null : (category ?? this.category),
      dateFilter: dateFilter ?? this.dateFilter,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      type != null ||
      category != null ||
      dateFilter != TransactionDateFilter.all;

  List<TransactionModel> apply(List<TransactionModel> transactions) {
    return transactions.where(_matches).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  bool _matches(TransactionModel transaction) {
    if (type != null && transaction.type != type) {
      return false;
    }

    if (category != null && transaction.category.cId != category!.cId) {
      return false;
    }

    if (!_matchesDateFilter(transaction.dateTime)) {
      return false;
    }

    if (searchQuery.isEmpty) {
      return true;
    }

    final query = searchQuery.toLowerCase();
    return transaction.category.title.toLowerCase().contains(query) ||
        transaction.note.toLowerCase().contains(query) ||
        transaction.amount.toString().contains(query);
  }

  bool _matchesDateFilter(DateTime dateTime) {
    final now = DateTime.now();

    return switch (dateFilter) {
      TransactionDateFilter.all => true,
      TransactionDateFilter.thisWeek => !dateTime.isBefore(
          DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1)),
        ),
      TransactionDateFilter.thisMonth =>
        dateTime.year == now.year && dateTime.month == now.month,
    };
  }
}
