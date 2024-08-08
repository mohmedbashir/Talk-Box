import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/controllers/chat_controller.dart';
import 'package:talk_box/models/user_model.dart';
import 'package:talk_box/services/notification_service.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/head_title.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatelessWidget {
  AccountPage({super.key, required this.currnetUser});
  final UserModel currnetUser;
  final AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: ListView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(15),
        children: [
          Row(
            children: [
              HeadTitle(title: "accoundDetails".tr),
            ],
          ),
          _userInformations(),
          const SizedBox(height: 5),
          _options(context),
        ],
      ),
    ));
  }

  Container _options(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    return Container(
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15)),
          border: Border.all(width: 2, color: AppColors.black1)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Column(
            children: [
              _option(
                icon: AppAssets.changeAvatarIcon,
                label: "option1".tr,
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
                              authController.changeAvatar(
                                  'https://firebasestorage.googleapis.com/v0/b/talk-box-7bc47.appspot.com/o/Avatar%2F${index + 1}.png?alt=media&token=e94c0927-3047-4708-ae86-145a06668481&_gl=1*16ks8rz*_ga*MTM4NzU4MDU0Mi4xNjc1MjQ4Njcw*_ga_CW55HF8NVT*MTY4NTgwNjMxNS42Ny4xLjE2ODU4MTQwNjguMC4wLjA.');
                              Get.back();
                              authController.update();
                            },
                            child: ClipOval(
                                child: Image.asset(
                                    'assets/avatars/${index + 1}.png')),
                          );
                        }),
                  ));
                },
              ),
              /*     _option(
                icon: AppAssets.storyIcon,
                 label: "myStories".tr,
                onTap: () async {
                  await NotificationService.scheduleNotification(
                      body: "sdsa",
                      title: "masd",
                      scheduled: NotificationCalendar.fromDate(
                          date:
                              DateTime.now().add(const Duration(seconds: 5))));
                },
              ), */
              _option(
                icon: AppAssets.rateIcon,
                label: "rateTheApp".tr,
                onTap: () async {
                  final url = await AppController.getAppLinks(
                      neddedLink:
                          defaultTargetPlatform == TargetPlatform.android
                              ? 'appLinkOnGoogleStore'
                              : 'appLinkOnAppleStore');
                  try {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              _option(
                icon: AppAssets.chatIcon,
                label: "contactUs".tr,
                onTap: () async {
                  final url = await AppController.getAppLinks(
                      neddedLink: 'contactLink');
                  try {
                    await launchUrl(Uri.parse('mailto:$url'),
                        mode: LaunchMode.externalNonBrowserApplication);
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              _option(
                  icon: AppAssets.shareIcon,
                  label: "share".tr,
                  onTap: () async {
                    final url = await AppController.getAppLinks(
                        neddedLink:
                            defaultTargetPlatform == TargetPlatform.android
                                ? 'appLinkOnGoogleStore'
                                : 'appLinkOnAppleStore');
                    await Share.share(url);
                  }),
              /*   _option(
                  icon: AppAssets.logoutIcon,
                  label: "VOICE TEST PAGE".tr,
                  onTap: () => Get.to(VoiceTestPage())), */
              _option(
                  icon: AppAssets.logoutIcon,
                  label: "signOut".tr,
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) =>
                          _signOutConfirmation(authController))),
            ],
          )
        ]),
      ),
    );
  }

  Widget _option(
      {required String icon,
      required String label,
      required Function()? onTap}) {
    return Column(
      children: [
        icon != AppAssets.changeAvatarIcon
            ? Container(
                width: double.infinity, color: AppColors.black1, height: 1)
            : Container(),
        MaterialButton(
          onPressed: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Image.asset(
                  icon,
                  height: 30,
                  color: AppColors.black3,
                ),
                const SizedBox(width: 15),
                CustomText(text: label, fontSize: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container _userInformations() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          border: Border.all(width: 2, color: AppColors.black1)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            child: Container(
              width: double.infinity,
              height: 7,
              color: AppColors.secondaryClr,
            ),
          ),
          Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CircleAvatar(
                      backgroundColor: AppColors.secondaryClr.withOpacity(.6),
                      radius: 37.sp,
                      child: CircleAvatar(
                        backgroundColor: AppColors.white,
                        radius: 35.sp,
                        child: ClipOval(
                          child: GetBuilder<AuthController>(
                            init: Get.put(AuthController()),
                            builder: (controller) => CachedNetworkImage(
                              imageUrl: controller.selectedAvatar ??
                                  currnetUser.avatarUrl!,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 1.5),
                              ),
                              height: 68.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: CustomText(
                      text: currnetUser.name!,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: CustomText(
                      text: '${"age".tr} : ${currnetUser.age} ${"year".tr}',
                      fontSize: 13,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    child: SizedBox(
                      width: 350.w,
                      child: CustomText(
                        text: currnetUser.bio!,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Center _signOutConfirmation(AuthController controller) {
  return Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        color: Colors.white,
        height: 140.h,
        width: 313.6.w,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomText(
                  textAlign: TextAlign.center,
                  text: "areYouSureOfLoggingOut".tr,
                  fontSize: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: MaterialButton(
                        height: 50,
                        onPressed: () => controller.signOut(),
                        child: CustomText(
                          text: "yes".tr,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(color: Colors.black12, height: 35, width: 1),
                    Expanded(
                      child: MaterialButton(
                        height: 50,
                        onPressed: () => Get.back(),
                        child: CustomText(
                          text: "no".tr,
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
