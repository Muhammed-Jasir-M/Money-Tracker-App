import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/currency/currency_scope.dart';
import 'package:money_tracker_app/core/utils/money_format.dart';
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

  static const _chartHeight = 196.0;
  static const _sectionRadius = 72.0;
  static const _centerSpaceRadius = 48.0;

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyScope.of(context);
    final sections = items.asMap().entries.map((entry) {
      return PieChartSectionData(
        color: Color(entry.value.color),
        value: entry.value.amount,
        radius: _sectionRadius,
        showTitle: false,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: _chartHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxRadius = (constraints.maxHeight / 2) - 6;
            final radius = _sectionRadius.clamp(56.0, maxRadius);

            return Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections
                        .map(
                          (section) => section.copyWith(radius: radius),
                        )
                        .toList(),
                    centerSpaceRadius: _centerSpaceRadius,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                ),
                IgnorePointer(
                  child: SizedBox(
                    width: _centerSpaceRadius * 2 - 4,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            MoneyFormat.amount(total, symbol, decimals: 0),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
