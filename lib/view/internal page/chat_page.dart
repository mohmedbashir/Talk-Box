import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/appintment_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/controllers/chat_controller.dart';
import 'package:talk_box/controllers/home_controller.dart';
import 'package:talk_box/services/generate_call_token.dart';
import 'package:talk_box/services/user_services.dart';
import 'package:talk_box/services/voice_recoder.dart';

import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/utils/helper.dart';
import 'package:talk_box/video_sdk/meeting_screen.dart';
import 'package:talk_box/view/home/account_page.dart';
import 'package:talk_box/view/home/doctor/doctor_interface.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/friend_message_bubble.dart';
import 'package:talk_box/view/widgets/my_message_bubble.dart';
import 'package:talk_box/view/widgets/voice_message.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../models/message_model.dart';

class ChatPage extends StatefulWidget with WidgetsBindingObserver {
  const ChatPage(
      {super.key,
      required this.friendName,
      required this.friendPhoto,
      required this.friendId,
      this.meetId,
      this.meetTime,
      this.isDoctor = false});

  final String friendName;
  final String friendPhoto;
  final String friendId;
  final bool isDoctor;
  final String? meetId;
  final DateTime? meetTime;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  AppController appController = Get.put(AppController());
  AuthController authController = Get.put(AuthController());
  ChatController chatController = Get.put(ChatController());
  AppointementController appointementController =
      Get.put(AppointementController());

  bool keyBoardEnabeld = true;

  void scheduleEndChatActions() {
    if (widget.meetTime != null) {
      print(widget.meetTime);
      final now = DateTime.now();
      final difference = widget.meetTime!.difference(now);
      final closeChatDuration = difference + const Duration(minutes: 50);
      final sendAlertDuratoin = closeChatDuration - const Duration(minutes: 5);
      print(closeChatDuration);
      print(sendAlertDuratoin);

      if (closeChatDuration.isNegative) return;

      Timer(
          sendAlertDuratoin,
          () => Helper.customSnakBar(
              title: "sessionWillFinishAfter5Minutes".tr,
              message: "sessionWillFinishAfter5Minutes2".tr));
      Timer(closeChatDuration, () {
        setState(() {
          keyBoardEnabeld = false;
        });
        appointementController.endMeet(meetId: widget.meetId!);
        Get.back();
      });
    }
  }

