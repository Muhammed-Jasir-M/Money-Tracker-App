import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/stats/utils/stats_helpers.dart';
import 'package:money_tracker_app/features/stats/widgets/category_breakdown_section.dart';
import 'package:money_tracker_app/features/stats/widgets/stats_period_chips.dart';
import 'package:money_tracker_app/features/stats/widgets/stats_summary_row.dart';
import 'package:money_tracker_app/features/stats/widgets/stats_trend_chart.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({
    super.key,
    this.onOpenTransactions,
  });

  final void Function(TransactionFilters filters)? onOpenTransactions;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  TransactionDateFilter _period = TransactionDateFilter.thisMonth;

  void _openCategoryTransactions(
    CategoryBreakdownItem item,
    TransactionType type,
  ) {
    widget.onOpenTransactions?.call(
      TransactionFilters(
        type: type,
        category: item.category,
        dateFilter: _period,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionError) {
          MHelperFunctions.showSnackBar(
            message: state.message,
            context: context,
            title: 'Error',
            bgColor: Colors.red,
            icon: Icons.error,
          );
        }
      },
      builder: (context, state) {
        if (state is TransactionLoading || state is TransactionInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = switch (state) {
          TransactionLoaded(:final transactions) => transactions,
          TransactionSuccess(:final transactions) => transactions,
          _ => <TransactionModel>[],
        };

        final periodTransactions =
            StatsHelpers.filterByPeriod(transactions, _period);
        final incomeTransactions = periodTransactions
            .where((t) => t.type == TransactionType.income)
            .toList();
        final expenseTransactions = periodTransactions
            .where((t) => t.type == TransactionType.expense)
            .toList();

        final totalIncome = StatsHelpers.sumAmount(incomeTransactions);
        final totalExpense = StatsHelpers.sumAmount(expenseTransactions);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            MSizes.defaultSpace,
            MSizes.defaultSpace,
            MSizes.defaultSpace,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stats',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: MSizes.md),
              StatsPeriodChips(
                period: _period,
                onChanged: (period) => setState(() => _period = period),
              ),
              const SizedBox(height: MSizes.md),
              StatsSummaryRow(
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                net: totalIncome - totalExpense,
              ),
              const SizedBox(height: MSizes.spaceBtwSections),
              CategoryBreakdownSection(
                title: 'Expense by category',
                transactions: expenseTransactions,
                accentColor: Colors.red,
                emptyMessage: 'Add an expense to see breakdown',
                onCategoryTap: widget.onOpenTransactions == null
                    ? null
                    : (item) => _openCategoryTransactions(
                          item,
                          TransactionType.expense,
                        ),
              ),
              const SizedBox(height: MSizes.spaceBtwSections),
              CategoryBreakdownSection(
                title: 'Income by category',
                transactions: incomeTransactions,
                accentColor: Colors.green,
                emptyMessage: 'Add income to see breakdown',
                onCategoryTap: widget.onOpenTransactions == null
                    ? null
                    : (item) => _openCategoryTransactions(
                          item,
                          TransactionType.income,
                        ),
              ),
              const SizedBox(height: MSizes.spaceBtwSections),
              StatsTrendChart(
                transactions: periodTransactions,
                period: _period,
              ),
            ],
          ),
        );
      },
    );
  }
}
