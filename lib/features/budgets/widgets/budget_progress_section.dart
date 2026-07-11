import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/currency/currency_scope.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/core/utils/money_format.dart';
import 'package:money_tracker_app/features/budgets/utils/budget_helpers.dart';
import 'package:money_tracker_app/features/budgets/view/manage_budgets_screen.dart';
import 'package:money_tracker_app/shared/widgets/section_heading.dart';

class BudgetProgressSection extends StatelessWidget {
  const BudgetProgressSection({
    super.key,
    required this.progress,
    this.compact = false,
    this.showManageAction = true,
  });

  final List<BudgetProgress> progress;
  final bool compact;
  final bool showManageAction;

  @override
  Widget build(BuildContext context) {
    if (progress.isEmpty) return const SizedBox.shrink();

    final alerts = BudgetHelpers.alertsFrom(progress);
    final isDark = MHelperFunctions.isDarkMode(context);
    final symbol = CurrencyScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MSectionHeading(
          title: 'Monthly budgets',
          showActionbutton: showManageAction,
          buttontitle: 'Manage',
          onPressed: showManageAction
              ? () {
                  MHelperFunctions.navigateToScreen(
                    context,
                    const ManageBudgetsScreen(),
                  );
                }
              : null,
        ),
        const SizedBox(height: MSizes.sm),
        if (alerts.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: MSizes.md,
              vertical: MSizes.sm,
            ),
            decoration: BoxDecoration(
              color: (alerts.any((a) => a.isOverBudget)
                      ? Colors.red
                      : Colors.orange)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: alerts.any((a) => a.isOverBudget)
                      ? Colors.red
                      : Colors.orange,
                ),
                const SizedBox(width: MSizes.sm),
                Expanded(
                  child: Text(
                    alerts.any((a) => a.isOverBudget)
                        ? '${alerts.where((a) => a.isOverBudget).length} budget(s) over limit'
                        : '${alerts.length} budget(s) at 80% or more',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: alerts.any((a) => a.isOverBudget)
                              ? Colors.red
                              : Colors.orange,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: MSizes.sm),
        ],
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? MSizes.md : MSizes.defaultSpace),
          decoration: BoxDecoration(
            color: isDark ? MColors.dark : MColors.light,
            borderRadius: BorderRadius.circular(MSizes.borderRadiusLg),
          ),
          child: Column(
            children: [
              for (var i = 0; i < progress.length; i++) ...[
                if (i > 0) SizedBox(height: compact ? MSizes.md : MSizes.lg),
                _BudgetProgressTile(
                  item: progress[i],
                  symbol: symbol,
                  compact: compact,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetProgressTile extends StatelessWidget {
  const _BudgetProgressTile({
    required this.item,
    required this.symbol,
    required this.compact,
  });

  final BudgetProgress item;
  final String symbol;
  final bool compact;

  Color _progressColor(BuildContext context) {
    if (item.isOverBudget) return Colors.red;
    if (item.isNearLimit) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final progressValue =
        (item.percent / 100).clamp(0.0, 1.0).toDouble();
    final barColor = _progressColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (item.iconIndex != null) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Color(item.color ?? 0).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  categoryIcons[item.iconIndex!],
                  size: 14,
                  color: Color(item.color ?? 0),
                ),
              ),
              const SizedBox(width: MSizes.sm),
            ] else ...[
              Icon(
                Icons.pie_chart_outline,
                size: 18,
                color: barColor,
              ),
              const SizedBox(width: MSizes.sm),
            ],
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (item.isOverBudget)
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: Colors.red)
            else if (item.isNearLimit)
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: Colors.orange),
          ],
        ),
        const SizedBox(height: MSizes.xs),
        Row(
          children: [
            Expanded(
              child: Text(
                '${MoneyFormat.amount(item.spent, symbol, decimals: 0)} / ${MoneyFormat.amount(item.limit, symbol, decimals: 0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.75),
                    ),
              ),
            ),
            Text(
              item.statusLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: MSizes.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: compact ? 8 : 10,
            backgroundColor: barColor.withValues(alpha: 0.15),
            color: barColor,
          ),
        ),
      ],
    );
  }
}
