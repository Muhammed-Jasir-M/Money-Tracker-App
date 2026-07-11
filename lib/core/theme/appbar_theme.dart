import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';

class MAppbarTheme {
  MAppbarTheme._();

  static const lightAppbarTheme = AppBarTheme(
    scrolledUnderElevation: 0,
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: MColors.black,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: MColors.darkGrey, size: MSizes.iconMd),
  );

  static const darkAppbarTheme = AppBarTheme(
    scrolledUnderElevation: 0,
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: MColors.white,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: MColors.white, size: MSizes.iconMd),
  );
}
