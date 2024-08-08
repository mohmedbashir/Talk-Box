import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/auth/sign_in_screen.dart';
import 'package:talk_box/view/widgets/custom_button.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/custom_text_form_field.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends GetWidget<AuthController> {
  SignUpScreen({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              _title(),
              _changeAvatar(),
              _userInfo(_authController, _formKey),
              _usagePolicy(),
              _signUpButton(),
              _or(),
              _doYouHaveAnAccount()
            ],
          ),
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return GetBuilder<AuthController>(
      builder: (controller) => controller.signLoading == false
          ? CustomButton(
              onTap: controller.usagePoliciesCheckBoxValue
                  ? () {
                      _formKey.currentState!.save();
                      if (_formKey.currentState!.validate()) {
                        controller.signUp();
                      }
                    }
                  : null,
              label: "register".tr,
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

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          CustomText(
            text: "createAccount".tr,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ],
      ),
    );
  }
}

Widget _changeAvatar() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: GetBuilder<AuthController>(
          builder: (controller) => Stack(children: [
            InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                Get.bottomSheet(Container(
                  decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25))),
                  child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(5),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, mainAxisSpacing: 5),
                      itemCount: 40,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            controller.changeAvatar(
                                'https://firebasestorage.googleapis.com/v0/b/talk-box-7bc47.appspot.com/o/Avatar%2F${index + 1}.png?alt=media&token=e94c0927-3047-4708-ae86-145a06668481&_gl=1*16ks8rz*_ga*MTM4NzU4MDU0Mi4xNjc1MjQ4Njcw*_ga_CW55HF8NVT*MTY4NTgwNjMxNS42Ny4xLjE2ODU4MTQwNjguMC4wLjA.');
                            Get.back();
                          },
                          child: ClipOval(
                              child: Image.asset(
                                  'assets/avatars/${index + 1}.png')),
                        );
                      }),
                ));
              },
              child: CircleAvatar(
                  backgroundColor: AppColors.borderClr,
                  radius: 48.sp,
                  child: CircleAvatar(
                    backgroundColor: AppColors.white,
                    radius: 46.sp,
                    child: ClipOval(
                      child: controller.selectedAvatar != null
                          ? CachedNetworkImage(
                              imageUrl: controller.selectedAvatar!,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator.adaptive(
                                      strokeWidth: 1.5),
                              fit: BoxFit.contain,
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Image.asset(
                                AppAssets.avatarIcon,
                                height: 70.h,
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                  )),
            ),
            controller.selectedAvatar == null
                ? Positioned(
                    right: 3,
                    bottom: 3,
                    child: CircleAvatar(
                      backgroundColor: AppColors.white,
                      radius: 17.sp,
                      child: CircleAvatar(
                        radius: 15.sp,
                        backgroundColor: AppColors.secondaryClr,
                        child: Icon(Icons.add, color: AppColors.white),
                      ),
                    ))
                : Container()
          ]),
        ),
      ),
    ],
  );
}

