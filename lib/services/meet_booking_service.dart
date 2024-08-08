import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/models/user_model.dart';
import 'package:talk_box/services/notification_service.dart';
import 'package:talk_box/services/payment_service.dart';
import 'package:talk_box/services/user_services.dart';

import 'package:talk_box/utils/helper.dart';
import 'package:talk_box/view/widgets/custom_button.dart';
import 'package:talk_box/view/widgets/custom_text_form_field.dart';
import 'package:uuid/uuid.dart';

class MeetsService {
  final CollectionReference<Map<String, dynamic>> doctorMeetsRef =
      FirebaseFirestore.instance.collection('DoctorMeets');
  final AppController appController = Get.put(AppController());
  Future bookaMeet(
      {required DateTime selectedDate, required UserModel currentUser}) async {
    if (await checkIfUserHasBookInSameDay(
        selectedDate: selectedDate, currentUserId: currentUser.uId!)) {
      Helper.customSnakBar(
          title: "invalidBooking1".tr,
          success: false,
          message: "invalidBooking12".tr);
      return;
    } else {
      if (!isAppointmentAllowed(selectedDate)) {
        Helper.customSnakBar(
            title: "invalidBooking2".tr,
            success: false,
            message: "invalidBooking22".tr);
        return;
      }
      if (await checkAvailabilityOfSelectedDate(selectedDate: selectedDate)) {
        Helper.customSnakBar(
            title: "invalidBooking3".tr,
            success: false,
            message: "invalidBooking32".tr);
        return;
      }
      final GlobalKey<FormState> phoneNumberTextFieldKey =
          GlobalKey<FormState>();
      final TextEditingController phoneNumberController =
          TextEditingController();
      Get.bottomSheet(ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        child: Container(
          height: 200.h,
          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
          color: Colors.white,
          child: Column(
            children: [
              Form(
                key: phoneNumberTextFieldKey,
                child: CustomTextFormField(
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone,
                  hintText: "phoneNumberHint".tr,
                  label: "phoneNumber".tr,
                  controller: phoneNumberController,
                  validator: (value) {
                    if (value == null) {
                      return "requiredField".tr;
                    } else if (value.length < 10) {
                      return "enterCorrectPhoneNumber".tr;
                    }
                    return null;
                  },
                ),
              ),
              CustomButton(
                  onTap: () async {
                    phoneNumberTextFieldKey.currentState!.save();
                    if (phoneNumberTextFieldKey.currentState!.validate()) {
                      final String meetId = const Uuid().v4();
                      await doctorMeetsRef.doc(meetId).set({
                        "meetId": meetId,
                        "userName": currentUser.name,
                        "userId": currentUser.uId,
                        "userPhoto": currentUser.avatarUrl,
                        "payment": "inProgress",
                        "finished": "false",
                        "bookingTime": Timestamp.now(),
                        "meetTime": selectedDate
                      });
                      Get.back();
                      print("start payment");
                      PaymentService.createPaymentProcess(
                          meetId,
                          currentUser.uId!,
                          phoneNumberController.text,
                          currentUser.name!,
                          currentUser.email!);

                      print("end payment");
                    }
                    print(appController.doctorInfo["id"]);
                    print("Hi");
                    await NotificationService.sendPushNotification(
                        to: await UserFirebaseServices().getFriendFcm(
                            friendUid: appController.doctorInfo["id"]),
                        title: "There is a new reservation",
                        body:
                            "${currentUser.name} booked a new session on ${DateFormat.yMMMMEEEEd().format(selectedDate)} at ${DateFormat.j().format(selectedDate)}");
                    await NotificationService.scheduleNotification(
                        title: 'You have a session with a psychologist',
                        body:
                            'less than 10 minutes left until the start of the session, be close so you don\'t miss it',
                        scheduled: NotificationCalendar.fromDate(
                            date:
                                selectedDate.subtract(Duration(minutes: 10))));
                  },
                  label: "goToPaymentpage".tr)
            ],
          ),
        ),
      ));
      /*     final String meetId = const Uuid().v4();
      await doctorMeetsRef.doc(meetId).set({
        "meetId": meetId,
        "userName": currentUser.name,
        "userId": currentUser.uId,
        "userPhoto": currentUser.avatarUrl,
        "payment": "inProgress",
        "finished": "false",
        "bookingTime": Timestamp.now(),
        "meetTime": selectedDate
      });

      print("start payment");
      PaymentService.createPaymentProcess(meetId, currentUser.uId!,
          "0592901480", currentUser.name!, currentUser.email!);
      print("end payment");

       */
    }
  }

  Future<bool> checkAvailabilityOfSelectedDate(
      {required DateTime selectedDate}) async {
    final meetRef = doctorMeetsRef
        .where("meetTime", isEqualTo: selectedDate)
        .where('payment', isEqualTo: 'completed');
    final snapShot = await meetRef.get();
    return snapShot.docs.isNotEmpty;
  }

  Future<bool> checkIfUserHasBookInSameDay(
      {required DateTime selectedDate, required String currentUserId}) async {
    final DateTime startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final DateTime endOfDay = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    final meetRef = doctorMeetsRef
        .where('userId', isEqualTo: currentUserId)
        .where("meetTime", isGreaterThanOrEqualTo: startOfDay)
        .where('payment', isEqualTo: 'completed')
        .where("meetTime", isLessThanOrEqualTo: endOfDay);
    final snapShot = await meetRef.get();
    return snapShot.docs.isNotEmpty;
  }

  bool isAppointmentAllowed(DateTime selectedDate) {
    // if (selectedDate.weekday == DateTime.friday) {
    //   return false;
    // }

    final startTime = TimeOfDay(hour: 9, minute: 0);
    final endTime = TimeOfDay(hour: 21, minute: 0);

    final selectedTime = TimeOfDay.fromDateTime(selectedDate);

    if (selectedTime.hour < startTime.hour ||
        selectedTime.hour > endTime.hour) {
      return false;
    }

    return true;
  }

  endMeet({required String meetId}) async {
    doctorMeetsRef.doc(meetId).update({'finished': 'true'});
  }
}
