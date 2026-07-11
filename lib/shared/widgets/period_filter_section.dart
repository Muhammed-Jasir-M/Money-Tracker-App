import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/features/transactions/utils/date_filter_pickers.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';

class PeriodFilterSection extends StatelessWidget {
  const PeriodFilterSection({
    super.key,
    required this.filters,
    required this.onChanged,
    this.compact = false,
  });

  final TransactionFilters filters;
  final ValueChanged<TransactionFilters> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _PeriodChip(
                label: 'This week',
                selected: filters.dateFilter == TransactionDateFilter.thisWeek,
                onTap: () => onChanged(
                  filters.copyWith(
                    dateFilter: TransactionDateFilter.thisWeek,
                    clearCustomMonth: true,
                    clearRange: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: MSizes.sm),
            Expanded(
              child: _PeriodChip(
                label: 'This month',
                selected: filters.dateFilter == TransactionDateFilter.thisMonth,
                onTap: () => onChanged(
                  filters.copyWith(
                    dateFilter: TransactionDateFilter.thisMonth,
                    clearCustomMonth: true,
                    clearRange: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: MSizes.sm),
            Expanded(
              child: _PeriodChip(
                label: 'All time',
                selected: filters.dateFilter == TransactionDateFilter.all,
                onTap: () => onChanged(
                  filters.copyWith(
                    dateFilter: TransactionDateFilter.all,
                    clearCustomMonth: true,
                    clearRange: true,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: MSizes.sm),
        Row(
          children: [
            Expanded(
              child: _PeriodChip(
                label: filters.dateFilter == TransactionDateFilter.customMonth &&
                        filters.customMonth != null
                    ? DateFilterPickers.monthLabel(filters.customMonth!)
                    : 'Custom month',
                selected:
                    filters.dateFilter == TransactionDateFilter.customMonth,
                onTap: () async {
                  final next =
                      await DateFilterPickers.pickCustomMonth(context, filters);
                  if (next != null) onChanged(next);
                },
              ),
            ),
            const SizedBox(width: MSizes.sm),
            Expanded(
              child: _PeriodChip(
                label: filters.dateFilter == TransactionDateFilter.customRange &&
                        filters.rangeStart != null &&
                        filters.rangeEnd != null
                    ? 'Custom range'
                    : 'Custom range',
                selected:
                    filters.dateFilter == TransactionDateFilter.customRange,
                onTap: () async {
                  final next =
                      await DateFilterPickers.pickCustomRange(context, filters);
                  if (next != null) onChanged(next);
                },
              ),
            ),
          ],
        ),
        if (!compact &&
            filters.dateFilter == TransactionDateFilter.customRange &&
            filters.rangeStart != null &&
            filters.rangeEnd != null) ...[
          const SizedBox(height: MSizes.xs),
          Text(
            DateFilterPickers.rangeLabel(filters.rangeStart, filters.rangeEnd),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
          ),
        ],
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = MHelperFunctions.isDarkMode(context);
    final baseColor = isDark ? MColors.bgDark : MColors.bgLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.15) : baseColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? accent : null,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class SortOrderSection extends StatelessWidget {
  const SortOrderSection({
    super.key,
    required this.sortOrder,
    required this.onChanged,
  });

  final TransactionSortOrder sortOrder;
  final ValueChanged<TransactionSortOrder> onChanged;

  static const _labels = {
    TransactionSortOrder.newestFirst: 'Newest',
    TransactionSortOrder.oldestFirst: 'Oldest',
    TransactionSortOrder.amountHigh: 'Amount ↓',
    TransactionSortOrder.amountLow: 'Amount ↑',
    TransactionSortOrder.categoryAsc: 'Category',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: MSizes.sm,
      runSpacing: MSizes.sm,
      children: TransactionSortOrder.values.map((order) {
        final selected = sortOrder == order;
        final accent = Theme.of(context).colorScheme.primary;
        final isDark = MHelperFunctions.isDarkMode(context);
        final baseColor = isDark ? MColors.bgDark : MColors.bgLight;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(order),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? accent.withValues(alpha: 0.15) : baseColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? accent : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                _labels[order]!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? accent : null,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
