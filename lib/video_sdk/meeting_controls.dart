import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MeetingControls extends StatelessWidget {
  final void Function() onToggleMicButtonPressed;
  final void Function() onToggleCameraButtonPressed;
  final void Function() onLeaveButtonPressed;
  final void Function() onSwitchCamButtonPressed;
  final bool isVideoCall;

  const MeetingControls(
      {super.key,
      required this.isVideoCall,
      required this.onToggleMicButtonPressed,
      required this.onToggleCameraButtonPressed,
      required this.onSwitchCamButtonPressed,
      required this.onLeaveButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MeetControlButton(
              onPressed: onLeaveButtonPressed,
              baseIcon: Icons.call,
              secondIcon: Icons.call,
              bgColor: Colors.red),
          MeetControlButton(
              onPressed: onToggleMicButtonPressed,
              baseIcon: Icons.mic,
              secondIcon: Icons.mic_off),
          isVideoCall
              ? MeetControlButton(
                  onPressed: onToggleCameraButtonPressed,
                  baseIcon: Icons.videocam,
                  secondIcon: Icons.videocam_off)
              : const SizedBox.shrink(),
          isVideoCall
              ? MeetControlButton(
                  onPressed: onSwitchCamButtonPressed,
                  baseIcon: Icons.switch_right_rounded,
                  secondIcon: Icons.switch_right_rounded)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class MeetControlButton extends StatefulWidget {
  const MeetControlButton(
      {super.key,
      required this.onPressed,
      required this.baseIcon,
      required this.secondIcon,
      this.bgColor});

  final Function() onPressed;
  final IconData baseIcon;
  final IconData secondIcon;
  final Color? bgColor;
  @override
  State<MeetControlButton> createState() => _MeetControlButtonState();
}

class _MeetControlButtonState extends State<MeetControlButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    void handleButtonPress() {
      setState(() {
        isPressed = !isPressed;
      });
      widget.onPressed();
    }

    return CircleAvatar(
        radius: widget.bgColor != null ? 30.sp : 25.sp,
        backgroundColor: widget.bgColor != null ? widget.bgColor : Colors.white,
        child: IconButton(
            onPressed: handleButtonPress,
            icon: Icon(
              isPressed ? widget.secondIcon : widget.baseIcon,
              size: widget.bgColor != null ? 30.sp : 25.sp,
              color: widget.bgColor != null ? Colors.white : Colors.blue,
            )));
  }
}
