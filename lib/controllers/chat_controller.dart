import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/models/message_model.dart';
import 'package:talk_box/services/chat_service.dart';
import 'package:talk_box/services/notification_service.dart';
import 'package:talk_box/services/user_services.dart';
import 'package:talk_box/view/widgets/voice_message.dart';

import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    messageController.addListener(() {
      if ((messageController.text.replaceAll(' ', '')).isNotEmpty) {
        isTextMessage = true;
      } else {
        isTextMessage = false;
      }
      update();
    });
  }

  String textFieldHint = "sendmessage".tr;
  changeTextFieldHint() {
    if (textFieldHint == "sendmessage".tr) {
      textFieldHint = "recordAvoice".tr;
    } else {
      textFieldHint = "sendmessage".tr;
    }
    update();
  }

  bool isTextMessage = false;
  TextEditingController messageController = TextEditingController();
  AppController appController = Get.put(AppController());
  AuthController authController = Get.put(AuthController());
  ChatService chatService = ChatService();
  ScrollController listScrollController = ScrollController();
  final storage = FirebaseStorage.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatMessages(
      {required String chatId}) {
    final messagesCollectionRef = FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('Messages')
        .orderBy('sendAt', descending: true);

    return messagesCollectionRef.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChats() {
    final messagesCollectionRef = FirebaseFirestore.instance
        .collection('Chats')
        .orderBy('lastMessageTimestamp', descending: true);

    return messagesCollectionRef.snapshots();
  }

  Future<String> createNewChat(String user1Id, String user2Id,
      String user2Photo, String user2Name, String messageType) async {
    List ids = [user1Id, user2Id]..sort();
    String chatId = ids.toString();

    DocumentReference chatRef =
        FirebaseFirestore.instance.collection('Chats').doc(chatId);

    await chatRef.set({
      'lastMessage': messageType == 'text'
          ? messageController.text
          : messageType == 'photo'
              ? "photoHavebeenSent"
              : messageType == 'video'
                  ? "videoHavebeenSent"
                  : messageType == 'voice'
                      ? "voiceHavebeenSent"
                      : messageType == 'video call'
                          ? "videoCallInvitation"
                          : "voiceCallInvitation",
      'lastMessageTimestamp': Timestamp.now(),
      'lastMessageType': messageType,
      'lastMessageSenderId': authController.auth.currentUser!.uid,
      'user1Id': authController.auth.currentUser!.uid,
      'user1Photo':
          authController.auth.currentUser!.uid == appController.doctorInfo["id"]
              ? appController.doctorInfo["doctorPhoto"]
              : appController.currentUser.avatarUrl,
      'user1Name':
          authController.auth.currentUser!.uid == appController.doctorInfo["id"]
              ? appController.doctorInfo["doctorPhoto"]
              : appController.currentUser.name,
      'user2Id': user2Id,
      'user2Photo': user2Photo,
      'user2Name': user2Name,
    });
    return chatId;
  }

  Future sendMessage(
      {required String friendId,
      required friendPhoto,
      required String friendname,
      required String messageType,
      bool isMeet = false,
      String? mediaLink}) async {
    if (((messageType == 'text' &&
            messageController.text.replaceAll(' ', '').length > 0) ||
        messageType == 'photo' ||
        messageType == 'video' ||
        messageType == 'voice' ||
        messageType == 'video call' ||
        messageType == 'voice call')) {
      final messagesCollectionRef = FirebaseFirestore.instance
          .collection('Chats')
          .doc(await createNewChat(authController.auth.currentUser!.uid,
              friendId, friendPhoto, friendname, messageType))
          .collection('Messages');
      final message = MessageModel(
          text: messageType == 'text' ||
                  messageType == 'video call' ||
                  messageType == 'voice call'
              ? messageController.text
              : mediaLink,
          senderId: appController.currentUser.uId,
          msgId: Uuid().v4(),
          type: messageType,
          reciverId: friendId,
          sendAt: Timestamp.now());

      await messagesCollectionRef.doc().set(message.toJson());
      listScrollController.animateTo(
          listScrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.ease);

      if (messageType == 'video call' || messageType == 'voice call') {
        _sendCallAlert(
            messageType: messageType,
            currentUserName: appController.currentUser.name!,
            currentUserPhoto: appController.currentUser.avatarUrl!,
            friendId: friendId,
            chatId:
                ([appController.currentUser.uId, friendId]..sort()).toString(),
            meetingId: messageController.text);
      } else {
        NotificationService.sendPushNotification(
            title: "You have new messages",
            body: "Open Talk Box and discover it now",
            to: await UserFirebaseServices().getFriendFcm(friendUid: friendId));
      }
      messageController.clear();
    }
  }

  UploadTask? uploadTask;
  Future<void> sendMedia(
      {required String messageType,
      required String friendId,
      required String friendPhoto,
      required String friendname}) async {
    FilePickerResult? result;
    PlatformFile? platformFile;
    String? storyLink;
    result = await FilePicker.platform.pickFiles(
        type: messageType == 'photo' ? FileType.image : FileType.video);

    if (result != null) {
      platformFile = result.files.first;
      final file = File(platformFile.path!);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('Chats/${platformFile.name}');
      uploadTask = firebaseStorageRef.putFile(File(file.path));
      TaskSnapshot taskSnapshot =
          await uploadTask!.whenComplete(() => print('uploaded done'));
      storyLink = await taskSnapshot.ref.getDownloadURL();
      await sendMessage(
          messageType: messageType,
          friendId: friendId,
          friendPhoto: friendPhoto,
          friendname: friendname,
          mediaLink: storyLink);
      if (messageType == 'voice') {
        Get.back();
      }
      ;
    } else {}
  }

  Future deleteMessage({required String chatId, required messageId}) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('Messages')
        .where('msgId', isEqualTo: messageId)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final messageDocumentId = snapshot.docs[0].id;
      print(messageDocumentId);
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(chatId)
          .collection('Messages')
          .doc(messageDocumentId)
          .delete()
          .then((value) => print("successfully"));
    }
  }

  Future deleteChat({required String chatId}) async {
    await FirebaseFirestore.instance.collection('Chats').doc(chatId).delete();
    CollectionReference messagesCollection = FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('Messages');
    QuerySnapshot messagesSnapshot = await messagesCollection.get();
    messagesSnapshot.docs.forEach((messageDoc) {
      messageDoc.reference.delete();
    });
  }
}

_sendCallAlert(
    {required String messageType,
    required String currentUserName,
    required String currentUserPhoto,
    required String friendId,
    required String chatId,
    required String meetingId}) async {
  print("start");
  http.Response response = await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization':
          'key=AAAAmBT-uK0:APA91bF4ID_Wi6sTBhuW3BJKngXg7DOJpinV5MulRW7Sz2IcKF6PN7d23ZZGfidfXX09NTqYlxiC3TemB2vM9tkP88tpsaH87V90qvp9V0uvuzoLtOZvWATRqiV36RP803T6fu0SyCtG',
    },
    body: jsonEncode(
      <String, dynamic>{
        'to': await UserFirebaseServices().getFriendFcm(friendUid: friendId),
        'notification': <String, dynamic>{
          'body': 'You have call from $currentUserName',
          'title': 'Call Notification',
        },
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status': 'done',
          'callType': messageType,
          'meetingId': meetingId,
          'chatId': chatId,
          "friendPhoto": currentUserPhoto,
          "friendName": currentUserName
        },
      },
    ),
  );
  print("end");
}
