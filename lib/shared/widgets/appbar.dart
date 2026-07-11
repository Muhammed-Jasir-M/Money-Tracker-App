import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';

class MAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MAppBar({
    super.key,
    this.title,
    this.showBackArrow = false,
    this.centerTitle = true,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.leadingWidget,
    this.titleSpacing = 0,
  });

  final Widget? title;
  final double titleSpacing;
  final bool showBackArrow, centerTitle;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final Widget? leadingWidget;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return AppBar(
      titleSpacing: titleSpacing,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leadingWidth: 48.0,
      leading: showBackArrow
          ? IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_circle_left_outlined,
                color: isDark ? MColors.white : MColors.black,
                size: 30,
              ),
            )
          : leadingIcon != null
              ? IconButton(
                  onPressed: leadingOnPressed,
                  icon: Icon(leadingIcon),
                )
              : leadingWidget,
      title: title,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(MSizes.appBarHeight);
}

PreferredSizeWidget tabScreenAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
}) {
  return MAppBar(
    centerTitle: false,
    titleSpacing: MSizes.defaultSpace,
    title: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    ),
    actions: actions == null
        ? null
        : [
            ...actions,
            const SizedBox(width: MSizes.sm),
          ],
  );
}
