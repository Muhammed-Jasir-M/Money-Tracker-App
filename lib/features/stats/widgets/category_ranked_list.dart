import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/currency/currency_scope.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/money_format.dart';
import 'package:money_tracker_app/features/stats/utils/stats_helpers.dart';

class CategoryRankedList extends StatelessWidget {
  const CategoryRankedList({
    super.key,
    required this.items,
    this.onItemTap,
  });

  final List<CategoryBreakdownItem> items;
  final ValueChanged<CategoryBreakdownItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyScope.of(context);

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: MSizes.xs),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(item.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: MSizes.sm),
              Expanded(
                child: onItemTap == null
                    ? Text(
                        item.title,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                        overflow: TextOverflow.ellipsis,
                      )
                    : InkWell(
                        onTap: () => onItemTap!(item),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            item.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: MSizes.sm),
              Text(
                MoneyFormat.amount(item.amount, symbol, decimals: 0),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: MSizes.sm),
              SizedBox(
                width: 42,
                child: Text(
                  '${item.percentage.toStringAsFixed(0)}%',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
