import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/controllers/doctor_interface_controller.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/head_title.dart';

class DoctorInterface extends StatelessWidget {
  // DoctorInterface({super.key, required this.doctorInfo});
  // final Map doctorInfo;
  final DoctorInterfaceController doctorInterfaceController =
      Get.put(DoctorInterfaceController());
  final AuthController authController = Get.put(AuthController());
  final AppController appController = Get.put(AppController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _customAppBar(context, authController, appController),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(children: [HeadTitle(title: "sessions".tr)]),
            _daysBar(),
            GetBuilder<DoctorInterfaceController>(
                builder: (controller) => Expanded(
                    child: controller.meets(controller.selectedDayIndex))),
          ],
        ),
      ),
    );
  }

  Widget _daysBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GetBuilder<DoctorInterfaceController>(
            builder: (controller) => InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => controller.changeSelectedDay("today"),
              child: Container(
                width: 115.w,
                height: 43.h,
                decoration: BoxDecoration(
                    color: controller.selectedDayIndex == "today"
                        ? AppColors.secondaryClr
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: AppColors.black1)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomText(
                    text: "today".tr,
                    fontSize: 16,
                    color: controller.selectedDayIndex == "today"
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          GetBuilder<DoctorInterfaceController>(
            builder: (controller) => InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                controller.changeSelectedDay("tomorrow");
                // print(controller.selectedDayIndex);
              },
              child: Container(
                width: 115.w,
                height: 43.h,
                decoration: BoxDecoration(
                    color: controller.selectedDayIndex == "tomorrow"
                        ? AppColors.secondaryClr
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: AppColors.black1)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomText(
                    text: "tomorrow".tr,
                    fontSize: 16,
                    color: controller.selectedDayIndex == "tomorrow"
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          GetBuilder<DoctorInterfaceController>(
            builder: (controller) => InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => controller.changeSelectedDay("after tomorrow"),
              child: Container(
                width: 115.w,
                height: 43.h,
                decoration: BoxDecoration(
                    color: controller.selectedDayIndex == "after tomorrow"
                        ? AppColors.secondaryClr
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: AppColors.black1)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: FittedBox(
                    child: CustomText(
                      text: "afterTomorrow".tr,
                      fontSize: 16,
                      color: controller.selectedDayIndex == "after tomorrow"
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _customAppBar(BuildContext context, AuthController authController,
      AppController appController) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      leading: IconButton(
          icon: Icon(
            Icons.exit_to_app_rounded,
            color: AppColors.black3,
          ),
          onPressed: () async {
            print(
                "the token is :${await FirebaseMessaging.instance.getToken()}");
            showDialog(
                context: context,
                builder: (context) => _signOutConfirmation(authController));
          }),
      title: RichText(
        text: TextSpan(
          text: '',
          style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.bold),
          children: const <TextSpan>[
            TextSpan(
              text: 'T',
              style: TextStyle(color: AppColors.primaryClr),
            ),
            TextSpan(
              text: 'alk',
              style: TextStyle(color: AppColors.black),
            ),
            TextSpan(
              text: 'B',
              style: TextStyle(color: AppColors.primaryClr),
            ),
            TextSpan(
              text: 'ox',
              style: TextStyle(color: AppColors.black),
            ),
          ],
        ),
      ),
      elevation: 0,
      backgroundColor: AppColors.backgroundClr,
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 5),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: CircleAvatar(
              backgroundColor: AppColors.secondaryClr,
              radius: 19.sp,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: appController.doctorInfo["doctorPhoto"],
                  width: 50,
                  // fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

/*   _listOfMeets(String day) {
    switch (day) {
      case "today":
        return controller.meets[0];
      // break;
      case "tomorrow":
        return controller.meets[1];
      // break;
      case "after tomorrow":
        return controller.meets[1];
      // break;
    }
  } */
}

Center _signOutConfirmation(AuthController controller) {
  return Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        color: Colors.white,
        height: 120.h,
        width: 280.w,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const CustomText(
                  textAlign: TextAlign.center,
                  text: 'هل حقاً تريد تسجيل الخروج ؟',
                  fontSize: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: MaterialButton(
                        height: 50,
                        onPressed: () => controller.signOut(),
                        child: const CustomText(
                          text: 'نعم',
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(color: Colors.black12, height: 35, width: 1),
                    Expanded(
                      child: MaterialButton(
                        height: 50,
                        onPressed: () => Get.back(),
                        child: const CustomText(
                          text: 'لا',
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                )
              ]),
        ),
      ),
    ),
  );
}
