import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/utils/helper.dart';
import 'package:talk_box/view/auth/sign_up_screen.dart';
import 'package:talk_box/view/widgets/custom_button.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/custom_text_form_field.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(15), children: [
          SizedBox(height: 130.h),
          _title(),
          SizedBox(height: 40.h),
          _userInfo(_authController, _formKey),
          _passwordForgotten(),
          // _signInButton(),
          _signInButton(),
          _or(),
          _dontHaveAnAccount()
        ]),
      ),
    );
  }

  GetBuilder<AuthController> _signInButton() {
    return GetBuilder<AuthController>(
      builder: (controller) => controller.signLoading == false
          ? CustomButton(
              onTap: () {
                _formKey.currentState!.save();
                if (_formKey.currentState!.validate()) {
                  _authController.signIn();
                }
              },
              label: "signIn".tr,
              fontSize: 20,
            )
          : SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryClr),
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 1.5,
                      backgroundColor: Colors.white,
                    )),
              ),
            ),
    );
  }

  Row _dontHaveAnAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(text: "donthaveAnAccount".tr, fontSize: 14),
        InkWell(
          onTap: () => Get.offAll(
            SignUpScreen(),
          ),
          child: CustomText(
            text: "createOne".tr,
            color: AppColors.primaryClr,
            fontSize: 14,
          ),
        )
      ],
    );
  }

  Padding _or() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: AppColors.black1,
            height: 1,
            width: 157.w,
          ),
          CustomText(
            text: "or".tr,
            fontSize: 15,
          ),
          Container(
            color: AppColors.black1,
            height: 1,
            width: 157.w,
          ),
        ],
      ),
    );
  }

  Padding _passwordForgotten() {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> emailTFKey = GlobalKey<FormState>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              Get.bottomSheet(Container(
                height: 200.h,
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25))),
                child: Column(
                  children: [
                    Form(
                      key: emailTFKey,
                      child: CustomTextFormField(
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email,
                        hintText: "emailHint".tr,
                        label: "email".tr,
                        controller: emailController,
                        validator: (value) {
                          RegExp regex = RegExp(
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                          if (value == null || value.isEmpty) {
                            return "requiredField".tr;
                          } else if (!regex.hasMatch(value)) {
                            return "inCorrectEmail".tr;
                          }
                          return null;
                        },
                      ),
                    ),
                    CustomButton(
                        onTap: () async {
                          emailTFKey.currentState!.save();
                          if (emailTFKey.currentState!.validate()) {
                            try {
                              await AuthController()
                                  .auth
                                  .sendPasswordResetEmail(
                                      email: emailController.text.trim());
                              Get.back();
                              emailController.clear();
                              Helper.customSnakBar(
                                  success: true,
                                  title: 'checkYourEmail'.tr,
                                  message: "messageSentToYourEmail".tr.tr);
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                Helper.customSnakBar(
                                    success: false,
                                    title: "snackBar2".tr,
                                    message: "snackBar22".tr);
                              } else if (e.code == 'wrong-password') {
                                Helper.customSnakBar(
                                    success: false,
                                    title: "snackBar3".tr,
                                    message: "snackBar32".tr);
                              } else if (e.code == 'too-many-requests') {
                                Helper.customSnakBar(
                                    success: false,
                                    title: "snackBar4".tr,
                                    message: "snackBar42".tr);
                              }
                            }
                          }
                        },
                        label: "sendLinkBtn".tr)
                  ],
                ),
              ));
            },
            child: Text(
              "forgetPassword".tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Form _userInfo(AuthController controller, GlobalKey formKey) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (p0) => controller.loginEmailController.text = p0!,
            icon: Icons.email_outlined,
            hintText: "emailHint".tr,
            label: "email".tr,
            validator: (value) {
              RegExp regex = RegExp(
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
              if (value == null || value.isEmpty) {
                return "requiredField".tr;
              } else if (!regex.hasMatch(value)) {
                return "inCorrectEmail".tr;
              }
              return null;
            },
          ),
          CustomTextFormField(
            onSaved: (p0) => controller.loginPasswordController.text = p0!,
            icon: Icons.lock_outline_rounded,
            hintText: "passwordHint".tr,
            label: "password".tr,
            validator: (value) {
              RegExp regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])');
              if (value == null || value.isEmpty) {
                return "requiredField".tr;
              } else if (value.length < 8) {
                return "atLeast8digits".tr;
              } else if (!regex.hasMatch(value)) {
                return "inCorrectPassword".tr;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  RichText _title() {
    return RichText(
      text: TextSpan(
        text: '${"welcomeBack".tr}\n',
        style: GoogleFonts.cairo(
            color: AppColors.black, fontSize: 28, fontWeight: FontWeight.w700),
        children: <TextSpan>[
          TextSpan(
              text: "talkBox".tr,
              style: GoogleFonts.cairo(
                  color: AppColors.primaryClr,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