  @override
  void initState() {
    if (mounted) {
      scheduleEndChatActions();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List ids = [appController.currentUser.uId, widget.friendId]..sort();
    String chatId = ids.toString();

    return Scaffold(
      extendBody: false,
      /*  floatingActionButton:
          CustomFAB(scrollController: chatController.listScrollController), */
      appBar: CustomAppBar(chatId),
      body: Column(children: [
        Expanded(
          child: StreamBuilder(
              stream: chatController.getChatMessages(chatId: chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive(
                    strokeWidth: 1.5,
                  ));
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: CustomText(
                    text: "noMessages".tr,
                    fontSize: 14,
                  ));
                } else {
                  List<QueryDocumentSnapshot> chatMessageQuery =
                      snapshot.data!.docs;
                  List<MessageModel> chatMessages = [];
                  print(chatMessageQuery[0].runtimeType);
                  for (var element in chatMessageQuery) {
                    chatMessages.add(MessageModel.fromJson(
                        element.data() as Map<String, dynamic>));
                  }

                  return ListView.builder(
                    reverse: true,
                    controller: chatController.listScrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: chatMessageQuery.length,
                    itemBuilder: (context, index) {
                      if (chatMessages[index].senderId ==
                          appController.currentUser.uId) {
                        return MyMessageBubble(
                            chatId: chatId,
                            msgId: chatMessages[index].msgId ?? '',
                            text: chatMessages[index].text ?? '',
                            time: chatMessages[index].sendAt != null
                                ? DateFormat.jm()
                                    .format(((chatMessages[index].sendAt
                                            as Timestamp)
                                        .toDate()))
                                    .toString()
                                : '',
                            messageType: chatMessages[index].type!);
                      }
                      if (chatMessages[index].reciverId ==
                          appController.currentUser.uId) {
                        return FriendMessageBubble(
                            text: chatMessages[index].text ?? '',
                            time: chatMessages[index].sendAt != null
                                ? DateFormat.jm()
                                    .format(((chatMessages[index].sendAt
                                            as Timestamp)
                                        .toDate()))
                                    .toString()
                                : '',
                            chatId: chatId,
                            messageType: chatMessages[index].type!);
                      }
                      return null;
                    },
                  );
                }
              }),
        ),
        keyBoardEnabeld ? _sendMessage() : SizedBox.shrink()
      ]),
    );
  }

  AppBar CustomAppBar(String chatId) {
    return AppBar(
      actionsIconTheme: IconThemeData(size: 26),
      titleSpacing: 0,
      elevation: 1,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(15),
              bottomLeft: Radius.circular(15))),
      leading: IconButton(
          icon: Icon(
            widget.isDoctor
                ? Icons.close_rounded
                : Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
          onPressed: () => widget.isDoctor
              ? Get.dialog(closeChat(appointementController, widget.meetId!))
              : Get.back()),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondaryClr,
            radius: 21.sp,
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              radius: 20.sp,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl:
                      (widget.meetTime != null && widget.isDoctor == false)
                          ? appController.doctorInfo["doctorPhoto"]
                          : widget.friendPhoto,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            constraints: BoxConstraints(maxWidth: 150.w),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                    text: widget.friendName,
                    textAlign: TextAlign.start,
                    fontSize: 17,
                    maxLines: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: ((widget.meetTime != null && widget.isDoctor) ||
              widget.meetTime == null)
          ? [
              IconButton(
                  tooltip: 'Voice Call',
                  onPressed: () async {
                    String meetId = await onCreateButtonPressed(
                        meetId: widget.meetId,
                        meetTime: widget.meetTime,
                        isDoctor: widget.isDoctor,
                        context: context,
                        isVideoCall: false,
                        chatId: chatId);
                    chatController.messageController.text = meetId;
                    chatController.sendMessage(
                        friendId: widget.friendId,
                        friendPhoto: widget.friendPhoto,
                        friendname: widget.friendName,
                        messageType: 'voice call');
                  },
                  icon: const Icon(
                    Icons.call_rounded,
                    color: Colors.black,
                  )),
              IconButton(
                  tooltip: 'Video Call',
                  onPressed: () async {
                    String meetId = await onCreateButtonPressed(
                        meetId: widget.meetId,
                        isDoctor: widget.isDoctor,
                        meetTime: widget.meetTime,
                        context: context,
                        isVideoCall: true,
                        chatId: chatId);

                    chatController.messageController.text = meetId;
                    chatController.sendMessage(
                        friendId: widget.friendId,
                        friendPhoto: widget.friendPhoto,
                        friendname: widget.friendName,
                        messageType: 'video call');
                  },
                  icon:
                      const Icon(Icons.videocam_rounded, color: Colors.black)),
              const SizedBox(width: 10)
            ]
          : null,
    );
  }

  Widget _sendMessage() {
    return GetBuilder<ChatController>(
      builder: (controller) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                  offset: Offset(-1, -1),
                  blurRadius: 5,
                  color: AppColors.black1)
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            child: Container(
              color: AppColors.white,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      onPressed: () => attachButton(),
                      shape: CircleBorder(),
                      height: 50.w,
                      minWidth: 50.w,
                      splashColor: AppColors.black1,
                      elevation: 0,
                      disabledElevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      color: AppColors.white,
                      child: Icon(
                        Icons.attach_file_outlined,
                        size: 30.sp,
                        color: AppColors.secondaryClr,
                      ),
                    ),
                    // RecordVideoButton(),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: AppColors.borderClr, width: 1.5)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: TextFormField(
                              // autofocus: false,
                              scrollPadding: EdgeInsets.all(0),
                              controller: chatController.messageController,
                              cursorWidth: 1,
                              cursorHeight: 20,
                              maxLines: 3,
                              minLines: 1,
                              style: GoogleFonts.alexandria(
                                  fontSize: 17, color: AppColors.black),
                              decoration: InputDecoration(
                                  enabled: chatController.textFieldHint ==
                                      "sendmessage".tr,
                                  contentPadding: EdgeInsets.all(10),
                                  filled: true,
                                  fillColor: AppColors.white,
                                  hintText: chatController
                                      .textFieldHint /* "sendmessage".tr */,
                                  hintStyle: GoogleFonts.alexandria(
                                      fontSize: 17, color: AppColors.black2),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none))),
                        ),
                      ),
                    ),
                    if (chatController.isTextMessage)
                      MaterialButton(
                        height: 50.w,
                        minWidth: 50.w,
                        shape: CircleBorder(),
                        color: AppColors.secondaryClr,
                        onPressed: () async {
                          chatController.sendMessage(
                              friendId: widget.friendId,
                              friendPhoto: widget.friendPhoto,
                              friendname: widget.friendName,
                              messageType: 'text');
                        },
                        child:
                            Icon(Icons.send, color: Colors.white, size: 32.sp),
                      ),

                    if (!chatController.isTextMessage)
                      VoiceRecordButton(
                          friendId: widget.friendId,
                          friendname: widget.friendName,
                          friendPhoto: widget.friendPhoto),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Future<dynamic> attachButton() {
    return Get.bottomSheet(Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          )),
      height: Get.height * .14,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MaterialButton(
              onPressed: () async {
                Get.back();
                await chatController.sendMedia(
                    messageType: 'photo',
                    friendId: widget.friendId,
                    friendPhoto: widget.friendPhoto,
                    friendname: widget.friendName);
                // _showLoadingDialog(context, chatController);
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.photo_library_outlined,
                        color: Colors.black87, size: 25.sp),
                    SizedBox(width: 10),
                    CustomText(text: "choosePic".tr, fontSize: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(height: 1, color: Colors.black12),
            ),
            MaterialButton(
              onPressed: () async {
                Get.back();
                await chatController.sendMedia(
                    messageType: 'video',
                    friendId: widget.friendId,
                    friendPhoto: widget.friendPhoto,
                    friendname: widget.friendName);
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.video_library_outlined,
                        color: Colors.black87, size: 25.sp),
                    SizedBox(width: 10),
                    CustomText(text: "chooseVid".tr, fontSize: 16),
                  ],
                ),
              ),
            ),
          ]),
    ));
  }
}

