import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/dashboard/widgets/gradient_card.dart';
import 'package:money_tracker_app/features/dashboard/widgets/home_appbar.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/view/transaction_detail_screen.dart';
import 'package:money_tracker_app/shared/widgets/section_heading.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onViewAllTransactions,
    this.onOpenSettings,
  });

  final VoidCallback? onViewAllTransactions;
  final VoidCallback? onOpenSettings;

  static const _recentLimit = 5;

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
        final totals = _calculateTotals(transactions);

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(MSizes.defaultSpace),
            child: Column(
              children: [
                /// Home Appbar
                MHomeAppbar(onOpenSettings: onOpenSettings),
                const SizedBox(height: 20),

                /// Balance Card
                MGradientBalanceCard(
                  totalBalance: totals['balance'] ?? 0,
                  totalIncome: totals['income'] ?? 0,
                  totalExpense: totals['expense'] ?? 0,
                ),
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
                  const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text('No transactions yet'),
                    ),
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
    );
  }

  Map<String, double> _calculateTotals(List<TransactionModel> transactions) {
    double income = 0;
    double expense = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
}
