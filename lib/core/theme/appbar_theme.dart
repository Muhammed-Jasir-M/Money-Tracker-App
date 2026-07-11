import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';

class MAppbarTheme {
  MAppbarTheme._();

  // Light Theme for Appbar
  static const lightAppbarTheme = AppBarTheme(
    scrolledUnderElevation: 0,
    backgroundColor: MColors.light,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: MColors.dark, size: MSizes.iconMd),
  );

  // Dark Theme For Appbar
  static const darkAppbarTheme = AppBarTheme(
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: MColors.light, size: MSizes.iconMd),
  );
}
