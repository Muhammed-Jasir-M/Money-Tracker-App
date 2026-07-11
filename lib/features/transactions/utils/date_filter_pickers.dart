import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';

class DateFilterPickers {
  DateFilterPickers._();

  static String monthLabel(DateTime month) {
    return DateFormat('MMM yyyy').format(month);
  }

  static String rangeLabel(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Pick range';
    }
    final startText = DateFormat('d MMM yyyy').format(start);
    final endText = DateFormat('d MMM yyyy').format(end);
    return '$startText – $endText';
  }

  static String periodChipLabel(TransactionFilters filters) {
    return switch (filters.dateFilter) {
      TransactionDateFilter.all => 'All time',
      TransactionDateFilter.thisWeek => 'This week',
      TransactionDateFilter.thisMonth => 'This month',
      TransactionDateFilter.customMonth => filters.customMonth == null
          ? 'Custom month'
          : monthLabel(filters.customMonth!),
      TransactionDateFilter.customRange => rangeLabel(
          filters.rangeStart,
          filters.rangeEnd,
        ),
    };
  }

  static Future<TransactionFilters?> pickCustomMonth(
    BuildContext context,
    TransactionFilters current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current.customMonth ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select month',
    );
    if (picked == null) return null;

    return current.copyWith(
      dateFilter: TransactionDateFilter.customMonth,
      customMonth: DateTime(picked.year, picked.month),
      clearRange: true,
    );
  }

  static Future<TransactionFilters?> pickCustomRange(
    BuildContext context,
    TransactionFilters current,
  ) async {
    final start = await showDatePicker(
      context: context,
      initialDate: current.rangeStart ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Start date',
    );
    if (start == null || !context.mounted) return null;

    final end = await showDatePicker(
      context: context,
      initialDate: current.rangeEnd ?? start,
      firstDate: start,
      lastDate: DateTime(2100),
      helpText: 'End date',
    );
    if (end == null) return null;

    return current.copyWith(
      dateFilter: TransactionDateFilter.customRange,
      rangeStart: start,
      rangeEnd: end,
      clearCustomMonth: true,
    );
  }
}
