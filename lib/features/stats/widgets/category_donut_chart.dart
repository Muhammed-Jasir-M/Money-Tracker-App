import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/features/stats/utils/stats_helpers.dart';

class CategoryDonutChart extends StatelessWidget {
  const CategoryDonutChart({
    super.key,
    required this.items,
    required this.total,
    required this.accentColor,
  });

  final List<CategoryBreakdownItem> items;
  final double total;
  final Color accentColor;

  static const _chartHeight = 220.0;
  static const _sectionRadius = 90.0;
  static const _centerSpaceRadius = 52.0;

  @override
  Widget build(BuildContext context) {
    final sections = items.map((item) {
      return PieChartSectionData(
        color: Color(item.color),
        value: item.amount,
        radius: _sectionRadius,
        showTitle: false,
      );
    }).toList();

    return SizedBox(
      height: _chartHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: _centerSpaceRadius,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            ),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '\u{20B9}${total.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
