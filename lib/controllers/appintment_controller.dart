import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/services/meet_booking_service.dart';

class AppointementController extends GetxController {
  AppController appController = Get.put(AppController());

  String? meetPrice;
  @override
  void onInit() async {
    meetPrice =
        await AppController.getAppLinks(neddedLink: 'meetPrice') as String;
    super.onInit();
  }

  MeetsService meetsService = MeetsService();
  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
  );
  updateDateTime(DateTime newDateTime) {
    selectedDate = newDateTime;
    update();
  }

  bool bookingLoading = false;

  bool _doctorPoliciesCheckBoxValue = false;
  bool get doctorPoliciesCheckBoxValue => _doctorPoliciesCheckBoxValue;

  checkBoxOnTap(bool value) {
    _doctorPoliciesCheckBoxValue = value;
    update();
  }

  bookAMeet() async {
    bookingLoading = true;
    update();
    await meetsService.bookaMeet(
        selectedDate: selectedDate, currentUser: appController.currentUser);
    bookingLoading = false;
    update();
  }

  endMeet({required String meetId}) async {
    await meetsService.endMeet(meetId: meetId);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMeetOfToday() {
    return FirebaseFirestore.instance
        .collection('DoctorMeets')
        .where('userId', isEqualTo: appController.currentUser.uId)
        .where('finished', isEqualTo: 'false')
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
            ).add(const Duration(days: 1))))
        .where('payment', isEqualTo: 'completed')
        .orderBy('meetTime')
        .limit(1)
        .snapshots();
  }
}
