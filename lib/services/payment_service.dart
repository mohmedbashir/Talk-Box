import 'dart:convert';
import 'dart:io';

// import 'package:android_intent_plus/android_intent.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as GetPackage;
import 'package:talk_box/controllers/app_controller.dart';

import '../utils/api_client.dart';
import '../utils/constants.dart';
import '../utils/helper.dart';
import '../view/internal page/payment_page.dart';

class PaymentService {
  static Future<void> createPaymentProcess(String meetId, String userId,
      String userPhone, String userFullName, String userEmail) async {
    var body = {
      "pageCode": AppConstants.MESHULAM_PAGE_CODE,
      "userId": AppConstants.MESHULAM_USER_ID,
      "sum": await AppController.getAppLinks(neddedLink: 'meetPrice') as String,
      "successUrl": AppConstants.MESHULAM_SUCCESS_URL,
      "cField1": userId,
      "cField2": meetId,
      "pageField[phone]": userPhone,
      "pageField[fullName]": userFullName,
      "pageField[email]": userEmail
    };
    /*   var body = {
      "pageCode": AppConstants.MESHULAM_PAGE_CODE_Test,
      "userId": AppConstants.MESHULAM_USER_ID_Test,
      "sum": "1",
      "successUrl": AppConstants.MESHULAM_SUCCESS_URL,
      "cField1": userId,
      "cField2": meetId,
      "pageField[phone]": "0592901480",
      "pageField[fullName]": "mo test",
      "pageField[email]": "kk1123686@gmail.com"
    }; */

    ApiClient apiClient = ApiClient(Dio());
    apiClient.init();
    final response = await apiClient.post(
      "createPaymentProcess",
      body: FormData.fromMap(body),
    );

    final rBody = jsonDecode(response?.data);
    if (response?.statusCode == 200) {
      if (rBody != null && rBody["status"] == 1 && rBody["data"] != null) {
        print("${rBody["data"]["url"]}");
        Uri url = Uri.parse(rBody["data"]["url"]);
        print("url is $url");
        GetPackage.Get.to(() => PaymentPage(url: rBody["data"]["url"]));
      }
    } else {
      // Error occurred
      Helper.customSnakBar(
        title: 'خطأ',
        success: false,
        message: '${rBody["err"]["message"]}ً',
      );
    }
  }

  // static void closeWindow() {
  //   if (Platform.isAndroid) {
  //     AndroidIntent intent = const AndroidIntent(
  //       action: 'android.intent.action.CLOSE_SYSTEM_DIALOGS',
  //     );
  //     intent.launch();
  //   }
  // }
}
