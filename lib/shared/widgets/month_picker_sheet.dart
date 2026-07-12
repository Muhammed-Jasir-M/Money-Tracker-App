import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';

Future<DateTime?> showMonthPickerSheet({
  required BuildContext context,
  DateTime? initialMonth,
  int yearsBack = 8,
  int yearsForward = 0,
}) {
  final now = DateTime.now();
  final initial = initialMonth ?? now;

  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _MonthPickerSheet(
        initialMonth: DateTime(initial.year, initial.month),
        minYear: now.year - yearsBack,
        maxYear: now.year + yearsForward,
      );
    },
  );
}

class _MonthPickerSheet extends StatefulWidget {
  const _MonthPickerSheet({
    required this.initialMonth,
    required this.minYear,
    required this.maxYear,
  });

  final DateTime initialMonth;
  final int minYear;
  final int maxYear;

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  late int _year;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialMonth;
    _year = widget.initialMonth.year.clamp(widget.minYear, widget.maxYear);
  }

  bool get _canGoPrev => _year > widget.minYear;
  bool get _canGoNext => _year < widget.maxYear;

  bool _isFutureMonth(int month) {
    final now = DateTime.now();
    if (_year > now.year) return true;
    if (_year < now.year) return false;
    return month > now.month;
  }

  bool _isCurrentMonth(int month) {
    final now = DateTime.now();
    return _year == now.year && month == now.month;
  }

  bool _isSelected(int month) {
    return _selected.year == _year && _selected.month == month;
  }

  void _selectMonth(int month) {
    if (_isFutureMonth(month)) return;
    setState(() {
      _selected = DateTime(_year, month);
    });
  }

  void _confirm() {
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final theme = Theme.of(context);
    final surface = isDark ? MColors.cardDark : MColors.cardLight;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            MSizes.lg,
            MSizes.sm,
            MSizes.lg,
            MSizes.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: MSizes.md),
                decoration: BoxDecoration(
                  color: MColors.outline.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly report',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Select the month to export',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: MSizes.lg),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MSizes.sm,
                  vertical: MSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: isDark ? MColors.bgDark : MColors.bgLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _canGoPrev
                          ? () => setState(() => _year--)
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                      tooltip: 'Previous year',
                    ),
                    Expanded(
                      child: Text(
                        '$_year',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _canGoNext
                          ? () => setState(() => _year++)
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                      tooltip: 'Next year',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MSizes.lg),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: MSizes.sm,
                  crossAxisSpacing: MSizes.sm,
                  childAspectRatio: 2.15,
                ),
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final label = DateFormat.MMM().format(DateTime(_year, month));
                  final selected = _isSelected(month);
                  final current = _isCurrentMonth(month);
                  final disabled = _isFutureMonth(month);

                  return _MonthCell(
                    label: label,
                    selected: selected,
                    isCurrent: current,
                    disabled: disabled,
                    onTap: () => _selectMonth(month),
                  );
                },
              ),
              const SizedBox(height: MSizes.lg),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: MColors.boxGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Use ${DateFormat('MMMM yyyy').format(_selected)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.label,
    required this.selected,
    required this.isCurrent,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isCurrent;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final theme = Theme.of(context);

    Color background;
    Color foreground;
    Border? border;

    if (disabled) {
      background = (isDark ? MColors.bgDark : MColors.bgLight)
          .withValues(alpha: 0.55);
      foreground = theme.disabledColor;
      border = null;
    } else if (selected) {
      background = MColors.primary.withValues(alpha: 0.16);
      foreground = MColors.primary;
      border = Border.all(color: MColors.primary, width: 1.5);
    } else {
      background = isDark ? MColors.bgDark : MColors.bgLight;
      foreground = theme.textTheme.bodyMedium?.color ?? MColors.darkerGrey;
      border = isCurrent
          ? Border.all(
              color: MColors.primary.withValues(alpha: 0.35),
              width: 1,
            )
          : null;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
