import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/stats/widgets/bar_chart.dart';
import 'package:money_tracker_app/features/stats/widgets/line_chart.dart';
import 'package:money_tracker_app/features/stats/widgets/pie_chart.dart';

class ChartSlider extends StatefulWidget {
  const ChartSlider({
    super.key,
    required this.transactions,
    required this.type,
  });

  final List<TransactionModel> transactions;
  final TransactionType type;

  @override
  State<ChartSlider> createState() => _ChartSliderState();
}

class _ChartSliderState extends State<ChartSlider> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    final chartColor =
        widget.type == TransactionType.income ? Colors.green : Colors.red;

    return Column(
      children: [
        // Chart title with type
        Text(
          widget.type == TransactionType.income ? 'Income' : 'Expense',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: chartColor,
              ),
        ),
        const SizedBox(height: 8),

        // Total amount
        Text(
          'Total: ${MHelperFunctions.formatCurrency(widget.transactions.fold(0, (sum, item) => sum + item.amount))}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),

        // Page indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? chartColor
                      : Colors.grey.withValues(alpha: 0.5),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Charts with horizontal swipe
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              MBarChart(transactions: widget.transactions, type: widget.type),
              MPieChart(transactions: widget.transactions, type: widget.type),
              MLineChart(transactions: widget.transactions, type: widget.type),
            ],
          ),
        ),

        // Manual navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: chartColor),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              const SizedBox(width: 20),
              Text(
                _getChartName(_currentPage),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: Icon(Icons.chevron_right, color: chartColor),
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getChartName(int index) {
    switch (index) {
      case 0:
        return 'Bar Chart';
      case 1:
        return 'Pie Chart';
      case 2:
        return 'Trend Chart';
      default:
        return '';
    }
  }
}
