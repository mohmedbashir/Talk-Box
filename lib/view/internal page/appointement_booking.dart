import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/appintment_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/widgets/custom_button.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/head_title.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

class AppointementBokking extends StatefulWidget {
  const AppointementBokking({super.key});

  @override
  State<AppointementBokking> createState() => _AppointementBokkingState();
}

class _AppointementBokkingState extends State<AppointementBokking> {
  final AppointementController _appointementController =
      Get.put(AppointementController());

  AppController appController = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _customAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            _aboutDoctor(),
            _selectDate(),
            _doctorPolicies(),
            _appointmentButton(),
          ],
        ),
      ),
    );
  }

  Widget _selectDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadTitle(title: "chooseSessionDate".tr),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 5),
          child: RichText(
            text: TextSpan(
                text: "workHours".tr,
                style: GoogleFonts.alexandria(
                    decoration: TextDecoration.none,
                    fontSize: 14.5.sp,
                    wordSpacing: 1,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600),
                children: [
                  TextSpan(
                    text: "workHoursDescription".tr,
                    style: GoogleFonts.alexandria(
                        decoration: TextDecoration.none,
                        fontSize: 14.5.sp,
                        wordSpacing: 1,
                        color: AppColors.black,
                        fontWeight: FontWeight.w300),
                  )
                ]),
          ),
        ),
        Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.borderClr, width: 1.5)),
          child: CupertinoDatePicker(
            initialDateTime: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              DateTime.now().hour + 2,
            ),
            maximumDate: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ).add(Duration(days: 3)),
            minimumDate: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              DateTime.now().hour + 2,
            ),
            mode: CupertinoDatePickerMode.dateAndTime,
            minuteInterval: 60,
            onDateTimeChanged: (value) =>
                _appointementController.updateDateTime(value),
          ),
        ),
      ],
    );
  }

  AppBar _customAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.backgroundClr,
      leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
          onPressed: () => Get.back()),
      centerTitle: true,
      title: CustomText(text: "bookASession".tr, fontSize: 20),
    );
  }

  Widget _appointmentButton() {
    return GetBuilder<AppointementController>(
      builder: (controller) => controller.bookingLoading == false
          ? CustomButton(
              onTap: controller.doctorPoliciesCheckBoxValue == false
                  ? null
                  : () => controller.bookAMeet(),
              label: "bookButtonText".tr +
                  " ${controller.meetPrice.toString()} " +
                  "just".tr,
              fontSize: 17)
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

  Widget _doctorPolicies() {
    return Row(children: [
      GetBuilder<AppointementController>(
        builder: (controller) => Checkbox(
          value: controller.doctorPoliciesCheckBoxValue,
          onChanged: (value) {
            controller.checkBoxOnTap(value!);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
      CustomText(
        text: "sessionPagePolicyCheckBox".tr,
        fontSize: 13,
      ),
      GestureDetector(
          onTap: () async {
            final url =
                await AppController.getAppLinks(neddedLink: 'appPolicies');
            try {
              await launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
            } catch (e) {
              print(e);
            }
          },
          child: CustomText(
            text: "appPolicies".tr,
            color: AppColors.secondaryClr,
            fontSize: 13,
          )),
    ]);
  }

  Column _aboutDoctor() {
    AppointementController appointementController =
        Get.put(AppointementController());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadTitle(title: "aboutDoctor".tr),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(width: 2, color: AppColors.black1)),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: Container(
                  width: double.infinity,
                  height: 7,
                  color: AppColors.secondaryClr,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              AppColors.secondaryClr.withOpacity(.6),
                          radius: 34.sp,
                          child: CircleAvatar(
                            backgroundColor: AppColors.white,
                            radius: 32.sp,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl:
                                    appController.doctorInfo["doctorPhoto"],
                                height: 62,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            CustomText(
                              text: appController.doctorInfo["doctorName"],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            CustomText(
                              text: "jobTitle".tr,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black3,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        height: 1,
                        width: 313.6.w,
                        color: AppColors.black1,
                      ),
                    ),
                    CustomText(
                      text: "sessionDescription".tr +
                          " ${appointementController.meetPrice.toString()} " +
                          "just".tr,
                      fontSize: 13,
                      textAlign: TextAlign.start,
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    MaterialButton(
                      onPressed: () async {
                        final url = await AppController.getAppLinks(
                            neddedLink: 'doctorCV');
                        try {
                          await launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        } catch (e) {}
                      },
                      child: CustomText(
                        text: "openCVLink".tr,
                        fontSize: 12,
                        color: AppColors.secondaryClr,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
