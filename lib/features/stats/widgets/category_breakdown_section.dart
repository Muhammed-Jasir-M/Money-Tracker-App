import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/stats/utils/stats_helpers.dart';
import 'package:money_tracker_app/features/stats/widgets/category_donut_chart.dart';
import 'package:money_tracker_app/features/stats/widgets/category_ranked_list.dart';

class CategoryBreakdownSection extends StatelessWidget {
  const CategoryBreakdownSection({
    super.key,
    required this.title,
    required this.transactions,
    required this.accentColor,
    required this.emptyMessage,
    this.onCategoryTap,
  });

  final String title;
  final List<TransactionModel> transactions;
  final Color accentColor;
  final String emptyMessage;
  final ValueChanged<CategoryBreakdownItem>? onCategoryTap;

  static const _minCardHeight = 280.0;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final items = StatsHelpers.groupByCategory(transactions);
    final total = StatsHelpers.sumAmount(transactions);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MSizes.md),
      decoration: BoxDecoration(
        color: isDark ? MColors.dark : MColors.light,
        borderRadius: BorderRadius.circular(MSizes.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: MSizes.sm),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: MSizes.md),
          if (items.isEmpty)
            SizedBox(
              height: _minCardHeight - 56,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48,
                      color: accentColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: MSizes.sm),
                    Text(
                      emptyMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            CategoryDonutChart(
              items: items,
              total: total,
              accentColor: accentColor,
              onSliceTap: onCategoryTap,
            ),
            const SizedBox(height: MSizes.md),
            CategoryRankedList(
              items: items,
              onItemTap: onCategoryTap,
            ),
          ],
        ],
      ),
    );
  }
}
