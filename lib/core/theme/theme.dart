import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/theme/appbar_theme.dart';
import 'package:money_tracker_app/core/theme/text_theme.dart';

class MAppTheme {
  MAppTheme._();

  static ButtonStyle _segmentedStyle(Color accent, Color base) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accent.withValues(alpha: 0.14);
        }
        return base;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accent;
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return BorderSide(color: accent, width: 1.5);
        }
        return BorderSide.none;
      }),
    );
  }

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: MColors.primary,
    scaffoldBackgroundColor: MColors.bgLight,
    disabledColor: MColors.lightGrey,
    appBarTheme: MAppbarTheme.lightAppbarTheme,
    textTheme: MTextTheme.lightTextTheme,
    iconTheme: const IconThemeData(color: MColors.darkGrey, size: MSizes.iconMd),
    colorScheme: const ColorScheme.light(
      surface: MColors.bgLight,
      onSurface: MColors.black,
      primary: MColors.primary,
      secondary: MColors.primary,
      tertiary: MColors.tertiary,
      surfaceContainerHighest: MColors.white,
      outline: Color(0xFFE2E2E2),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: _segmentedStyle(MColors.primary, MColors.white),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: MColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
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
    iconTheme: const IconThemeData(color: MColors.white, size: MSizes.iconMd),
    colorScheme: const ColorScheme.dark(
      surface: MColors.bgDark,
      onSurface: MColors.white,
      primary: MColors.primary,
      secondary: MColors.primary,
      tertiary: MColors.tertiary,
      surfaceContainerHighest: MColors.cardDark,
      outline: Color(0xFF3A3A3A),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: _segmentedStyle(MColors.primary, MColors.cardDark),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: MColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
