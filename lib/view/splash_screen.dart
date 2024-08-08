import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/services/local_storage_service.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/auth/sign_in_screen.dart';
import 'package:talk_box/view/home/doctor/doctor_interface.dart';
import 'package:talk_box/view/home/main_screen.dart';
import 'package:talk_box/view/internal%20page/shimmer.dart';
import 'package:talk_box/view/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  Map doctorInfo = {};
  getUserId() async {
    userId = await LocalStorageService().readData();
  }

  getdoctorInfo() async {
    // await appController.getDoctorInfo();
    doctorInfo = {
      "doctorPhoto": await AppController.getAppLinks(
          neddedLink: 'doctorInfo', key: 'doctorPhoto'),
      "doctorName": await AppController.getAppLinks(
          neddedLink: 'doctorInfo', key: 'doctorName'),
      "id":
          await AppController.getAppLinks(neddedLink: 'doctorInfo', key: 'id'),
      "cv":
          await AppController.getAppLinks(neddedLink: 'doctorInfo', key: 'cv'),
    };
  }

  String userId = '';
  AuthController authController = Get.put(AuthController());
  AppController appController = Get.put(AppController());

  /*  bool? isFirstTime = true;
  initializeOnBoardingScreens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('isFirstTime');
  }
 */
  // String doctorId = '';
  // getDoctorId() async {
  //   doctorId = await appController.doctorInfo["id"];
  // }

  @override
  void initState() {
    getUserId();
    // getdoctorInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getdoctorInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              backgroundColor: AppColors.primaryClr,
              body: Center(
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 1.5,
                  backgroundColor: Colors.white,
                ),
              ));
        }
        return GetBuilder<AuthController>(
            init: Get.put(AuthController()),
            builder: (controller) => controller.auth.currentUser != null
                ? controller.auth.currentUser!.uid == doctorInfo["id"]
                    ? DoctorInterface()
                    : MainScreen()
                : OnBoardingScreen());
      },
    );
  }
}
