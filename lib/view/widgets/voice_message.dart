import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talk_box/controllers/chat_controller.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:uuid/uuid.dart';

class VoiceRecordButton extends StatefulWidget {
  const VoiceRecordButton(
      {super.key,
      required this.friendId,
      required this.friendPhoto,
      required this.friendname});
  final String friendId;
  final String friendPhoto;
  final String friendname;

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

ChatController chatController = Get.put(ChatController());

class _VoiceRecordButtonState extends State<VoiceRecordButton> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  // Duration duration = Duration.zero;
  // Duration position = Duration.zero;
  // final audioPlayer = AudioPlayer();
  File? audioFile;
  // String? voicePath;
  bool isPlaying = false;
  @override
  void initState() {
    super.initState();
    initRecorder();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    recorder.closeRecorder();
  }

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
    print("recording");
  }

  Future stop() async {
    if (!isRecorderReady) return;
    final voicePath = await recorder.stopRecorder();
    audioFile = File(voicePath!);
    print(audioFile);
    print("idle");
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw "Mic Permission is Needed";
    }
    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 50.w,
      minWidth: 50.w,
      shape: CircleBorder(),
      color: AppColors.secondaryClr,
      onPressed: () async {
        if (!mounted) return;
        if (isRecorderReady) {
          if (recorder.isRecording) {
            await audioPlayer.play(AssetSource("voices/stop.mp3"));
            await stop();
            chatController.changeTextFieldHint();
            Get.bottomSheet(VoicePlayer(
              friendId: widget.friendId,
              friendPhoto: widget.friendPhoto,
              friendname: widget.friendname,
              audioFile: audioFile!,
            ));
          } else {
            if (isRecorderReady) {
              await audioPlayer.play(AssetSource("voices/start.mp3"));
              await record();
              chatController.changeTextFieldHint();
            }
          }
          setState(() {});
        }
      },
      child: Icon(
          recorder.isRecording
              ? Icons.stop_rounded
              : Icons.keyboard_voice_outlined,
          color: Colors.white,
          size: 30.sp),
    );
  }

/*   void _getLastVoiceMessage(
      {required String friendId,
      required String friendPhoto,
      required String friendname}) {
    Get.bottomSheet(VocicePlayer(
      friendId: friendId,
      friendPhoto: friendPhoto,
      friendname: friendname,
      audioFile: audioFile!,
    ));
  } */
}

class VoicePlayer extends StatefulWidget {
  const VoicePlayer(
      {super.key,
      required this.friendId,
      required this.friendPhoto,
      required this.friendname,
      required this.audioFile});
  final String friendId;
  final String friendPhoto;
  final String friendname;
  final File audioFile;
  @override
  State<VoicePlayer> createState() => _VoicePlayerState();
}

final audioPlayer = AudioPlayer();
Duration duration = Duration.zero;
Duration position = Duration.zero;
bool isPlaying = false;
// final audioPath = 'audio-${Uuid().v4()}';

class _VoicePlayerState extends State<VoicePlayer> {
  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    position = Duration.zero;
    duration = Duration.zero;
    isPlaying = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.h,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                shape: CircleBorder(),
                height: 34.w,
                minWidth: 34.w,
                color: Colors.blue,
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    await audioPlayer.play(DeviceFileSource(
                        "/data/user/0/com.example.talk_box/cache/audio"));
                  }
                },
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              ),
              Text(formatTime(position)),
              Slider(
                thumbColor: Colors.blue,
                activeColor: Colors.blue,
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  position = Duration(seconds: value.toInt());

                  await audioPlayer.seek(position);
                  await audioPlayer.resume();
                  setState(() {});
                },
              ),
              MaterialButton(
                height: 50.w,
                minWidth: 50.w,
                shape: CircleBorder(),
                color: Colors.blue,
                onPressed: () async {
                  Get.back();
                  if (widget.audioFile != null) {
                    UploadTask? uploadTask;
                    uploadTask = FirebaseStorage.instance
                        .ref()
                        .child('Chats/${widget.audioFile}-${Uuid().v4()}')
                        .putFile(File(widget.audioFile.path));
                    TaskSnapshot taskSnapshot = await uploadTask
                        .whenComplete(() => print('uploaded done'));
                    final voiceLink = await taskSnapshot.ref.getDownloadURL();
                    chatController.sendMessage(
                        friendId: widget.friendId,
                        friendPhoto: widget.friendPhoto,
                        friendname: widget.friendname,
                        mediaLink: voiceLink,
                        messageType: 'voice');
                  }
                },
                child: Icon(Icons.send, color: Colors.white, size: 30),
              ),
            ],
          )),
    );
  }
}

String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
}
