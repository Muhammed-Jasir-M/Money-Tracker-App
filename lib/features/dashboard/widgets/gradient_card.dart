import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/currency/currency_scope.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/core/utils/money_format.dart';
import 'package:money_tracker_app/shared/widgets/price_info_tile.dart';

class MGradientBalanceCard extends StatelessWidget {
  const MGradientBalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final symbol = CurrencyScope.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      width: MHelperFunctions.screenWidth(context),
      height: 180,
      decoration: BoxDecoration(
        gradient: MColors.boxGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            MoneyFormat.amount(totalBalance, symbol, withSpace: true),
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MPriceInfoTextWithIcon(
                  title: 'Income',
                  amount: MoneyFormat.amount(totalIncome, symbol, withSpace: true),
                ),
                MPriceInfoTextWithIcon(
                  title: 'Expenses',
                  amount: MoneyFormat.amount(totalExpense, symbol, withSpace: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
