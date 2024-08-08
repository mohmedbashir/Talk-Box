import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/appintment_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/controllers/chat_controller.dart';
import 'package:talk_box/models/user_model.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/utils/helper.dart';

import 'package:talk_box/view/internal%20page/chat_page.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/friend_card.dart';
import 'package:talk_box/view/widgets/head_title.dart';

class MessagesPage extends StatelessWidget {
  MessagesPage({super.key, required this.currnetUser});
  final UserModel currnetUser;
  ChatController chatController = Get.put(ChatController());
  AppController appController = Get.put(AppController());
  AppointementController appointementController =
      Get.put(AppointementController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _meetOfToday(appointementController),
            _messagesBox(),
          ],
        ),
      ),
    );
  }

  Expanded _messagesBox() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeadTitle(title: "inbox".tr),
          Expanded(
            child: StreamBuilder(
                stream: chatController.getChats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive(
                            strokeWidth: 1.5));
                  } else {
                    List chats = [];
                    for (var element in snapshot.data!.docs) {
                      chats.add(element.data());
                    }
                    chats = chats
                        .where(
                          (element) {
                            return element['user1Id'] ==
                                    appController.currentUser.uId ||
                                element['user2Id'] ==
                                    appController.currentUser.uId;
                          },
                        )
                        .where((element) =>
                            element['user1Id'] !=
                                appController.doctorInfo["id"] &&
                            element['user2Id'] !=
                                appController.doctorInfo["id"])
                        .toList();
                    if (chats.isEmpty) {
                      return Center(
                          child: CustomText(
                        text: "inbox2".tr,
                        fontSize: 14,
                      ));
                    }
                    return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          // print(chats.length);

                          return FriendCard(
                            firendCardType: FirendCardType.message,
                            lastMessage: chats[index]['lastMessageSenderId'] ==
                                    appController.currentUser.uId
                                ? '${"me".tr} : ${(chats[index]['lastMessage'] as String).tr}'
                                : (chats[index]['lastMessage'] as String).tr,
                            userPhoto: checkWhichUser(chats, index)
                                ? chats[index]['user2Photo']
                                : chats[index]['user1Photo'],
                            name: checkWhichUser(chats, index)
                                ? chats[index]['user2Name']
                                : chats[index]['user1Name'],
                            userId: checkWhichUser(chats, index)
                                ? chats[index]['user2Id']
                                : chats[index]['user1Id'],
                            time: chats[index]['lastMessageTimestamp']
                                as Timestamp,
                          );
                        });
                  }
                }),
          ),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _meetOfToday(
      AppointementController appointementController) {
    return StreamBuilder(
      stream: appointementController.getMeetOfToday(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          if (snapshot.data!.docs.isNotEmpty) {
            var meetTime = (snapshot.data!.docs
                .where((element) => DateTime.now().isBefore(
                    (element['meetTime'] as Timestamp)
                        .toDate()
                        .add(Duration(hours: 1))))
                .toList());

            return meetTime.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        HeadTitle(title: "sessionWithDoctor".tr),
                        DoctorChatCard(
                            meetId: meetTime[0]['meetId'],
                            meetTime:
                                (meetTime[0]['meetTime'] as Timestamp).toDate())
                      ])
                : SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
    );
  }

  checkWhichUser(chats, index) {
    return chats[index]['user1Id'] == appController.currentUser.uId;
  }

  Widget DoctorChatCard({required DateTime meetTime, required String meetId}) {
    return Container(
      height: 74.16.h,
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(width: 1, color: AppColors.black1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: CircleAvatar(
                  backgroundColor: AppColors.secondaryClr,
                  radius: 26.sp,
                  child: CircleAvatar(
                      backgroundColor: AppColors.white,
                      radius: 25.sp,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: appController.doctorInfo["doctorPhoto"],
                          height: 48.h,
                        ),
                      )),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: appController.doctorInfo["doctorName"],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    width: 210.w,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CustomText(
                            text: meetTime
                                        .difference(DateTime.now())
                                        .inMinutes <=
                                    0
                                ? meetTime
                                            .difference(DateTime.now())
                                            .inMinutes <=
                                        -60
                                    ? "finishedSession".tr
                                    : "startedSession".tr
                                : " ${"yourSessionStartAfter".tr} ${Helper.dateTimeIntoRemainingTime(dateTime: meetTime)}",
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            fontSize: 11.5.sp,
                            color: AppColors.black3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          Container(
            padding: Get.locale.toString().contains("en")
                ? const EdgeInsets.only(right: 10)
                : const EdgeInsets.only(left: 10),
            width: 75.w,
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () => (meetTime.difference(DateTime.now()).inMinutes <=
                          5 &&
                      meetTime.difference(DateTime.now()).inMinutes > -50)
                  ? Get.to(
                      ChatPage(
                        isDoctor: false,
                        meetTime: meetTime,
                        meetId: meetId,
                        friendName: appController.doctorInfo["doctorName"],
                        friendId: appController.doctorInfo["id"],
                        friendPhoto: appController.doctorInfo["doctorPhoto"],
                      ),
                    )
                  : meetTime.difference(DateTime.now()).inMinutes <= -60
                      ? Helper.customSnakBar(
                          title: "theSessionTimeDidintcameYet1".tr,
                          success: false,
                          message: "theSessionTimeDidintcameYet12".tr)
                      : Helper.customSnakBar(
                          title: "theSessionTimeDidintcameYet1".tr,
                          success: false,
                          message: "theSessionTimeDidintcameYet13".tr),
              child: Image.asset(AppAssets.chatIcon,
                  height: 60.sp, color: AppColors.secondaryClr),
            ),
          )
        ],
      ),
    );
  }
}
