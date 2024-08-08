import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class Themes {
  static final theme = ThemeData(
      primaryColor: AppColors.primaryClr,
      scaffoldBackgroundColor: Color(0xfff0f1f9),
      brightness: Brightness.light);
}

TextStyle get headingStyle1 => GoogleFonts.cairo(
      fontSize: 30,
      fontWeight: FontWeight.w800,
    );
TextStyle get headingStyle2 => GoogleFonts.cairo(
      fontSize: 26,
      fontWeight: FontWeight.w700,
    );
TextStyle get headingStyle3 => GoogleFonts.cairo(
      fontSize: 24,
      fontWeight: FontWeight.w700,
    );
TextStyle get headingStyle4 => GoogleFonts.cairo(
      fontSize: 20,
      fontWeight: FontWeight.w700,
    );
TextStyle get headingStyle5 => GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
TextStyle get headingStyle6 => GoogleFonts.cairo(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
