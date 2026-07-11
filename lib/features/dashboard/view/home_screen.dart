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
import 'package:money_tracker_app/features/transactions/view/all_transactions_screen.dart';
import 'package:money_tracker_app/shared/widgets/section_heading.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionError) {
          MHelperFunctions.showSnackBar(
            message: state.message,
            context: context,
            title: "Error",
            bgColor: Colors.red,
            icon: Icons.error,
          );
        } else if (state is TransactionSuccess) {
          MHelperFunctions.showSnackBar(
            message: state.message,
            context: context,
            title: "Success",
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

        final totals = _calculateTotals(transactions);

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(MSizes.defaultSpace),
            child: Column(
              children: [
                // Appbar
                MHomeAppbar(),
                const SizedBox(height: 20),

                // Gradient Balance Card
                MGradientBalanceCard(
                  totalBalance: totals['balance'] ?? 0,
                  totalIncome: totals['income'] ?? 0,
                  totalExpense: totals['expense'] ?? 0,
                ),

                const SizedBox(height: 20),

                // Section Heading
                MSectionHeading(
                  title: 'Transactions',
                  showActionbutton: true,
                  onPressed: () {
                    MHelperFunctions.navigateToScreen(
                      context,
                      AllTransactionScreen(),
                    );
                  },
                ),

                const SizedBox(height: MSizes.sm),

                // Transaction Tile
                if (transactions.isEmpty)
                  const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text('No transactions availablel'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              MHelperFunctions.formatDateHeader(
                                  transaction.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          MTransactionTile(
                            icon:
                                categoryIcons[transaction.category.iconIndex],
                            title: transaction.category.title,
                            iconBgColor: Color(transaction.category.color),
                            amount: transaction.amount,
                            time: transaction.time.toString(),
                            type: transaction.type,
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

  dynamic _calculateTotals(List<TransactionModel> transactions) {
    double income = 0;
    double expense = 0;

    for (var transaction in transactions) {
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
