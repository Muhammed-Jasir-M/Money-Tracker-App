import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';

class MTransactionTile extends StatelessWidget {
  const MTransactionTile({
    super.key,
    this.iconBgColor = Colors.yellow,
    this.iconColor = Colors.white,
    required this.icon,
    required this.title,
    this.amount = 0.0,
    this.time = "",
    this.showPriceDate = true,
    this.bgColor,
    this.type,
  });

  final Color iconBgColor, iconColor;
  final IconData icon;
  final String title, time;
  final double amount;
  final bool showPriceDate;
  final Color? bgColor;
  final TransactionType? type;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor ?? (isDark ? MColors.dark : MColors.light),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(icon, color: iconColor)
                    ],
                  ),
                  SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (showPriceDate)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${type == TransactionType.income ? '+' : '-'}${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: MColors.outline,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              if (!showPriceDate) Container()
            ],
          ),
        ),
      ),
    );
  }
}
