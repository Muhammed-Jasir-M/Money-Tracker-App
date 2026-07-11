import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/theme/appbar_theme.dart';
import 'package:money_tracker_app/core/theme/text_theme.dart';

class MAppTheme {
  MAppTheme._();

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: MColors.primary,
    scaffoldBackgroundColor: MColors.bgLight,
    disabledColor: MColors.lightGrey,
    appBarTheme: MAppbarTheme.lightAppbarTheme,
    textTheme: MTextTheme.lightTextTheme,
    iconTheme: IconThemeData(color: MColors.dark, size: MSizes.iconMd),
    colorScheme: ColorScheme.light(
      surface: MColors.bgLight,
      onSurface: MColors.black,
      primary: MColors.primary,
      secondary: MColors.secondary,
      tertiary: MColors.tertiary,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: MColors.primary,
    scaffoldBackgroundColor: MColors.bgDark,
    disabledColor: MColors.darkGrey,
    appBarTheme: MAppbarTheme.darkAppbarTheme,
    textTheme: MTextTheme.darkTextTheme,
    iconTheme: IconThemeData(color: MColors.light, size: MSizes.iconMd),
    colorScheme: ColorScheme.dark(
      surface: MColors.bgDark,
      onSurface: MColors.white,
      primary: MColors.primary,
      secondary: MColors.secondary,
      tertiary: MColors.tertiary,
    ),
  );
}
