import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantTile extends StatefulWidget {
  final Participant participant;
  const ParticipantTile({super.key, required this.participant});

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  Stream? videoStream;

  @override
  void initState() {
    // initial video stream for the participant
    widget.participant.streams.forEach((key, Stream stream) {
      if (mounted) {
        setState(() {
          if (stream.kind == 'video') {
            videoStream = stream;
          }
        });
      }
    });
    _initStreamListeners();
    super.initState();
  }

  _initStreamListeners() {
    widget.participant.on(Events.streamEnabled, (Stream stream) {
      if (mounted) {
        if (stream.kind == 'video') {
          setState(() => videoStream = stream);
        }
      }
    });

    widget.participant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'video') {
        if (mounted) {
          setState(() => videoStream = null);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return videoStream != null
        ? RTCVideoView(
            videoStream?.renderer as RTCVideoRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
        : Container(
            color: Colors.grey.shade800,
            child: Center(
              child: Icon(
                Icons.person,
                size: 100.sp,
              ),
            ),
          );
  }
}
