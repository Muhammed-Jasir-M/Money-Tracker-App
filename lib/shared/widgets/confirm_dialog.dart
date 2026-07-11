import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';

class MConfirmDialog extends StatelessWidget {
  const MConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelLabel = 'Cancel',
    required this.confirmLabel,
    this.isDestructive = false,
    this.icon,
    this.showCancel = true,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final bool isDestructive;
  final IconData? icon;
  final bool showCancel;

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String cancelLabel = 'Cancel',
    required String confirmLabel,
    bool isDestructive = false,
    IconData? icon,
    bool showCancel = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MConfirmDialog(
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
        icon: icon,
        showCancel: showCancel,
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final accent = isDestructive ? Colors.red : MColors.primary;
    final dialogIcon = icon ??
        (isDestructive ? Icons.delete_outline_rounded : Icons.info_outline_rounded);

    return Dialog(
      backgroundColor: isDark ? MColors.cardDark : MColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MSizes.borderRadiusLg),
        side: isDark
            ? BorderSide.none
            : BorderSide(color: MColors.outline.withValues(alpha: 0.35)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: MSizes.lg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(MSizes.lg, MSizes.lg, MSizes.lg, MSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(dialogIcon, color: accent, size: 24),
            ),
            const SizedBox(height: MSizes.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: MSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: MSizes.lg),
            if (showCancel)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: MSizes.md),
                        side: BorderSide(
                          color: isDark
                              ? MColors.outline
                              : MColors.outline.withValues(alpha: 0.6),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(MSizes.buttonRadius),
                        ),
                      ),
                      child: Text(cancelLabel),
                    ),
                  ),
                  const SizedBox(width: MSizes.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: MSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(MSizes.buttonRadius),
                        ),
                      ),
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: MSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MSizes.buttonRadius),
                    ),
                  ),
                  child: Text(confirmLabel),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
