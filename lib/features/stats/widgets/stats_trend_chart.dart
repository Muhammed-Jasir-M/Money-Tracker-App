import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/currency/currency_scope.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/core/utils/money_format.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/stats/utils/stats_helpers.dart';
import 'package:money_tracker_app/features/transactions/utils/date_filter_pickers.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';

class StatsTrendChart extends StatelessWidget {
  const StatsTrendChart({
    super.key,
    required this.transactions,
    required this.periodFilters,
  });

  final List<TransactionModel> transactions;
  final TransactionFilters periodFilters;

  static const _chartHeight = 280.0;

  String get _title => switch (periodFilters.dateFilter) {
        TransactionDateFilter.all => 'Monthly trend',
        TransactionDateFilter.thisMonth => 'Daily trend this month',
        TransactionDateFilter.thisWeek => 'Daily trend this week',
        TransactionDateFilter.customMonth =>
          'Daily trend ${periodFilters.customMonth != null ? DateFilterPickers.monthLabel(periodFilters.customMonth!) : ''}',
        TransactionDateFilter.customRange => 'Trend for selected range',
      };

  String get _emptyMessage => switch (periodFilters.dateFilter) {
        TransactionDateFilter.all =>
          'Add transactions across multiple months to see trend',
        TransactionDateFilter.thisMonth =>
          'Add transactions this month to see daily trend',
        TransactionDateFilter.thisWeek =>
          'Add transactions this week to see daily trend',
        TransactionDateFilter.customMonth =>
          'Add transactions in this month to see trend',
        TransactionDateFilter.customRange =>
          'Add transactions in this range to see trend',
      };

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final symbol = CurrencyScope.of(context);
    final points = StatsHelpers.groupTrend(transactions, periodFilters);
    final hasData = points.isNotEmpty;

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
          if (hasData) ...[
            const SizedBox(height: MSizes.sm),
            const Row(
              children: [
                _LegendDot(color: Colors.green, label: 'Income'),
                SizedBox(width: MSizes.md),
                _LegendDot(color: Colors.red, label: 'Expense'),
              ],
            ),
          ],
          const SizedBox(height: MSizes.xs),
          Expanded(
            child: hasData
                ? _TrendLineChart(
                    points: points,
                    symbol: symbol,
                    isDark: isDark,
                  )
                : _TrendEmptyState(message: _emptyMessage),
          ),
        ],
      ),
    );
  }
}

class _TrendEmptyState extends StatelessWidget {
  const _TrendEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_outlined,
            size: 48,
            color: MColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: MSizes.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MSizes.md),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendLineChart extends StatelessWidget {
  const _TrendLineChart({
    required this.points,
    required this.symbol,
    required this.isDark,
  });

  final List<TrendPoint> points;
  final String symbol;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final maxY = _niceMaxY(points);
    final yInterval = _yInterval(maxY);
    final labelStep = _xLabelStep(points.length);
    final mutedLabelColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.grey.shade600;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt().clamp(0, points.length - 1);
                final point = points[index];
                final label = spot.barIndex == 0 ? 'Income' : 'Expense';
                final value =
                    spot.barIndex == 0 ? point.income : point.expense;
                return LineTooltipItem(
                  '${point.label}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '$label: ${MoneyFormat.amount(value, symbol, decimals: 0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: isDark ? 0.18 : 0.22),
            strokeWidth: 1,
          ),
        ),
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
                if (!_shouldShowXLabel(index, points.length, labelStep)) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    points[index].label,
                    style: TextStyle(
                      fontSize: 10,
                      color: mutedLabelColor,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > maxY + 0.01) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    MHelperFunctions.formatCurrency(value, symbol),
                    style: TextStyle(
                      fontSize: 10,
                      color: mutedLabelColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(
              color: Colors.grey.withValues(alpha: isDark ? 0.25 : 0.35),
            ),
            bottom: BorderSide(
              color: Colors.grey.withValues(alpha: isDark ? 0.25 : 0.35),
            ),
          ),
        ),
        minX: 0,
        maxX: points.length <= 1 ? 1 : (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: points
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.income))
                .toList(),
            isCurved: points.length > 2,
            color: Colors.green,
            barWidth: 2.5,
            dotData: FlDotData(show: points.length <= 8),
          ),
          LineChartBarData(
            spots: points
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.expense))
                .toList(),
            isCurved: points.length > 2,
            color: Colors.red,
            barWidth: 2.5,
            dotData: FlDotData(show: points.length <= 8),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }

  double _niceMaxY(List<TrendPoint> points) {
    final peak = points.fold<double>(
      0,
      (current, point) {
        final value =
            point.income > point.expense ? point.income : point.expense;
        return value > current ? value : current;
      },
    );
    if (peak <= 0) return 100;

    final target = peak * 1.12;
    return _roundUpNice(target);
  }

  double _roundUpNice(double value) {
    if (value <= 100) return 100;
    if (value <= 500) return ((value / 100).ceil() * 100).toDouble();
    if (value <= 2000) return ((value / 250).ceil() * 250).toDouble();
    if (value <= 10000) return ((value / 1000).ceil() * 1000).toDouble();
    if (value <= 50000) return ((value / 5000).ceil() * 5000).toDouble();
    if (value <= 100000) return ((value / 10000).ceil() * 10000).toDouble();
    return ((value / 25000).ceil() * 25000).toDouble();
  }

  double _yInterval(double maxY) {
    if (maxY <= 100) return 25;
    if (maxY <= 500) return 100;
    if (maxY <= 2000) return 500;
    if (maxY <= 5000) return 1000;
    if (maxY <= 20000) return 5000;
    if (maxY <= 50000) return 10000;
    if (maxY <= 100000) return 20000;
    return maxY / 4;
  }

  int _xLabelStep(int count) {
    if (count <= 6) return 1;
    if (count <= 12) return 2;
    if (count <= 24) return 4;
    return (count / 5).ceil().clamp(2, 8);
  }

  bool _shouldShowXLabel(int index, int total, int step) {
    if (total <= 6) return true;
    if (index == 0 || index == total - 1) return true;
    return index % step == 0;
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
