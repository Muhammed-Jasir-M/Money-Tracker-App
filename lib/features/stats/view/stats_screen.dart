import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/stats/utils/stats_helpers.dart';
import 'package:money_tracker_app/features/stats/widgets/category_breakdown_section.dart';
import 'package:money_tracker_app/features/stats/widgets/stats_summary_row.dart';
import 'package:money_tracker_app/features/stats/widgets/stats_trend_chart.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/empty_state.dart';
import 'package:money_tracker_app/shared/widgets/period_filter_section.dart';

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
  TransactionFilters _periodFilters = const TransactionFilters(
    dateFilter: TransactionDateFilter.thisMonth,
  );

  void _openCategoryTransactions(
    CategoryBreakdownItem item,
    TransactionType type,
  ) {
    widget.onOpenTransactions?.call(
      _periodFilters.copyWith(
        type: type,
        category: item.category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: tabScreenAppBar(context, title: 'Stats'),
      body: BlocConsumer<TransactionBloc, TransactionState>(
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
            StatsHelpers.filterByPeriod(transactions, _periodFilters);
        final incomeTransactions = periodTransactions
            .where((t) => t.type == TransactionType.income)
            .toList();
        final expenseTransactions = periodTransactions
            .where((t) => t.type == TransactionType.expense)
            .toList();

        final totalIncome = StatsHelpers.sumAmount(incomeTransactions);
        final totalExpense = StatsHelpers.sumAmount(expenseTransactions);
        final hasTransactions = transactions.isNotEmpty;

        if (!hasTransactions) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(MSizes.defaultSpace),
              child: const MEmptyState(
                icon: Icons.bar_chart_outlined,
                title: 'No stats to show',
                subtitle:
                    'Add transactions to see charts and category breakdowns',
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            MSizes.defaultSpace,
            MSizes.sm,
            MSizes.defaultSpace,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PeriodFilterSection(
                filters: _periodFilters,
                compact: true,
                onChanged: (filters) =>
                    setState(() => _periodFilters = filters.periodOnly()),
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
                periodFilters: _periodFilters,
              ),
            ],
          ),
        );
      },
    ),
    );
  }
}
