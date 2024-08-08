import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_box/models/user_model.dart';

class LocalStorageService {
/*   Future<UserModel?> get getUser async {
    try {
      String userId = await readData();
      UserModel user = await UserFirebaseServices().fethcUserData(userId);
      return user;
    } catch (e) {
      print('there is error');
    }
  } */

  saveData(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', value);
  }

  readData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString('userId') ?? '';
    return value;
  }

  deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
