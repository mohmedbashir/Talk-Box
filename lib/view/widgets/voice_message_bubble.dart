import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/widgets/custom_circle_button.dart';
import 'package:talk_box/view/widgets/voice_message.dart';

class VoiceMessageBubble extends StatefulWidget {
  VoiceMessageBubble(
      {super.key, required this.audioFileUrl, required this.isSender});
  final String audioFileUrl;
  final bool isSender;
  final audioPlayer = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;
  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    widget.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          widget.isPlaying = state == PlayerState.playing;
        });
      }
    });
    widget.audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          widget.duration = newDuration;
        });
      }
    });
    widget.audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          widget.position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.position = Duration.zero;
    widget.duration = Duration.zero;
    // audioPlayer.dispose();
    widget.isPlaying = false;
  }

  Widget build(BuildContext context) {
    print(widget.audioFileUrl);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: widget.isSender ? AppColors.borderClr : AppColors.secondaryClr,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          widget.isSender
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formatTime(widget.position)),
                    Slider(
                      thumbColor:
                          widget.isSender ? Colors.blue : Colors.blue[800],
                      activeColor:
                          widget.isSender ? Colors.blue : Colors.blue[800],
                      inactiveColor: widget.isSender ? null : Colors.blue[600],
                      min: 0,
                      max: widget.duration.inSeconds.toDouble(),
                      value: widget.position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        widget.position = Duration(seconds: value.toInt());

                        await widget.audioPlayer.seek(widget.position);
                        await widget.audioPlayer.resume();
                        setState(() {});
                      },
                    ),
                    CustomCircleButton(
                      icon: widget.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow_rounded,
                      color: widget.isSender ? Colors.blue : Colors.blue,
                      onTap: () async {
                        if (widget.isPlaying) {
                          await widget.audioPlayer.pause();
                        } else {
                          await widget.audioPlayer
                              .play(UrlSource(widget.audioFileUrl));
                        }
                      },
                    )
                    /* MaterialButton(
                      shape: CircleBorder(),
                      height: 25.h,
                      minWidth: 10.w,
                      color: widget.isSender ? Colors.blue : Colors.blue[700],
                      onPressed: () async {
                        if (widget.isPlaying) {
                          await widget.audioPlayer.pause();
                        } else {
                          await widget.audioPlayer
                              .play(UrlSource(widget.audioFileUrl));
                        }
                      },
                      child: Icon(
                        widget.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                    ), */
                  ],
                )
              : Row(
                  children: [
                    MaterialButton(
                      shape: CircleBorder(),
                      height: 34.w,
                      minWidth: 34.w,
                      color: widget.isSender ? Colors.blue : Colors.blue[700],
                      onPressed: () async {
                        if (widget.isPlaying) {
                          await widget.audioPlayer.pause();
                        } else {
                          await widget.audioPlayer
                              .play(UrlSource(widget.audioFileUrl));
                        }
                      },
                      child: Icon(
                        widget.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Slider(
                      thumbColor:
                          widget.isSender ? Colors.blue : Colors.blue[800],
                      activeColor:
                          widget.isSender ? Colors.blue : Colors.blue[800],
                      inactiveColor: widget.isSender ? null : Colors.blue[600],
                      min: 0,
                      max: widget.duration.inSeconds.toDouble(),
                      value: widget.position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        widget.position = Duration(seconds: value.toInt());

                        await widget.audioPlayer.seek(widget.position);
                        await widget.audioPlayer.resume();
                        setState(() {});
                      },
                    ),
                    Text(formatTime(widget.position)),
                  ],
                ),
        ],
      ),
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
