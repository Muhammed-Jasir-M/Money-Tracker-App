import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';

class MSectionHeading extends StatelessWidget {
  const MSectionHeading({
    super.key,
    this.onPressed,
    this.textColor,
    this.buttontitle = 'View all',
    required this.title,
    this.showActionbutton = true,
  });

  final Color? textColor;
  final bool showActionbutton;
  final String title, buttontitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final darkMode = MHelperFunctions.isDarkMode(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Heading Text
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Button
        if (showActionbutton)
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: darkMode ? MColors.white : MColors.outline,
              textStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            child: Text(buttontitle),
          ),
      ],
    );
  }
}
