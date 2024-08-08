import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/firebase_options.dart';
import 'package:talk_box/services/notification_service.dart';
import 'package:talk_box/utils/bindings.dart';
import 'package:talk_box/utils/locale.dart';

import 'package:talk_box/utils/theme.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/incoming_call.dart';

import 'utils/constants.dart';
import 'view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  NotificationService.firebaseMessageingInitialze();
  AppController().onInit();
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'high_importance_channel',
      channelName: 'high_importance_channel',
      channelDescription: 'high_importance_channel',
      // defaultColor: AppColors.primaryClr,
      // icon: 'assets/appIcon/appIcon.png',
      importance: NotificationImportance.Max,
      channelShowBadge: true,
      locked: true,
      defaultRingtoneType: DefaultRingtoneType.Notification,
    )
  ]);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification!.title == 'Call Notification') {
      print(message.notification!.title);
      Get.dialog(IncomingCall(
          callType: message.data["callType"],
          callerName: message.data["friendName"],
          callerPhoto: message.data["friendPhoto"],
          // recipientId: message.data["friendPhoto"],
          chatId: message.data["chatId"],
          meetingId: message.data["meetingId"]));
    }

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthController _authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 824.7272727272727),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        initialBinding: AppBindings(),
        translations: MyLocale(),
        locale: Get.deviceLocale,
        theme: Themes.theme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