Widget _userInfo(AuthController controller, GlobalKey formKey) {
  return Form(
    key: formKey,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                onSaved: (p0) => controller.firstNameController.text = p0!,
                keyboardType: TextInputType.name,
                label: "firstName".tr,
                isNameField: true,
                icon: Icons.person_2_outlined,
                hintText: "firstName".tr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "requiredField".tr;
                  } else if (value.length < 3) {
                    return "tooShortName".tr;
                  } else {
                    return null;
                  }
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: CustomTextFormField(
                onSaved: (p0) => controller.lastNameController.text = p0!,
                keyboardType: TextInputType.name,
                label: "lastName".tr,
                isNameField: true,
                icon: Icons.person_2_outlined,
                hintText: "lastName".tr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "requiredField".tr;
                  } else if (value.length < 3) {
                    return "tooShortName".tr;
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ],
        ),
        CustomTextFormField(
          onSaved: (p0) => controller.bioController.text = p0!,
          keyboardType: TextInputType.text,
          label: "bio".tr,
          maxLines: 5,
          icon: Icons.text_fields_rounded,
          hintText: "bioHint".tr,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "requiredField".tr;
            }
            return null;
          },
        ),
        CustomTextFormField(
          onSaved: (p0) => controller.emailController.text = p0!,
          keyboardType: TextInputType.emailAddress,
          label: "email".tr,
          icon: Icons.email_outlined,
          hintText: "emailHint".tr,
          validator: (value) {
            RegExp regex = RegExp(
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
            if (value == null || value.isEmpty) {
              return "requiredField".tr;
            } else if (!regex.hasMatch(value)) {
              return "invalidEmail".tr;
            }
            return null;
          },
        ),
        GetBuilder<AuthController>(
          builder: (controller) => CustomTextFormField(
            onSaved: (p0) => controller.passwordController.text = p0!,
            keyboardType: TextInputType.visiblePassword,
            obsecureText: controller.obsecurePassword,
            prefixOnTap: () => controller.onTapObsecureButton(),
            label: "password".tr,
            icon: Icons.lock_outline_rounded,
            hintText: "passwordHint".tr,
            validator: (value) {
              RegExp regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])');
              if (value == null || value.isEmpty) {
                return "requiredField".tr;
              } else if (value.length < 8) {
                return "atLeast8digits".tr;
              } else if (!regex.hasMatch(value)) {
                return "numbers&letters".tr;
              }
              return null;
            },
          ),
        ),
        Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "age".tr,
                  fontSize: 14,
                ),
                const SizedBox(height: 10),
                Container(
                  height: 55.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(color: AppColors.borderClr, width: 1.5)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FloatingActionButton(
                          heroTag: "btn1",
                          elevation: 2,
                          highlightElevation: 2,
                          backgroundColor: AppColors.secondaryClr,
                          mini: true,
                          onPressed: () => controller.changeAge('+'),
                          child: Icon(
                            Icons.add,
                            size: 30.sp,
                          ),
                        ),
                        GetBuilder<AuthController>(
                            builder: (controller) => CustomText(
                                  text: controller.age.toString(),
                                  fontSize: 20,
                                )),
                        FloatingActionButton(
                          heroTag: "btn2",
                          elevation: 2,
                          highlightElevation: 2,
                          backgroundColor: AppColors.secondaryClr,
                          mini: true,
                          onPressed: () => controller.changeAge('-'),
                          child: Icon(
                            Icons.remove,
                            size: 30.sp,
                          ),
                        )
                      ]),
                ),
              ],
            )),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "gender".tr,
                  fontSize: 14,
                ),
                const SizedBox(height: 10),
                Container(
                  height: 55.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(color: AppColors.borderClr, width: 1.5)),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: GetBuilder<AuthController>(
                      init: AuthController(),
                      builder: (controller) => Row(children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => controller.changeGender(0),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                                decoration: controller.isMale
                                    ? BoxDecoration(
                                        color: AppColors.secondaryClr,
                                        borderRadius: BorderRadius.circular(10))
                                    : null,
                                child: Center(
                                  child: CustomText(
                                    text: "male".tr,
                                    fontSize: 17,
                                    color: controller.isMale
                                        ? AppColors.white
                                        : AppColors.black,
                                  ),
                                )),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                            child: InkWell(
                          onTap: () => controller.changeGender(1),
                          child: Container(
                              decoration: !controller.isMale
                                  ? BoxDecoration(
                                      color: AppColors.secondaryClr,
                                      borderRadius: BorderRadius.circular(10))
                                  : null,
                              child: Center(
                                  child: CustomText(
                                text: "female".tr,
                                fontSize: 17,
                                color: !controller.isMale
                                    ? AppColors.white
                                    : AppColors.black,
                              ))),
                        )),
                      ]),
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
      ],
    ),
  );
}

Row _usagePolicy() {
  return Row(children: [
    GetBuilder<AuthController>(
      builder: (controller) => Checkbox(
        value: controller.usagePoliciesCheckBoxValue,
        onChanged: (value) => controller.checkBoxOnTap(value!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ),
    Row(
      children: [
        CustomText(
          text: "sessionPagePolicyCheckBox".tr,
          fontSize: 13,
        ),
        GestureDetector(
          onTap: () async {
            //replace this with Policies Link
            final url = "https://talk-box-7bc47.web.app/privecy_policy.html";
            try {
              await launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
            } catch (e) {
              print(e);
            }
          },
          child: CustomText(
            text: "appPolicies".tr,
            fontSize: 13,
            color: AppColors.secondaryClr,
          ),
        ),
      ],
    ),
  ]);
}

Widget _or() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          color: AppColors.black1,
          height: 1,
          width: 160.h,
        ),
        CustomText(
          text: "or".tr,
          fontSize: 12,
        ),
        Container(
          color: AppColors.black1,
          height: 1,
          width: 160.h,
        ),
      ],
    ),
  );
}

Row _doYouHaveAnAccount() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CustomText(text: "doYouHaveAnAccount".tr, fontSize: 14),
      InkWell(
        onTap: () => Get.offAll(
          SignInScreen(),
        ),
        child: CustomText(
          text: "signIn".tr,
          color: AppColors.primaryClr,
          fontSize: 14,
        ),
      )
    ],
  );
}
