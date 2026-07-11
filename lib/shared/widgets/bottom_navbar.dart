import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';

class MBottomNavbar extends StatelessWidget {
  const MBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onIndexChange,
  });

  final int currentIndex;
  final void Function(int) onIndexChange;

  static const _fabGap = 52.0;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? MColors.cardDark : MColors.cardLight,
          border: isDark
              ? null
              : Border(
                  top: BorderSide(
                    color: MColors.outline.withValues(alpha: 0.35),
                  ),
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              index: 0,
              currentIndex: currentIndex,
              icon: CupertinoIcons.home,
              label: 'Home',
              onTap: onIndexChange,
            ),
            _NavItem(
              index: 1,
              currentIndex: currentIndex,
              icon: CupertinoIcons.list_bullet,
              label: 'Transactions',
              onTap: onIndexChange,
            ),
            const SizedBox(width: _fabGap),
            _NavItem(
              index: 2,
              currentIndex: currentIndex,
              icon: CupertinoIcons.graph_square_fill,
              label: 'Stats',
              onTap: onIndexChange,
            ),
            _NavItem(
              index: 3,
              currentIndex: currentIndex,
              icon: CupertinoIcons.settings,
              label: 'Settings',
              onTap: onIndexChange,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final selected = currentIndex == index;
    final isDark = MHelperFunctions.isDarkMode(context);
    final inactiveColor =
        isDark ? const Color(0xFF9E9E9E) : MColors.darkerGrey;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 28,
                alignment: Alignment.center,
                decoration: selected
                    ? BoxDecoration(
                        color: MColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Icon(
                  icon,
                  size: 22,
                  color: selected ? MColors.primary : inactiveColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? MColors.primary : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
