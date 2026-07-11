import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';

class MTextFormField extends StatelessWidget {
  const MTextFormField({
    super.key,
    this.controller,
    this.label,
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
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.style,
    this.contentPadding,
  });

  final TextEditingController? controller;
  final String? label;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final bool readOnly, isOpened, isDense;
  final VoidCallback? onTap;
  final VoidCallback? onIconPressed;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final Widget? suffixWidget;
  final TextAlign textAlign;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    final field = TextFormField(
      focusNode: focusNode,
      onTap: onTap,
      readOnly: readOnly,
      controller: controller,
      keyboardType: keyboardType,
      textAlignVertical: TextAlignVertical.center,
      textAlign: textAlign,
      style: style,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        isDense: isDense,
        contentPadding: contentPadding,
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
              ? const BorderRadius.vertical(top: Radius.circular(15))
              : BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: fillColor ?? (isDark ? MColors.dark : MColors.light),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: MSizes.formLabelSize,
              ),
        ),
        const SizedBox(height: MSizes.sm),
        field,
      ],
    );
  }
}
