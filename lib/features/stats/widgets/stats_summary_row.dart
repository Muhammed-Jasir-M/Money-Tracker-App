import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';

class StatsSummaryRow extends StatelessWidget {
  const StatsSummaryRow({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
  });

  final double totalIncome;
  final double totalExpense;
  final double net;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Income',
            amount: totalIncome,
            color: Colors.green,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: MSizes.sm),
        Expanded(
          child: _SummaryCard(
            label: 'Expense',
            amount: totalExpense,
            color: Colors.red,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: MSizes.sm),
        Expanded(
          child: _SummaryCard(
            label: 'Net',
            amount: net,
            color: net >= 0 ? Colors.green : Colors.red,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.isDark,
  });

  final String label;
  final double amount;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MSizes.sm,
        vertical: MSizes.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? MColors.dark : MColors.light,
        borderRadius: BorderRadius.circular(MSizes.borderRadiusLg),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: MSizes.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '\u{20B9}${amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
