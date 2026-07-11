import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/money_format.dart';
import 'package:money_tracker_app/shared/widgets/confirm_dialog.dart';

class MHelperFunctions {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double screenHeight(BuildContext context) {
    return screenSize(context).height;
  }

  static double screenWidth(BuildContext context) {
    return screenSize(context).width;
  }

  static double getBottomNavigationBarHeight() {
    return kBottomNavigationBarHeight;
  }

  static double getAppBarHeight() {
    return kToolbarHeight;
  }

  static void showAlert(String title, String message, BuildContext context) {
    MConfirmDialog.show(
      context: context,
      title: title,
      message: message,
      confirmLabel: 'OK',
      showCancel: false,
    );
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void showSnackBar({
    required String title,
    required String message,
    required IconData icon,
    required BuildContext context,
    required Color bgColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final isDark = isDarkMode(context);
    final surfaceColor = isDark ? MColors.cardDark : MColors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MSizes.md,
              vertical: MSizes.sm + 2,
            ),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: bgColor.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: bgColor, size: 22),
                ),
                const SizedBox(width: MSizes.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                      ),
                      if (message.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          message,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: onSurface.withValues(alpha: 0.72),
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
          backgroundColor: Colors.transparent,
          duration: duration,
          action: action,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(
            MSizes.md,
            0,
            MSizes.md,
            MSizes.md,
          ),
          padding: EdgeInsets.zero,
        ),
      );
  }

  static void showSuccessSnackBar(
    BuildContext context, {
    required String title,
    String message = '',
  }) {
    showSnackBar(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      bgColor: const Color(0xFF2E7D32),
    );
  }

  static void showErrorSnackBar(
    BuildContext context, {
    required String title,
    String message = '',
  }) {
    showSnackBar(
      context: context,
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      bgColor: const Color(0xFFC62828),
    );
  }

  static String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return 'Today';
    } else if (inputDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  static String formatCurrency(double amount, [String symbol = '₹']) {
    return MoneyFormat.compact(amount, symbol);
  }

  static String formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
