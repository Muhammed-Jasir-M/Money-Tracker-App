import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';

class MTextFormField extends StatelessWidget {
  const MTextFormField({
    super.key,
    this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.onIconPressed,
    this.isOpened = false,
    this.fillColor,
    this.isDense = false,
    this.suffixWidget,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final bool readOnly, isOpened, isDense;
  final VoidCallback? onTap;
  final VoidCallback? onIconPressed;
  final ValueChanged<String>? onChanged;
  final Widget? suffixWidget;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      controller: controller,
      keyboardType: keyboardType,
      textAlignVertical: TextAlignVertical.center,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        isDense: isDense,
        prefixIcon: Icon(prefixIcon, size: 16, color: Colors.grey),
        suffixIcon: suffixWidget ??
            (suffixIcon != null
                ? IconButton(
                    onPressed: onIconPressed,
                    icon: Icon(suffixIcon, size: 16, color: Colors.grey),
                  )
                : null),
        border: OutlineInputBorder(
          borderRadius: isOpened
              ? BorderRadius.vertical(top: Radius.circular(15))
              : BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: fillColor ?? (isDark ? MColors.dark : MColors.light),
      ),
    );
  }
}
