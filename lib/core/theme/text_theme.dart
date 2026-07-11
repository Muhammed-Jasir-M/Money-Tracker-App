import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tracker_app/core/constants/colors.dart';

class MTextTheme {
  MTextTheme._();

  // Light Theme For Text
  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: MColors.dark,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: MColors.dark,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: MColors.dark,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: MColors.dark,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: MColors.dark,
    ),
    titleSmall: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: MColors.dark,
    ),
    bodyLarge: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      color: MColors.dark,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: MColors.dark,
    ),
    bodySmall: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: MColors.dark,
    ),
    labelLarge: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      color: MColors.dark,
    ),
    labelMedium: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: MColors.dark,
    ),
    labelSmall: GoogleFonts.lato(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: MColors.dark,
    ),
  );

  // Dark Theme For Text
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: MColors.light,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: MColors.light,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: MColors.light,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: MColors.light,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: MColors.light,
    ),
    titleSmall: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: MColors.light,
    ),
    bodyLarge: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      color: MColors.light,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: MColors.light,
    ),
    bodySmall: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: MColors.light,
    ),
    labelLarge: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      color: MColors.light,
    ),
    labelMedium: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: MColors.light,
    ),
    labelSmall: GoogleFonts.lato(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: MColors.light,
    ),
  );
}
