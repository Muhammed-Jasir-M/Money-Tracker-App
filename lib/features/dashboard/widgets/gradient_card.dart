import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/currency/currency_scope.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/core/utils/money_format.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/features/stats/utils/stats_helpers.dart';
import 'package:money_tracker_app/features/transactions/utils/transaction_filters.dart';
import 'package:money_tracker_app/shared/widgets/price_info_tile.dart';

enum BalanceCardPeriod { allTime, thisMonth }

class MGradientBalanceCard extends StatefulWidget {
  const MGradientBalanceCard({
    super.key,
    required this.transactions,
  });

  final List<TransactionModel> transactions;

  @override
  State<MGradientBalanceCard> createState() => _MGradientBalanceCardState();
}

class _MGradientBalanceCardState extends State<MGradientBalanceCard> {
  BalanceCardPeriod _period = BalanceCardPeriod.allTime;

  static const _thisMonthFilters = TransactionFilters(
    dateFilter: TransactionDateFilter.thisMonth,
  );

  List<TransactionModel> get _filteredTransactions {
    if (_period == BalanceCardPeriod.allTime) {
      return widget.transactions;
    }
    return StatsHelpers.filterByPeriod(
      widget.transactions,
      _thisMonthFilters,
    );
  }

  ({double income, double expense, double balance}) get _totals {
    double income = 0;
    double expense = 0;

    for (final transaction in _filteredTransactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return (income: income, expense: expense, balance: income - expense);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final symbol = CurrencyScope.of(context);
    final totals = _totals;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      width: MHelperFunctions.screenWidth(context),
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
        children: [
          _BalancePeriodToggle(
            period: _period,
            onChanged: (period) => setState(() => _period = period),
          ),
          const SizedBox(height: MSizes.md),
          const Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            MoneyFormat.amount(totals.balance, symbol, withSpace: true),
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MPriceInfoTextWithIcon(
                  title: 'Income',
                  amount: MoneyFormat.amount(
                    totals.income,
                    symbol,
                    withSpace: true,
                  ),
                ),
                MPriceInfoTextWithIcon(
                  title: 'Expenses',
                  amount: MoneyFormat.amount(
                    totals.expense,
                    symbol,
                    withSpace: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalancePeriodToggle extends StatelessWidget {
  const _BalancePeriodToggle({
    required this.period,
    required this.onChanged,
  });

  final BalanceCardPeriod period;
  final ValueChanged<BalanceCardPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'All time',
            selected: period == BalanceCardPeriod.allTime,
            onTap: () => onChanged(BalanceCardPeriod.allTime),
          ),
          _ToggleChip(
            label: 'This month',
            selected: period == BalanceCardPeriod.thisMonth,
            onTap: () => onChanged(BalanceCardPeriod.thisMonth),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(alpha: 0.95)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected
                  ? MColors.primary
                  : Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ),
    );
  }
}
