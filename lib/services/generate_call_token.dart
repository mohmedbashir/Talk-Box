import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:talk_box/controllers/app_controller.dart';

//Auth token we will use to generate a meeting and connect to it
String token = '';

// API call to create meeting
Future<String> createMeeting() async {
  token = await AppController.getAppLinks(neddedLink: 'videoSDKToken');
  final http.Response httpResponse = await http.post(
    Uri.parse("https://api.videosdk.live/v2/rooms"),
    headers: {'Authorization': token},
  );

//Destructuring the roomId from the response
  print(json.decode(httpResponse.body)['roomId']);
  return json.decode(httpResponse.body)['roomId'];
}
