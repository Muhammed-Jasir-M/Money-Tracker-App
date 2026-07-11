import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';

class StatsPeriodChips extends StatelessWidget {
  const StatsPeriodChips({
    super.key,
    required this.period,
    required this.onChanged,
  });

  final TransactionDateFilter period;
  final ValueChanged<TransactionDateFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PeriodChip(
            label: 'This week',
            selected: period == TransactionDateFilter.thisWeek,
            onTap: () => onChanged(TransactionDateFilter.thisWeek),
          ),
        ),
        const SizedBox(width: MSizes.sm),
        Expanded(
          child: _PeriodChip(
            label: 'This month',
            selected: period == TransactionDateFilter.thisMonth,
            onTap: () => onChanged(TransactionDateFilter.thisMonth),
          ),
        ),
        const SizedBox(width: MSizes.sm),
        Expanded(
          child: _PeriodChip(
            label: 'All time',
            selected: period == TransactionDateFilter.all,
            onTap: () => onChanged(TransactionDateFilter.all),
          ),
        ),
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
