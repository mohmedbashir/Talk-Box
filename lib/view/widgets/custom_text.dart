import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_box/utils/constants.dart';

class CustomText extends StatelessWidget {
  const CustomText(
      {super.key,
      required this.text,
      this.color = AppColors.black,
      this.fontSize = 18,
      this.fontWeight = FontWeight.w500,
      this.textAlign = TextAlign.center,
      this.maxLines = 10});
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.alexandria(
          decoration: TextDecoration.none,
          fontSize: fontSize.sp,
          color: color,
          fontWeight: fontWeight),
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}
