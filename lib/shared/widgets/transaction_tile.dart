import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/currency/currency_scope.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/core/utils/money_format.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
class MTransactionTile extends StatelessWidget {
  const MTransactionTile({
    super.key,
    this.iconBgColor = Colors.yellow,
    this.iconColor = Colors.white,
    required this.icon,
    required this.title,
    this.amount = 0.0,
    this.time = '',
    this.note = '',
    this.noteMaxLines = 1,
    this.showPriceDate = true,
    this.bgColor,
    this.useCategoryTint = true,
    this.type,
    this.onTap,
    this.trailing,
  });

  final Color iconBgColor, iconColor;
  final IconData icon;
  final String title, time, note;
  final int? noteMaxLines;
  final double amount;
  final bool showPriceDate;
  final Color? bgColor;
  final bool useCategoryTint;
  final TransactionType? type;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final symbol = CurrencyScope.of(context);
    final tileBg = bgColor ?? (isDark ? MColors.cardDark : MColors.cardLight);
    final subtitleColor =
        isDark ? const Color(0xFF9E9E9E) : MColors.darkerGrey;
    final borderColor = isDark
        ? MColors.outline.withValues(alpha: 0.22)
        : MColors.outline.withValues(alpha: 0.45);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: tileBg,
                  border: Border.all(color: borderColor),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (useCategoryTint)
                        Container(
                          width: 4,
                          color: iconBgColor,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        Icon(icon, color: iconColor),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (note.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              note,
                                              maxLines: noteMaxLines,
                                              overflow: noteMaxLines == null
                                                  ? TextOverflow.visible
                                                  : TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: subtitleColor,
                                                fontWeight: FontWeight.w500,
                                                height: 1.35,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (showPriceDate)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      MoneyFormat.signed(
                                        amount,
                                        symbol,
                                        isIncome:
                                            type == TransactionType.income,
                                      ),
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
                                        fontSize: 12,
                                        color: subtitleColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              else if (trailing != null)
                                trailing!,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
