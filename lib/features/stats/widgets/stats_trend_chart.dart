import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/stats/utils/stats_helpers.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';

class StatsTrendChart extends StatelessWidget {
  const StatsTrendChart({
    super.key,
    required this.transactions,
    required this.period,
  });

  final List<TransactionModel> transactions;
  final TransactionDateFilter period;

  static const _chartHeight = 280.0;

  String get _title => switch (period) {
        TransactionDateFilter.all => 'Monthly trend',
        TransactionDateFilter.thisMonth => 'Daily trend this month',
        TransactionDateFilter.thisWeek => 'Daily trend this week',
      };

  String get _emptyMessage => switch (period) {
        TransactionDateFilter.all =>
          'Add transactions across multiple months to see trend',
        TransactionDateFilter.thisMonth =>
          'Add transactions this month to see daily trend',
        TransactionDateFilter.thisWeek =>
          'Add transactions this week to see daily trend',
      };

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final points = StatsHelpers.groupTrend(transactions, period);

    return Container(
      width: double.infinity,
      height: _chartHeight,
      padding: const EdgeInsets.fromLTRB(
        MSizes.md,
        MSizes.md,
        MSizes.md,
        MSizes.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? MColors.dark : MColors.light,
        borderRadius: BorderRadius.circular(MSizes.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: MSizes.sm),
          Row(
            children: [
              _LegendDot(color: Colors.green, label: 'Income'),
              const SizedBox(width: MSizes.md),
              _LegendDot(color: Colors.red, label: 'Expense'),
            ],
          ),
          const SizedBox(height: MSizes.xs),
          Expanded(
            child: points.isEmpty
                ? Center(
                    child: Text(
                      _emptyMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final point = points[spot.x.toInt()];
                              final label = spot.barIndex == 0
                                  ? 'Income'
                                  : 'Expense';
                              final value = spot.barIndex == 0
                                  ? point.income
                                  : point.expense;
                              return LineTooltipItem(
                                '$label\n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        '\u{20B9}${value.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) {
                                return const SizedBox.shrink();
                              }
                              if (points.length > 7 &&
                                  index % ((points.length / 4).ceil()) != 0 &&
                                  index != points.length - 1) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  points[index].label,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 24,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                MHelperFunctions.formatCurrency(value),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      minX: 0,
                      maxX: points.length <= 1
                          ? 1
                          : (points.length - 1).toDouble(),
                      minY: 0,
                      maxY: _maxY(points),
                      lineBarsData: [
                        LineChartBarData(
                          spots: points
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.income,
                                ),
                              )
                              .toList(),
                          isCurved: points.length > 2,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: points.length <= 6,
                          ),
                        ),
                        LineChartBarData(
                          spots: points
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.expense,
                                ),
                              )
                              .toList(),
                          isCurved: points.length > 2,
                          color: Colors.red,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: points.length <= 6,
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                  ),
          ),
        ],
      ),
    );
  }

  double _maxY(List<TrendPoint> points) {
    final maxValue = points.fold<double>(
      0,
      (current, point) {
        final peak = point.income > point.expense
            ? point.income
            : point.expense;
        return peak > current ? peak : current;
      },
    );
    return maxValue <= 0 ? 100 : maxValue * 1.2;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
