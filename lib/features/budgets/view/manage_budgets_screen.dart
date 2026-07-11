import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/currency/currency_scope.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/core/utils/money_format.dart';
import 'package:money_tracker_app/data/models/budget/budget_model.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/budgets/bloc/budget_bloc.dart';
import 'package:money_tracker_app/features/budgets/utils/budget_helpers.dart';
import 'package:money_tracker_app/features/budgets/view/add_budget_screen.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/button.dart';
import 'package:money_tracker_app/shared/widgets/confirm_dialog.dart';
import 'package:money_tracker_app/shared/widgets/empty_state.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class ManageBudgetsScreen extends StatelessWidget {
  const ManageBudgetsScreen({super.key});

  Future<void> _openAdd(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBudgetScreen(),
      ),
    );

    if (context.mounted) {
      context.read<BudgetBloc>().add(LoadBudgets());
    }
  }

  Future<void> _openEdit(BuildContext context, BudgetModel budget) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBudgetScreen(budget: budget),
      ),
    );

    if (context.mounted) {
      context.read<BudgetBloc>().add(LoadBudgets());
    }
  }

  Future<void> _confirmDelete(BuildContext context, BudgetModel budget) async {
    final confirmed = await MConfirmDialog.show(
      context: context,
      title: 'Delete budget?',
      message: 'Remove this monthly spending limit?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    context.read<BudgetBloc>().add(DeleteBudget(budget));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MAppBar(
        showBackArrow: true,
        title: Text(
          'Manage Budgets',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<BudgetBloc, BudgetState>(
              listener: (context, state) {
                if (state is BudgetError) {
                  MHelperFunctions.showSnackBar(
                    message: state.message,
                    context: context,
                    title: 'Error',
                    bgColor: Colors.red,
                    icon: Icons.error,
                  );
                } else if (state is BudgetSuccess &&
                    state.message.contains('deleted')) {
                  MHelperFunctions.showSnackBar(
                    message: state.message,
                    context: context,
                    title: 'Success',
                    bgColor: Colors.green,
                    icon: Icons.check_circle,
                  );
                }
              },
              builder: (context, budgetState) {
                if (budgetState is BudgetLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final budgets = switch (budgetState) {
                  BudgetLoaded(:final budgets) => budgets,
                  BudgetSuccess(:final budgets) => budgets,
                  _ => <BudgetModel>[],
                };

                if (budgets.isEmpty) {
                  return MEmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'No budgets yet',
                    subtitle:
                        'Set monthly limits for total expenses or categories',
                    actionLabel: 'Add budget',
                    onAction: () => _openAdd(context),
                  );
                }

                return BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, transactionState) {
                    final transactions = switch (transactionState) {
                      TransactionLoaded(:final transactions) => transactions,
                      TransactionSuccess(:final transactions) => transactions,
                      _ => <TransactionModel>[],
                    };

                    final categories = switch (
                        context.watch<CategoryBloc>().state) {
                      CategoryLoaded(:final categories) => categories,
                      CategorySuccess(:final categories) => categories,
                      _ => <CategoryModel>[],
                    };

                    final progress = BudgetHelpers.computeProgress(
                      budgets: budgets,
                      transactions: transactions,
                      categories: categories,
                    );

                    final symbol = CurrencyScope.of(context);

                    return ListView.builder(
                      padding: const EdgeInsets.all(MSizes.defaultSpace),
                      itemCount: progress.length,
                      itemBuilder: (context, index) {
                        final item = progress[index];
                        final barColor = item.isOverBudget
                            ? Colors.red
                            : item.isNearLimit
                                ? Colors.orange
                                : Theme.of(context).colorScheme.primary;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: MSizes.md),
                          child: MTransactionTile(
                            icon: item.iconIndex != null
                                ? categoryIcons[item.iconIndex!]
                                : Icons.pie_chart_outline,
                            title: item.title,
                            note:
                                '${MoneyFormat.amount(item.spent, symbol, decimals: 0)} of ${MoneyFormat.amount(item.limit, symbol, decimals: 0)} • ${item.statusLabel}',
                            noteMaxLines: null,
                            showPriceDate: false,
                            iconBgColor: item.color != null
                                ? Color(item.color!)
                                : barColor,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Edit',
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 20),
                                  onPressed: () =>
                                      _openEdit(context, item.budget),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Delete',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, item.budget),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(MSizes.defaultSpace),
              child: MButton(
                btnTitle: 'Add budget',
                width: double.infinity,
                height: 50,
                onTap: () => _openAdd(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
