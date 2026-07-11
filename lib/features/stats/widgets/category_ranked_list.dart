import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/features/stats/utils/stats_helpers.dart';

class CategoryRankedList extends StatelessWidget {
  const CategoryRankedList({
    super.key,
    required this.items,
  });

  final List<CategoryBreakdownItem> items;

  @override
  Widget build(BuildContext context) {
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
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: MSizes.sm),
              Text(
                '\u{20B9}${item.amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
