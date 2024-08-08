import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/video_sdk/meeting_screen.dart';
import 'package:talk_box/view/widgets/custom_text.dart';

class IncomingCall extends StatefulWidget {
  const IncomingCall({
    super.key,
    required this.callType,
    required this.callerName,
    required this.callerPhoto,
    // required this.recipientId,
    required this.chatId,
    required this.meetingId,
  });
  final String callType;
  final String callerName;
  final String callerPhoto;
  // final String recipientId;
  final String chatId;
  final String meetingId;
  @override
  State<IncomingCall> createState() => _IncomingCallState();
}

class _IncomingCallState extends State<IncomingCall> {
  final audioPlayer = AudioPlayer();
  playRingtone() async {
    await audioPlayer.play(AssetSource("voices/incoming-call-ringtone.wav"));
  }

  Timer? timer;
  checkAnswer() {
    timer = Timer(Duration(seconds: 20), () {
      if (mounted) {
        audioPlayer.stop();
        Get.back();
      }
    });
  }

  @override
  void initState() {
    playRingtone();
    checkAnswer();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(15),
        height: 260.h,
        width: 240.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomText(
                text: widget.callType == 'video call'
                    ? "incomingVideoCall".tr
                    : "incomingVoiceCall".tr,
                fontSize: 16),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                backgroundColor: AppColors.secondaryClr.withOpacity(.6),
                radius: 40.sp,
                child: CircleAvatar(
                    backgroundColor: AppColors.white,
                    radius: 39.sp,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.callerPhoto,
                        height: 75.h,
                      ),
                    )),
              ),
            ),
            CustomText(text: widget.callerName),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Colors.green,
                    onPressed: () async {
                      final token = await AppController.getAppLinks(
                          neddedLink: 'videoSDKToken');
                      audioPlayer.stop();
                      Get.back();
                      try {
                        Get.to(
                          MeetingScreen(
                            meetingId: widget.meetingId,
                            isVideoCall: widget.callType == 'video call',
                            chatId: widget.chatId,
                            token: token,
                          ),
                        );
                      } on Exception catch (e) {
                        print(e);
                      }
                    },
                    child: CustomText(
                        text: "join".tr, fontSize: 14, color: Colors.white)),
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Colors.red,
                    onPressed: () {
                      audioPlayer.stop();
                      Get.back();
                    },
                    child: CustomText(
                        text: "cancel".tr, fontSize: 14, color: Colors.white)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
