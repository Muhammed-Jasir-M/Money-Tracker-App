import 'dart:math';

import 'package:flutter/material.dart';

class MColors {
  static const bgLight = Color(0xFFF5F5F5);
  static const bgDark = Color(0xFF212121);

  static const dark = Color(0xFF292727);
  static const light = Color(0xFFD4C8C8);

  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  static const primary = Color(0xFF00B2E7);
  static const secondary = Color(0xFFE064F7);
  static const tertiary = Color(0xFFFF8D6C);

  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF2E2E2E);
  static const Color lightGrey = Color(0xFFF0EDED);
  static const Color softGrey = Color(0xFFF4F4F4);

  static const outline = Color(0xFFBDBDBD);

  static const Gradient floatingButtonGradient = LinearGradient(
    colors: [
      MColors.tertiary,
      MColors.secondary,
      MColors.primary,
    ],
    transform: GradientRotation(pi / 4),
  );

  static const Gradient boxGradient = LinearGradient(
    colors: [
      MColors.primary,
      MColors.secondary,
      MColors.tertiary,
    ],
    transform: GradientRotation(pi / 4),
  );

  static const Gradient barChartGradient = LinearGradient(
    colors: [
      MColors.primary,
      MColors.secondary,
      MColors.tertiary,
    ],
    transform: GradientRotation(pi / 40),
  );
}