class RecordVideoButton extends StatefulWidget {
  const RecordVideoButton({
    super.key,
  });

  @override
  State<RecordVideoButton> createState() => _RecordVideoButtonState();
}

class _RecordVideoButtonState extends State<RecordVideoButton> {
  final recorder = VoiceRecorder();

  @override
  void initState() {
    recorder.init();
    super.initState();
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Material(
            elevation: 10,
            color: AppColors.white,
            child: InkWell(
              onLongPress: () async {
                /*   final player = AudioPlayer();
                player.play(AssetSource('assets/voices/notification.mp3')); */
              },
              child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: Padding(
                    padding: EdgeInsets.only(right: 5, top: 1),
                    child: Icon(
                      Icons.mic_none_rounded,
                      size: 30.sp,
                      color: AppColors.secondaryClr,
                    ),
                  )),
            ),
          ),
        ),
        ClipOval(
          child: Material(
            elevation: 10,
            color: AppColors.white,
            child: InkWell(
              onLongPress: () async {
                /*   final player = AudioPlayer();
                player.play(AssetSource('assets/voices/notification.mp3')); */
              },
              child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: Padding(
                    padding: EdgeInsets.only(right: 5, top: 1),
                    child: Icon(
                      Icons.mic_none_rounded,
                      size: 30.sp,
                      color: AppColors.secondaryClr,
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> sendPushNotification(
    {required String to, required String title, required String body}) async {
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
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': const Uuid().v4(),
            'status': 'done'
          },
          'to': to,
        },
      ),
    );
    response;
  } catch (e) {
    e;
  }
}

Center closeChat(AppointementController appointementController, String meetId) {
  return Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        color: Colors.white,
        height: 140.h,
        width: 313.6.w,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const CustomText(
                  textAlign: TextAlign.center,
                  text: 'هل تريد إنهاء هذه الجلسة ؟',
                  fontSize: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: MaterialButton(
                        height: 50,
                        onPressed: () async {
                          final doctorinfo = {
                            "doctorPhoto": await AppController.getAppLinks(
                                neddedLink: 'doctorInfo', key: 'doctorPhoto'),
                            "doctorName": await AppController.getAppLinks(
                                neddedLink: 'doctorInfo', key: 'doctorName'),
                            "id": await AppController.getAppLinks(
                                neddedLink: 'doctorInfo', key: 'id'),
                            "cv": await AppController.getAppLinks(
                                neddedLink: 'doctorInfo', key: 'cv'),
                          };
                          appointementController.endMeet(meetId: meetId);
                          Get.off(DoctorInterface());
                        },
                        child: CustomText(
                          text: "yes".tr,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(color: Colors.black12, height: 35, width: 1),
                    Expanded(
                      child: MaterialButton(
                        height: 50,
                        onPressed: () => Get.back(),
                        child: CustomText(
                          text: "no".tr,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                )
              ]),
        ),
      ),
    ),
  );
}

onCreateButtonPressed(
    {required BuildContext context,
    required bool isVideoCall,
    String? meetId,
    DateTime? meetTime,
    bool isDoctor = false,
    required String chatId}) async {
  String? meetId;
  await createMeeting().then((meetingId) async {
    final token = await AppController.getAppLinks(neddedLink: 'videoSDKToken');
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeetingScreen(
          meetingId: meetingId,
          isVideoCall: isVideoCall,
          meetId: meetingId,
          meetTime: meetTime,
          chatId: chatId,
          token: token,
        ),
      ),
    );
    meetId = meetingId;
    print(meetId);
  });
  return meetId;
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
          'body': 'From $currentUserName',
          'title': '1',
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
