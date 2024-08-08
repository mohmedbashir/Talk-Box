import 'dart:convert';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:talk_box/utils/constants.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future initialize() async {
    // Request permission for receiving notifications
    await _firebaseMessaging.requestPermission();

    // Configure the app to handle incoming notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the incoming message when the app is in the foreground
      print('Message received: ${message.notification?.title}');
    });

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> sendPushNotification(
      {required String to,
      required String title,
      required String body,
      String? type}) async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAmBT-uK0:APA91bF4ID_Wi6sTBhuW3BJKngXg7DOJpinV5MulRW7Sz2IcKF6PN7d23ZZGfidfXX09NTqYlxiC3TemB2vM9tkP88tpsaH87V90qvp9V0uvuzoLtOZvWATRqiV36RP803T6fu0SyCtG',
        },
        body: jsonEncode(
          <String, dynamic>{
            'id': "asdsad",
            'to': to,
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'action': "reply",
              'title': title,
              'type': '$type',
              "priority": "high"
            },
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }

  static firebaseMessageingInitialze() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        announcement: true,
        provisional: false,
        carPlay: false,
        criticalAlert: false,
        sound: true);
  }

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: AppColors.secondaryClr,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupkey: 'high_importance_channel_group',
          // channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    /*  await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    ); */
  }

/*   /// Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // debugPrint('onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == "true") {
      /*    MainApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const SecondScreen(),
        ),
      ); */
    }
  } */

  static Future<void> scheduleNotification({
    required final String title,
    required final String body,
    required NotificationSchedule? scheduled,
  }) async {
    // assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: 'high_importance_channel',
          title: title,
          body: body,
        ),
        schedule: scheduled);
  }
}
