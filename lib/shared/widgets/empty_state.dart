import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';

class MEmptyState extends StatelessWidget {
  const MEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final isTight = hasBoundedHeight && constraints.maxHeight < 180;
        final useCompact = compact || isTight;
        final iconBox = useCompact ? 52.0 : 72.0;
        final iconSize = useCompact ? 26.0 : 36.0;
        final padding = useCompact ? MSizes.md : MSizes.lg;

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              decoration: BoxDecoration(
                color: MColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: MColors.primary),
            ),
            SizedBox(height: useCompact ? MSizes.sm : MSizes.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: (useCompact
                      ? Theme.of(context).textTheme.titleSmall
                      : Theme.of(context).textTheme.titleMedium)
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: useCompact ? MSizes.xs : MSizes.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                maxLines: useCompact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.75),
                      height: 1.3,
                    ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: useCompact ? MSizes.md : MSizes.lg),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: MColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: useCompact ? MSizes.md : MSizes.lg,
                    vertical: useCompact ? MSizes.sm : MSizes.md,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        );

        if (!hasBoundedHeight) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: padding,
            ),
            child: Center(child: content),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: Center(child: content),
          ),
        );
      },
    );
  }
}
