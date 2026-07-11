import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/features/stats/widgets/chart_slider.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/view/transaction_detail_screen.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

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
          if (state is TransactionLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded ||
              state is TransactionSuccess) {
            final transactions = state is TransactionLoaded
                ? state.transactions
                : (state as TransactionSuccess).transactions;

            if (transactions.isEmpty) {
              return const SizedBox(
                height: 50,
                child: Center(
                  child: Text('No transactions availablel'),
                ),
              );
            }

            final expenseTransactions = transactions
                .where((transaction) =>
                    transaction.type == TransactionType.expense)
                .toList();

            if (expenseTransactions.isEmpty) {
              return const SizedBox(
                height: 50,
                child: Center(
                  child: Text('No expense transactions available'),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: MHelperFunctions.screenWidth(context),
                    height: MHelperFunctions.screenWidth(context),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDark ? MColors.dark : MColors.light,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                      child: ChartSlider(
                        transactions: expenseTransactions,
                        type: TransactionType.expense,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Transaction Tile
                  Padding(
                    padding: const EdgeInsets.only(bottom: MSizes.sm),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: expenseTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = expenseTransactions[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                MHelperFunctions.formatDateHeader(
                                    transaction.dateTime),
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
                              time: MHelperFunctions.formatTime(
                                  transaction.dateTime),
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
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text('No Transactions Found'),
            );
          }
        },
      );
  }
}
