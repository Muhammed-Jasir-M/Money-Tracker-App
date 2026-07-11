import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/budgets/widgets/budget_progress_loader.dart';
import 'package:money_tracker_app/features/dashboard/widgets/gradient_card.dart';
import 'package:money_tracker_app/features/dashboard/widgets/home_appbar.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/view/transaction_detail_screen.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/empty_state.dart';
import 'package:money_tracker_app/shared/widgets/section_heading.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onViewAllTransactions,
    this.onOpenCategories,
    this.onOpenBudgets,
  });

  final VoidCallback? onViewAllTransactions;
  final VoidCallback? onOpenCategories;
  final VoidCallback? onOpenBudgets;

  static const _recentLimit = 5;

  @override
  Widget build(BuildContext context) {
    final appBarActions = [
      if (onOpenBudgets != null)
        IconButton(
          onPressed: onOpenBudgets,
          tooltip: 'Manage budgets',
          icon: const Icon(Icons.account_balance_wallet_outlined),
        ),
      if (onOpenCategories != null)
        IconButton(
          onPressed: onOpenCategories,
          tooltip: 'Manage categories',
          icon: const Icon(Icons.category_outlined),
        ),
    ];

    return Scaffold(
      appBar: tabScreenAppBar(
        context,
        title: 'Home',
        actions: appBarActions.isEmpty ? null : appBarActions,
      ),
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
        } else if (state is TransactionSuccess) {
          MHelperFunctions.showSnackBar(
            message: state.message,
            context: context,
            title: 'Success',
            bgColor: Colors.green,
            icon: Icons.check_circle,
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

        final sorted = List<TransactionModel>.from(transactions)
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
        final recent = sorted.take(_recentLimit).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              MSizes.defaultSpace,
              MSizes.sm,
              MSizes.defaultSpace,
              MSizes.defaultSpace,
            ),
            child: Column(
              children: [
                const MHomeAppbar(),
                const SizedBox(height: 20),

                /// Balance Card
                MGradientBalanceCard(transactions: transactions),
                const SizedBox(height: 20),

                const BudgetProgressLoader(compact: true),
                const SizedBox(height: 20),

                /// Recent Transactions Heading
                MSectionHeading(
                  title: 'Recent Transactions',
                  showActionbutton: transactions.isNotEmpty,
                  onPressed: onViewAllTransactions,
                ),
                const SizedBox(height: MSizes.sm),

                /// Recent Transactions List  
                if (recent.isEmpty)
                  const MEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    subtitle: 'Tap + to add your first income or expense',
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent.length,
                    itemBuilder: (context, index) {
                      final transaction = recent[index];
                      final showHeader = index == 0 ||
                          !MHelperFunctions.isSameDay(
                            transaction.dateTime,
                            recent[index - 1].dateTime,
                          );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                MHelperFunctions.formatDateHeader(
                                  transaction.dateTime,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                            ),
                          MTransactionTile(
                            icon: categoryIcons[
                                transaction.category.iconIndex],
                            title: transaction.category.title,
                            note: transaction.note,
                            iconBgColor: Color(transaction.category.color),
                            amount: transaction.amount,
                            time: MHelperFunctions.formatTime(
                              transaction.dateTime,
                            ),
                            type: transaction.type,
                            onTap: () {
                              MHelperFunctions.navigateToScreen(
                                context,
                                TransactionDetailScreen(
                                  transaction: transaction,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    ),
    );
  }
}
