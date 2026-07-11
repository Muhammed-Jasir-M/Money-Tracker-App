import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/budgets/bloc/budget_bloc.dart';
import 'package:money_tracker_app/features/budgets/utils/budget_helpers.dart';
import 'package:money_tracker_app/features/budgets/widgets/budget_progress_section.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';

class BudgetProgressLoader extends StatelessWidget {
  const BudgetProgressLoader({
    super.key,
    this.compact = false,
    this.periodFilters = BudgetHelpers.monthlyFilters,
    this.monthlyViewOnly = false,
  });

  final bool compact;
  final TransactionFilters periodFilters;
  final bool monthlyViewOnly;

  bool _supportsPeriod(TransactionFilters filters) {
    return switch (filters.dateFilter) {
      TransactionDateFilter.thisMonth => true,
      TransactionDateFilter.customMonth => filters.customMonth != null,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (monthlyViewOnly && !_supportsPeriod(periodFilters)) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, budgetState) {
        final budgets = budgetsFromState(budgetState) ?? [];
        if (budgets.isEmpty) return const SizedBox.shrink();

        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, transactionState) {
            final transactions = switch (transactionState) {
              TransactionLoaded(:final transactions) => transactions,
              TransactionSuccess(:final transactions) => transactions,
              _ => <TransactionModel>[],
            };

            final categories = switch (context.watch<CategoryBloc>().state) {
              CategoryLoaded(:final categories) => categories,
              CategorySuccess(:final categories) => categories,
              _ => <CategoryModel>[],
            };

            final progress = BudgetHelpers.computeProgress(
              budgets: budgets,
              transactions: transactions,
              categories: categories,
              periodFilters: periodFilters,
            );

            return BudgetProgressSection(
              progress: progress,
              compact: compact,
            );
          },
        );
      },
    );
  }
}
