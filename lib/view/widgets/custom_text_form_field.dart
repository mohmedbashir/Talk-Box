import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/widgets/custom_text.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      required this.icon,
      required this.hintText,
      required this.label,
      this.obsecureText = false,
      this.suffix = AppAssets.hidePasswordIcon,
      this.prefixOnTap,
      this.validator,
      this.keyboardType,
      this.controller,
      this.maxLines,
      this.isNameField,
      this.onSaved});

  final IconData icon;
  final String hintText;
  final String label;
  final String suffix;
  final bool obsecureText;
  final Function()? prefixOnTap;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final Function(String?)? onSaved;
  final int? maxLines;
  final bool? isNameField;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isNameField == true ? 1 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            fontSize: 15.sp,
          ),
          SizedBox(height: 10.h),
          GetBuilder(
            init: AuthController(),
            builder: (authController) => TextFormField(
                onSaved: onSaved,
                autofocus: false,
                controller: controller,
                keyboardType: keyboardType,
                textInputAction: TextInputAction.next,
                validator: validator,
                obscureText: label == 'password'.tr
                    ? authController.obsecurePassword
                    : false,
                cursorWidth: 1,
                maxLength: isNameField == true ? 10 : null,
                minLines: 1,
                maxLines: maxLines ?? 1,
                obscuringCharacter: '●',
                style: GoogleFonts.alexandria(
                    fontSize: 19.sp, color: AppColors.black),
                decoration: InputDecoration(
                  errorStyle: GoogleFonts.alexandria(fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  prefixIcon: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Icon(
                        icon,
                        color: AppColors.black2,
                      )),
                  suffixIcon: label == 'password'.tr
                      ? Get.locale.toString().contains("en")
                          ? Stack(children: [
                              InkWell(
                                onTap: () =>
                                    authController.onTapObsecureButton(),
                                borderRadius: BorderRadius.circular(50),
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 13, 16),
                                    child: Icon(
                                      authController.obsecurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.black38,
                                      size: 22.sp,
                                    )),
                              ),
                              Positioned(
                                left: 0,
                                top: 10,
                                child: Container(
                                  height: 30.h,
                                  color: AppColors.black1,
                                  width: 1.5,
                                ),
                              ),
                            ])
                          : Stack(children: [
                              InkWell(
                                onTap: () =>
                                    authController.onTapObsecureButton(),
                                borderRadius: BorderRadius.circular(50),
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 13, 16),
                                    child: Icon(
                                      authController.obsecurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.black38,
                                      size: 22.sp,
                                    )),
                              ),
                              Positioned(
                                right: 0,
                                top: 10,
                                child: Container(
                                  height: 30.h,
                                  color: AppColors.black1,
                                  width: 1.5,
                                ),
                              ),
                            ])
                      : null,
                  filled: true,
                  fillColor: AppColors.white,
                  hintText: hintText,
                  hintStyle: GoogleFonts.alexandria(
                      fontSize: 15.sp, color: AppColors.black2),
                  errorBorder: customErrorBorder,
                  focusedErrorBorder: customErrorBorder,
                  border: customBorder,
                  focusedBorder: customBorder,
                  disabledBorder: customBorder,
                  enabledBorder: customBorder,
                )),
          )
        ],
      ),
    );
  }
}
