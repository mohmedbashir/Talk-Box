import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/video_sdk/meeting_screen.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/video_player.dart';
import 'package:talk_box/view/widgets/voice_message.dart';
import 'package:talk_box/view/widgets/voice_message_bubble.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:ui' as ui;
import '../../utils/constants.dart';

class FriendMessageBubble extends StatefulWidget {
  FriendMessageBubble(
      {super.key,
      required this.text,
      required this.time,
      required this.messageType,
      required this.chatId});

  final String text;
  final String time;
  final String messageType;
  final String chatId;

  @override
  State<FriendMessageBubble> createState() => _FriendMessageBubbleState();
}

class _FriendMessageBubbleState extends State<FriendMessageBubble> {
  @override
  void initState() {
    if (widget.messageType == 'video' && _thumbnailUrl == null) {
      generateThumbnail();
    }

    super.initState();
  }

  String? _thumbnailUrl;
  getThumnail() async {}
  Future generateThumbnail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _thumbnailUrl = prefs.getString(widget.text);
    if (_thumbnailUrl == null) {
      _thumbnailUrl = await VideoThumbnail.thumbnailFile(
          quality: 30,
          video: widget.text,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.WEBP);
      prefs.setString(widget.text, _thumbnailUrl!);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.messageType == 'photo'
        ? Directionality(
            textDirection: Get.locale.toString().contains("en")
                ? TextDirection.rtl
                : TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _messageSendTimeWidget(widget.time),
                BubbleNormalImage(
                  image: CachedNetworkImage(imageUrl: widget.text),
                  id: const Uuid().v4(),
                  color: AppColors.secondaryClr,
                  tail: false,
                  isSender: false,
                ),
              ],
            ),
          )
        : widget.messageType == 'video'
            ? Directionality(
                textDirection: Get.locale.toString().contains("en")
                    ? TextDirection.rtl
                    : TextDirection.rtl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _messageSendTimeWidget(widget.time),
                    BubbleNormalImage(
                      onTap: () => Get.to(VideoPlayerView(url: widget.text)),
                      image: _thumbnailUrl != null
                          ? Stack(children: [
                              Image.file(File(_thumbnailUrl!),
                                  fit: BoxFit.cover),
                              GestureDetector(
                                onTap: () {
                                  Get.to(VideoPlayerView(url: widget.text));
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                      color: AppColors.black.withOpacity(.4),
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 30.sp,
                                  ),
                                ),
                              )
                            ])
                          : const SizedBox(
                              width: 70,
                              height: 70,
                              child: Center(
                                  child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 1))),
                      id: const Uuid().v4(),
                      color: AppColors.secondaryClr,
                      tail: false,
                      isSender: false,
                    ),
                  ],
                ),
              )
            : widget.messageType == 'text'
                ? Directionality(
                    textDirection: Get.locale.toString().contains("en")
                        ? TextDirection.rtl
                        : TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _messageSendTimeWidget(widget.time),
                        BubbleSpecialOne(
                          textStyle: GoogleFonts.alexandria(
                              fontSize: 18.sp,
                              color: AppColors.black,
                              fontWeight: FontWeight.w300),
                          text: widget.text,
                          color: AppColors.secondaryClr,
                          tail: true,
                          isSender: false,
                        ),
                      ],
                    ),
                  )
                : widget.messageType == 'voice'
                    ? Directionality(
                        textDirection: Get.locale.toString().contains("en")
                            ? TextDirection.rtl
                            : TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _messageSendTimeWidget(widget.time),
                            VoiceMessageBubble(
                                audioFileUrl: widget.text, isSender: false)
                          ],
                        ),
                      )
                    : Container();
  }
}

void onJoinButtonPressed(
    {required String meetingId,
    required bool isVideoCall,
    required String chatId,
    required String token}) {
  try {
    Get.to(
      MeetingScreen(
        meetingId: meetingId,
        isVideoCall: isVideoCall,
        chatId: chatId,
        token: token,
      ),
    );
  } on Exception catch (e) {
    print(e);
  }
}

Future _deleteCallDocuments(String chatId) async {
  CollectionReference parentCollectionRef =
      FirebaseFirestore.instance.collection('Chats');
  final documentQuery = await parentCollectionRef
      .doc(chatId)
      .collection('Messages')
      .where('type', whereIn: ['video call', 'voice call']);
  final doc = await documentQuery.get().then((querySnapshot) {
    if (querySnapshot.size > 0) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    } else {
      print("No matching document found");
    }
  });
}

Padding _messageSendTimeWidget(String time) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 5),
    child: CustomText(
      text: time,
      fontSize: 11,
      color: AppColors.black3,
    ),
  );
}
