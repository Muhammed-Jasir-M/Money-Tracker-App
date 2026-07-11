import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';

enum TransactionDateFilter {
  all,
  thisWeek,
  thisMonth,
  customMonth,
  customRange,
}

enum TransactionSortOrder {
  newestFirst,
  oldestFirst,
  amountHigh,
  amountLow,
  categoryAsc,
}

class TransactionFilters {
  const TransactionFilters({
    this.searchQuery = '',
    this.type,
    this.category,
    this.dateFilter = TransactionDateFilter.all,
    this.customMonth,
    this.rangeStart,
    this.rangeEnd,
    this.sortOrder = TransactionSortOrder.newestFirst,
  });

  final String searchQuery;
  final TransactionType? type;
  final CategoryModel? category;
  final TransactionDateFilter dateFilter;
  final DateTime? customMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final TransactionSortOrder sortOrder;

  TransactionFilters copyWith({
    String? searchQuery,
    TransactionType? type,
    bool clearType = false,
    CategoryModel? category,
    bool clearCategory = false,
    TransactionDateFilter? dateFilter,
    DateTime? customMonth,
    bool clearCustomMonth = false,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    bool clearRange = false,
    TransactionSortOrder? sortOrder,
  }) {
    return TransactionFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      type: clearType ? null : (type ?? this.type),
      category: clearCategory ? null : (category ?? this.category),
      dateFilter: dateFilter ?? this.dateFilter,
      customMonth:
          clearCustomMonth ? null : (customMonth ?? this.customMonth),
      rangeStart: clearRange ? null : (rangeStart ?? this.rangeStart),
      rangeEnd: clearRange ? null : (rangeEnd ?? this.rangeEnd),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      type != null ||
      category != null ||
      dateFilter != TransactionDateFilter.all;

  TransactionFilters periodOnly() {
    return TransactionFilters(
      dateFilter: dateFilter,
      customMonth: customMonth,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  List<TransactionModel> apply(List<TransactionModel> transactions) {
    final filtered = transactions.where(_matches).toList();
    return _sort(filtered);
  }

  List<TransactionModel> applyDateOnly(List<TransactionModel> transactions) {
    return transactions.where((t) => _matchesDateFilter(t.dateTime)).toList();
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
    final today = DateTime(now.year, now.month, now.day);

    return switch (dateFilter) {
      TransactionDateFilter.all => true,
      TransactionDateFilter.thisWeek => !dateTime.isBefore(
          today.subtract(Duration(days: today.weekday - DateTime.monday)),
        ),
      TransactionDateFilter.thisMonth =>
        dateTime.year == now.year && dateTime.month == now.month,
      TransactionDateFilter.customMonth => customMonth != null &&
          dateTime.year == customMonth!.year &&
          dateTime.month == customMonth!.month,
      TransactionDateFilter.customRange =>
        rangeStart != null &&
            rangeEnd != null &&
            !_isBeforeDay(dateTime, rangeStart!) &&
            !_isAfterDay(dateTime, rangeEnd!),
    };
  }

  static bool _isBeforeDay(DateTime value, DateTime start) {
    final day = DateTime(value.year, value.month, value.day);
    final startDay = DateTime(start.year, start.month, start.day);
    return day.isBefore(startDay);
  }

  static bool _isAfterDay(DateTime value, DateTime end) {
    final day = DateTime(value.year, value.month, value.day);
    final endDay = DateTime(end.year, end.month, end.day);
    return day.isAfter(endDay);
  }

  List<TransactionModel> _sort(List<TransactionModel> transactions) {
    final sorted = List<TransactionModel>.from(transactions);
    switch (sortOrder) {
      case TransactionSortOrder.newestFirst:
        sorted.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      case TransactionSortOrder.oldestFirst:
        sorted.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      case TransactionSortOrder.amountHigh:
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
      case TransactionSortOrder.amountLow:
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
      case TransactionSortOrder.categoryAsc:
        sorted.sort((a, b) {
          final byCategory =
              a.category.title.toLowerCase().compareTo(b.category.title.toLowerCase());
          if (byCategory != 0) return byCategory;
          return b.dateTime.compareTo(a.dateTime);
        });
    }
    return sorted;
  }
}
