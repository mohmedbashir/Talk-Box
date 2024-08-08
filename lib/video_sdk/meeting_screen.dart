import 'dart:async';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:talk_box/controllers/appintment_controller.dart';
import 'package:talk_box/controllers/chat_controller.dart';
import 'package:talk_box/utils/helper.dart';
import 'package:talk_box/video_sdk/meeting_controls.dart';
import 'package:videosdk/videosdk.dart';
import './participant_tile.dart';

class MeetingScreen extends StatefulWidget {
  final String? meetingId;
  final String? token;
  final bool? isVideoCall;
  final String? chatId;
  final DateTime? meetTime;
  final String? meetId;
  final bool? isDoctor;
  const MeetingScreen(
      {super.key,
      /* required */ this.meetingId,
      /* required */ this.token,
      /* required */ this.isVideoCall,
      this.meetTime,
      this.meetId,
      this.isDoctor = false,
      /*  required */ this.chatId});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late Room _room;
  var micEnabled = true;
  var camEnabled;

  Map<String, Participant> participants = {};
  AppointementController appointementController =
      Get.put(AppointementController());
  void scheduleEndChatActions() {
    if (widget.meetTime != null) {
      print(widget.meetTime);
      final now = DateTime.now();
      final difference = widget.meetTime!.difference(now);
      final closeChatDuration = difference + const Duration(minutes: 50);
      final sendAlertDuratoin =
          closeChatDuration - const Duration(minutes: 5, seconds: 5);
      print(closeChatDuration);
      print(sendAlertDuratoin);

      if (closeChatDuration.isNegative) return;

      Timer(
          sendAlertDuratoin,
          () => Helper.customSnakBar(
              title: "sessionWillFinishAfter5Minutes".tr,
              message: "sessionWillFinishAfter5Minutes2".tr));

      Timer(closeChatDuration, () async {
        if (widget.isDoctor! == true) {
          appointementController.endMeet(meetId: widget.meetId!);
          await _deleteCallDocuments();
        }
        _room.disableCam();
        _room.leave();
        _room.end();
        Get.back();
      });
    }
  }

  @override
  void initState() {
    camEnabled = widget.isVideoCall;
    // create room
    _room = VideoSDK.createRoom(
      roomId: widget.meetingId!,
      token: widget.token!,
      displayName: "John Doe",
      micEnabled: micEnabled,
      camEnabled: camEnabled,
      defaultCameraIndex: 1,
    );

    if (mounted) {
      scheduleEndChatActions();
    }

    setMeetingEventListener();

    // Join room
    _room.join();
    if (mounted) {
      checkAnswer();
    }
    if (!widget.isVideoCall!) {
      // swithcOutputDevice();
    }
    super.initState();
  }

  // swithcOutputDevice() async {
  //   List<MediaDeviceInfo> outputDevice = _room.getAudioOutputDevices();

  //   await _room.switchAudioDevice(_room.getAudioOutputDevices()[0]);
  // }

  // listening to meeting events
  void setMeetingEventListener() {
    _room.on(Events.roomJoined, () {
      if (mounted) {
        setState(() {
          participants.putIfAbsent(
              _room.localParticipant.id, () => _room.localParticipant);
        });
      }
    });

    _room.on(
      Events.participantJoined,
      (Participant participant) {
        if (mounted) {
          setState(
            () => participants.putIfAbsent(participant.id, () => participant),
          );
        }
      },
    );
    _room.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        if (mounted) {
          setState(
            () => participants.remove(participantId),
          );
        }
      }
    });

    _room.on(Events.roomLeft, () {
      participants.clear();
      ChatController().messageController.clear();
    });
  }

  // onbackButton pressed leave the room
  Future<bool> _onWillPop() async {
    _room.leave();
    _room.disableCam();
    return true;
  }

  Timer? timer;
  checkAnswer() {
    timer = Timer(Duration(seconds: 20), () {
      if (participants.length < 2) {
        // _room.leave();
        _room.end();
        Get.back();
        _deleteCallDocuments();
        Helper.customSnakBar(title: "noAnswer".tr, message: "noAnswer2".tr);
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                ),
                itemBuilder: (context, index) {
                  return ParticipantTile(
                      key: Key(participants.values.elementAt(index).id),
                      participant: participants.values.elementAt(index));
                },
                itemCount: participants.length,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: MeetingControls(
                  isVideoCall: widget.isVideoCall!,
                  onToggleMicButtonPressed: () {
                    micEnabled ? _room.muteMic() : _room.unmuteMic();
                    micEnabled = !micEnabled;
                  },
                  onToggleCameraButtonPressed: () {
                    camEnabled ? _room.disableCam() : _room.enableCam();
                    camEnabled = !camEnabled;
                  },
                  onSwitchCamButtonPressed: () async {
                    final cameras = await _room.getCameras();

                    _room.changeCam(_room.selectedCamId == cameras[0].deviceId
                        ? cameras[1].deviceId
                        : cameras[0].deviceId);
                  },
                  onLeaveButtonPressed: () async {
                    _deleteCallDocuments();
                    if (_room != null) {
                      _room.disableCam();
                      _room.leave();
                      _room.end();
                    }
                    timer != null ? timer!.cancel() : null;
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _deleteCallDocuments() async {
    CollectionReference parentCollectionRef =
        FirebaseFirestore.instance.collection('Chats');
    final documentQuery = await parentCollectionRef
        .doc(widget.chatId)
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
}
