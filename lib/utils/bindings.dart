import 'package:get/get.dart';
import 'package:talk_box/controllers/appintment_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/home_controller.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => AppController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => AppointementController());
    // Get.lazyPut(() => NotificationController());
  }
}
