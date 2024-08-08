import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/widgets/custom_text.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.onTap,
      required this.label,
      this.fontSize = 18});

  final Function()? onTap;
  final String label;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryClr),
              child: CustomText(
                text: label,
                color: AppColors.white,
                fontSize: fontSize.sp,
              )),
        ),
      ),
    );
  }
}
