import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_box/controllers/chat_controller.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/video_player.dart';
import 'package:talk_box/view/widgets/voice_message.dart';
import 'package:talk_box/view/widgets/voice_message_bubble.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../utils/constants.dart';
import 'dart:ui' as ui;
// import '../../video_sdk/meeting_screen.dart';

class MyMessageBubble extends StatefulWidget {
  MyMessageBubble(
      {super.key,
      required this.text,
      required this.time,
      required this.messageType,
      required this.msgId,
      required this.chatId,
      this.onAgree});

  final String text;
  final String time;
  final String messageType;
  final String msgId;
  final String chatId;

  final Function()? onAgree;

  @override
  State<MyMessageBubble> createState() => _MyMessageBubbleState();
}

class _MyMessageBubbleState extends State<MyMessageBubble> {
  ChatController chatController = Get.put(ChatController());

  void initState() {
    if (widget.messageType == 'video' && _thumbnailUrl == null) {
      generateThumbnail();
    }

    super.initState();
    audioPlayer.onPlayerStateChanged.listen((state) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
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
    late Offset tapPosition;
    final overlay = Overlay.of(context).context.findRenderObject();
    return Get.locale.toString().contains("en")
        ? Directionality(
            textDirection: TextDirection.rtl,
            child: InkWell(
                onTapDown: (details) {
                  tapPosition = details.globalPosition;
                },
                onLongPress: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromRect(
                      tapPosition & Size(30, 20),
                      Offset.zero & overlay!.semanticBounds.size,
                    ),
                    items: [
                      PopupMenuItem(
                        onTap: () async {
                          chatController.deleteMessage(
                              chatId: widget.chatId, messageId: widget.msgId);
                          print(widget.msgId);
                        },
                        height: 20,
                        value: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomText(text: "deleteMsg".tr, fontSize: 16),
                        ),
                      ),
                    ],
                    elevation: 10,
                  ).then((value) {
                    if (value == 0) {
                      // deleteMessage(index);
                    }
                  });
                },
                child: widget.messageType == 'photo'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BubbleNormalImage(
                            image: CachedNetworkImage(imageUrl: widget.text),
                            id: const Uuid().v4(),
                            color: AppColors.borderClr,
                            tail: false,
                            isSender: false,
                          ),
                          _messageSendTimeWidget(widget.time),
                        ],
                      )
                    : widget.messageType == 'video'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              BubbleNormalImage(
                                onTap: () =>
                                    Get.to(VideoPlayerView(url: widget.text)),
                                image: _thumbnailUrl != null
                                    ? Stack(children: [
                                        Image.file(File(_thumbnailUrl!),
                                            fit: BoxFit.cover),
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(VideoPlayerView(
                                                url: widget.text));
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 5, top: 5),
                                            height: 30.w,
                                            width: 30.w,
                                            decoration: BoxDecoration(
                                                color: AppColors.black
                                                    .withOpacity(.4),
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        )
                                      ])
                                    : const SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Center(
                                            child: CircularProgressIndicator
                                                .adaptive(strokeWidth: 1))),
                                id: const Uuid().v4(),
                                color: AppColors.borderClr,
                                tail: false,
                                isSender: false,
                              ),
                              _messageSendTimeWidget(widget.time),
                            ],
                          )
                        : widget.messageType == 'text'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  BubbleSpecialOne(
                                    textStyle: GoogleFonts.alexandria(
                                        fontSize: 18.sp,
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w300),
                                    text: widget.text,
                                    color: AppColors.borderClr,
                                    tail: true,
                                    isSender: true,
                                  ),
                                  _messageSendTimeWidget(widget.time),
                                ],
                              )
                            : widget.messageType == 'voice'
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      VoiceMessageBubble(
                                          audioFileUrl: widget.text,
                                          isSender: true),
                                      _messageSendTimeWidget(widget.time),
                                    ],
                                  )
                                : Container()),
          )
        : InkWell(
            onTapDown: (details) {
              tapPosition = details.globalPosition;
            },
            onLongPress: () {
              showMenu(
                context: context,
                position: RelativeRect.fromRect(
                  tapPosition & Size(30, 20),
                  Offset.zero & overlay!.semanticBounds.size,
                ),
                items: [
                  PopupMenuItem(
                    onTap: () async {
                      chatController.deleteMessage(
                          chatId: widget.chatId, messageId: widget.msgId);
                      print(widget.msgId);
                    },
                    height: 20,
                    value: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomText(text: "deleteMsg".tr, fontSize: 16),
                    ),
                  ),
                ],
                elevation: 10,
              ).then((value) {
                if (value == 0) {
                  // deleteMessage(index);
                }
              });
            },
            child: widget.messageType == 'photo'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BubbleNormalImage(
                        image: CachedNetworkImage(imageUrl: widget.text),
                        id: const Uuid().v4(),
                        color: AppColors.borderClr,
                        tail: false,
                        isSender: false,
                      ),
                      _messageSendTimeWidget(widget.time),
                    ],
                  )
                : widget.messageType == 'video'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BubbleNormalImage(
                            onTap: () =>
                                Get.to(VideoPlayerView(url: widget.text)),
                            image: _thumbnailUrl != null
                                ? Stack(children: [
                                    Image.file(File(_thumbnailUrl!),
                                        fit: BoxFit.cover),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                            VideoPlayerView(url: widget.text));
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            right: 5, top: 5),
                                        height: 30.w,
                                        width: 30.w,
                                        decoration: BoxDecoration(
                                            color:
                                                AppColors.black.withOpacity(.4),
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    )
                                  ])
                                : const SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Center(
                                        child:
                                            CircularProgressIndicator.adaptive(
                                                strokeWidth: 1))),
                            id: const Uuid().v4(),
                            color: AppColors.borderClr,
                            tail: false,
                            isSender: false,
                          ),
                          _messageSendTimeWidget(widget.time),
                        ],
                      )
                    : widget.messageType == 'text'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              BubbleSpecialOne(
                                textStyle: GoogleFonts.alexandria(
                                    fontSize: 18.sp,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w300),
                                text: widget.text,
                                color: AppColors.borderClr,
                                tail: true,
                                isSender: true,
                              ),
                              _messageSendTimeWidget(widget.time),
                            ],
                          )
                        : widget.messageType == 'voice'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  VoiceMessageBubble(
                                      audioFileUrl: widget.text,
                                      isSender: true),
                                  _messageSendTimeWidget(widget.time),
                                ],
                              )
                            : Container());
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
}
