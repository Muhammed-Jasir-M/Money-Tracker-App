import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';

class MButton extends StatelessWidget {
  const MButton({
    super.key,
    required this.onTap,
    required this.btnTitle,
    required this.width,
    this.height = 50,
    this.btnColor = MColors.primary,
    this.textColor,
    this.showBorder = false,
    this.icon,
    this.borderRadius,
    this.iconColor,
  });

  final Function()? onTap;
  final String btnTitle;
  final double width, height;
  final double? borderRadius;
  final Color? btnColor, textColor, iconColor;
  final bool showBorder;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            borderRadius ?? MSizes.buttonRadius,
          ),
          gradient: MColors.floatingButtonGradient,
          border:
              showBorder ? Border.all(color: MColors.primary, width: 2) : null,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: MSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, color: iconColor ?? MColors.black, size: 26),
              if (icon != null) const SizedBox(width: MSizes.md),
              Text(
                btnTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.black,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
