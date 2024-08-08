import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/video_sdk/meeting_screen.dart';
import 'package:talk_box/view/home/doctor/doctor_interface.dart';
import 'package:talk_box/view/internal%20page/shimmer.dart';
import 'package:talk_box/view/widgets/test_page.dart';

import '../widgets/custom_text.dart';

class MainScreen extends StatefulWidget {
  const MainScreen(/* this.userId, */ {super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? userId;
  String? token;
  bool firstInitialize = true;
  @override
  void initState() {
    AppController().onInit();
    userId = AuthController().auth.currentUser!.uid;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    print(authController.isMale);
    return GetBuilder<AppController>(
      init: Get.put(AppController()),
      builder: (controller) => FutureBuilder(
          future: controller.fetchUSerDate(userId!),
          builder: (context, snapshot) {
            return snapshot.connectionState == ConnectionState.waiting &&
                    firstInitialize
                ? const ShimmerEffect()
                : Builder(
                    builder: (context) {
                      firstInitialize = false;
                      return Scaffold(
                        appBar: controller.selectedPage == 3
                            ? null
                            : _customAppBar(controller, authController),
                        body:
                            controller.mainScreenPages[controller.selectedPage],
                        bottomNavigationBar:
                            _customBottomNavigationBar(controller),
                        /*   floatingActionButton:
                            FloatingActionButton(onPressed: () {
                          // Get.dialog(IncomingCall());
                        }), */
                      );
                    },
                  );
          }),
    );
  }

  AppBar _customAppBar(
      AppController appController, AuthController authController) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
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
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              appController.bnbItemTapped(3);
              // Get.to(Testpage());
            },
            child: CircleAvatar(
              backgroundColor: AppColors.black1,
              radius: 23.sp,
              child: CircleAvatar(
                radius: 22.sp,
                backgroundColor: AppColors.backgroundClr,
                child: ClipOval(
                  child: CachedNetworkImage(
                    /*   color: authController.selectedAvatar!
                                .contains('man-avatar.png') ||
                            authController.selectedAvatar!
                                .contains('woman-avatar.png')
                        ? AppColors.black3
                        : null, */
                    imageUrl: appController.currentUser.avatarUrl!,
                    width: 40,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

Container _customBottomNavigationBar(AppController controller) {
  return Container(
    // height: 80.h,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      boxShadow: [
        BoxShadow(
            offset: Offset(-1, -1), blurRadius: 5, color: AppColors.black1)
      ],
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      child: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedPage,
          onTap: (value) => controller.bnbItemTapped(value),
          items: [
            BottomNavigationBarItem(
                icon: Image.asset(
                  AppAssets.homeIcon,
                  height: 32.h,
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(
                      color: AppColors.secondaryClr,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      AppAssets.homeIcon,
                      color: AppColors.white,
                      height: 32.h,
                      width: 32.h,
                    ),
                  ),
                ),
                label: ''),
            BottomNavigationBarItem(
                icon: Image.asset(
                  AppAssets.frindsIcon,
                  height: 30.5.h,
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(
                      color: AppColors.secondaryClr,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      AppAssets.frindsIcon,
                      color: AppColors.white,
                      height: 32.h,
                      width: 32.h,
                    ),
                  ),
                ),
                label: ''),
            BottomNavigationBarItem(
                icon: Image.asset(
                  AppAssets.chatIcon,
                  height: 32.h,
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(
                      color: AppColors.secondaryClr,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      AppAssets.chatIcon,
                      color: AppColors.white,
                      height: 32.h,
                      width: 32.h,
                    ),
                  ),
                ),
                label: ''),
            BottomNavigationBarItem(
                icon: Image.asset(
                  AppAssets.accountIcon,
                  height: 32.h,
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(
                      color: AppColors.secondaryClr,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      AppAssets.accountIcon,
                      color: AppColors.white,
                      height: 32.h,
                      width: 32.h,
                    ),
                  ),
                ),
                label: ''),
          ]),
    ),
  );
}
