import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talk_box/utils/helper.dart';

class VoiceRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialsed = false;

  bool get isRecording => _audioRecorder!.isRecording;
  Future init() async {
    _audioRecorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic Permission is reqired');
    }
    await _audioRecorder!.openRecorder();
    _isRecorderInitialsed = true;
  }

  void dispose() {
    _audioRecorder!.closeRecorder();
    _audioRecorder = null;
    _isRecorderInitialsed = false;
  }

  Future _record() async {
    if (!_isRecorderInitialsed) return;
    await _audioRecorder!.startRecorder(toFile: 'audio_example.aac');
  }

  Future _stop() async {
    if (!_isRecorderInitialsed) return;
    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecording() async {
    if (_audioRecorder!.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }
}
