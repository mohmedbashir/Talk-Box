import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/widgets/custom_text.dart';

class Helper {
  static customSnakBar(
      {required String title,
      bool? success,
      required String message,
      Color backgroundClr = Colors.white}) {
    return Get.snackbar('title', 'message',
        icon: success != null
            ? success
                ? Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Image.asset(AppAssets.successIcon))
                : Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Image.asset(AppAssets.wrongIcon))
            : Icon(Icons.priority_high_rounded),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        backgroundColor: backgroundClr.withOpacity(.2),
        colorText: Colors.white,
        titleText: CustomText(
          text: title,
          color: backgroundClr == Colors.white ? Colors.black : Colors.black,
          fontSize: 15,
        ),
        messageText: CustomText(
          text: message,
          color: backgroundClr == Colors.white ? Colors.black : Colors.black,
          fontSize: 12,
        ),
        snackStyle: SnackStyle.FLOATING);
  }

  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${"ago".tr} $years ${"year".tr}${years == 1 ? '' : ''} ';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${"ago".tr} $months ${"month".tr}${months == 1 ? '' : ''} ';
    } else if (difference.inDays > 0) {
      return '${"ago".tr} ${difference.inDays} ${"day".tr}${difference.inDays == 1 ? '' : ''} ';
    } else if (difference.inHours > 0) {
      return '${"ago".tr} ${difference.inHours} ${"hour".tr}${difference.inHours == 1 ? '' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${"ago".tr} ${difference.inMinutes} ${"minutes".tr}${difference.inMinutes == 1 ? '' : ''} ';
    } else {
      return "now".tr;
    }
  }

  static dateTimeIntoRemainingTime({required DateTime dateTime}) {
    Duration remainingTime = dateTime.difference(DateTime.now());

    String formattedTime = remainingTime.inHours > 0
        ? '${remainingTime.inHours} ${"hour".tr} ${remainingTime.inMinutes.remainder(60)} ${"minutes".tr}.'
        : '${remainingTime.inMinutes.remainder(60)} ${"minutes".tr}.';

    return formattedTime;
  }
}
