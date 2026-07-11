import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/category_icons.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/features/transactions/view/widgets/transactions_chart.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/transaction_tile.dart';

class AllTransactionScreen extends StatelessWidget {
  const AllTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: MAppBar(
        title: Text(
          'All Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MSizes.defaultSpace),
          child: BlocConsumer<TransactionBloc, TransactionState>(
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
              } else if (state is TransactionLoaded) {
                return Column(
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
                        child: MBarChart(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Transaction Tile
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = state.transactions[index];
                        return MTransactionTile(
                          icon: categoryIcons[transaction.category.iconIndex],
                          title: transaction.category.title,
                          iconBgColor: Color(transaction.category.color),
                          amount: transaction.amount,
                          time: transaction.time.toString(),
                        );
                      },
                    ),
                  ],
                );
              } else {
                return Center(
                  child: Text('No Transactions Found'),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
