import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:talk_box/view/internal%20page/chat_page.dart';
import 'package:talk_box/view/widgets/custom_text.dart';

import '../utils/constants.dart';
import '../utils/helper.dart';

class DoctorInterfaceController extends GetxController {
  changeSelectedDay(String day) {
    selectedDayIndex = day;
    update();
  }

  String selectedDayIndex = "today";
  Widget meets(String day) {
    if (day == "today") {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('DoctorMeets')
            .where('finished', isEqualTo: 'false')
            .where('payment', isEqualTo: 'completed')
            .where('meetTime',
                isGreaterThan: Timestamp.fromDate(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                )))
            .where('meetTime',
                isLessThanOrEqualTo: Timestamp.fromDate(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ).add(Duration(days: 1))))
            .orderBy('meetTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else {
            if (snapshot.hasData) {
              List meets = snapshot.data!.docs
                  .where((element) => DateTime.now().isBefore(
                      (element['meetTime'] as Timestamp)
                          .toDate()
                          .add(Duration(hours: 1))))
                  .toList();
              print(meets.length);
              return meets.length > 0
                  ? ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: meets.length,
                      itemBuilder: (context, index) => _doctorChatCard(
                          id: meets[index]['userId'],
                          meetTime:
                              (meets[index]['meetTime'] as Timestamp).toDate(),
                          meetId: meets[index]['meetId'].toString(),
                          name: meets[index]['userName'],
                          photo: meets[index]['userPhoto']),
                    )
                  : Center(
                      child: CustomText(text: "noSessions".tr, fontSize: 14));
            }
          }
          return Container();
        },
      );
    }
    if (day == "tomorrow") {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('DoctorMeets')
            .where('finished', isEqualTo: 'false')
            .where('payment', isEqualTo: 'completed')
            .where('meetTime',
                isGreaterThan: Timestamp.fromDate(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ).add(Duration(days: 1))))
            .where('meetTime',
                isLessThanOrEqualTo: Timestamp.fromDate(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ).add(Duration(days: 2))))
            .orderBy('meetTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else {
            if (snapshot.hasData) {
              List meets = snapshot.data!.docs
                  .where((element) => DateTime.now().isBefore(
                      (element['meetTime'] as Timestamp)
                          .toDate()
                          .add(Duration(hours: 1))))
                  .toList();

              return meets.length > 0
                  ? ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: meets.length,
                      itemBuilder: (context, index) => _doctorChatCard(
                          id: meets[index]['userId'],
                          meetTime:
                              (meets[index]['meetTime'] as Timestamp).toDate(),
                          meetId: meets[index]['meetId'].toString(),
                          name: meets[index]['userName'],
                          photo: meets[index]['userPhoto']),
                    )
                  : Center(
                      child: CustomText(text: "noSessions".tr, fontSize: 14));
            }
          }
          return Center(child: CustomText(text: "noSessions".tr, fontSize: 14));
        },
      );
    }
    if (day == "after tomorrow") {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('DoctorMeets')
            .where('finished', isEqualTo: 'false')
            .where('payment', isEqualTo: 'completed')
            .where('meetTime',
                isGreaterThan: Timestamp.fromDate(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ).add(Duration(days: 2))))
            .where('meetTime',
                isLessThanOrEqualTo: Timestamp.fromDate(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ).add(Duration(days: 3))))
            .orderBy('meetTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else {
            if (snapshot.hasData) {
              List meets = snapshot.data!.docs
                  .where((element) => DateTime.now().isBefore(
                      (element['meetTime'] as Timestamp)
                          .toDate()
                          .add(Duration(hours: 1))))
                  .toList();

              return meets.length > 0
                  ? ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: meets.length,
                      itemBuilder: (context, index) => _doctorChatCard(
                          id: meets[index]['userId'],
                          meetTime:
                              (meets[index]['meetTime'] as Timestamp).toDate(),
                          meetId: meets[index]['meetId'].toString(),
                          name: meets[index]['userName'],
                          photo: meets[index]['userPhoto']),
                    )
                  : Center(
                      child: CustomText(text: "noSessions".tr, fontSize: 14));
            }
          }
          return Center(child: CustomText(text: "noSessions".tr, fontSize: 14));
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _doctorChatCard(
      {required DateTime meetTime,
      required String id,
      required String name,
      required String photo,
      required String meetId}) {
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
                          imageUrl: photo,
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
                    text: name,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(
                    width: 156.8.w,
                    child: CustomText(
                      text:
                          "${"sessionTime".tr}: ${DateFormat.jm().format(meetTime)}",
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      fontSize: 13,
                      color: AppColors.black3,
                    ),
                  )
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
              onPressed: () =>
                  (meetTime.difference(DateTime.now()).inMinutes <= 5 &&
                          meetTime.difference(DateTime.now()).inMinutes > -50)
                      ? Get.to(
                          ChatPage(
                              isDoctor: true,
                              friendName: name,
                              friendId: id,
                              meetTime: meetTime,
                              friendPhoto: photo,
                              meetId: meetId),
                        )
                      : meetTime.difference(DateTime.now()).inMinutes <= -50
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
