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
    this.time = '',
    this.note = '',
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
    final baseBg = bgColor ?? (isDark ? MColors.dark : MColors.light);
    final tileBg = useCategoryTint && bgColor == null
        ? Color.alphaBlend(iconBgColor.withValues(alpha: 0.12), baseBg)
        : baseBg;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(14),
              border: useCategoryTint
                  ? Border(
                      left: BorderSide(color: iconBgColor, width: 4),
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (note.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  note,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: MColors.outline,
                                    fontWeight: FontWeight.w400,
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
                    )
                  else if (trailing != null)
                    trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
