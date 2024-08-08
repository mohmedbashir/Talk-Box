import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/models/story_model.dart';
import 'package:talk_box/models/user_model.dart';
import 'package:talk_box/services/local_storage_service.dart';
import 'package:talk_box/services/stories_services.dart';
import 'package:talk_box/services/user_services.dart';
import 'package:talk_box/view/home/account_page.dart';
import 'package:talk_box/view/home/messages_page.dart';
import 'package:talk_box/view/home/friends_page.dart';
import 'package:talk_box/view/home/home_page.dart';
import 'package:uuid/uuid.dart';

class AppController extends GetxController {
  int _selectedPage = 0;
  int get selectedPage => _selectedPage;
  UserModel currentUser = UserModel();
  // late String doctorPhoto;

  Map doctorInfo = {};
  Future getDoctorInfo() async {
    doctorInfo = {
      "doctorPhoto": await AppController.getAppLinks(
          neddedLink: 'doctorInfo', key: 'doctorPhoto'),
      "doctorName": await AppController.getAppLinks(
          neddedLink: 'doctorInfo', key: 'doctorName'),
      "id":
          await AppController.getAppLinks(neddedLink: 'doctorInfo', key: 'id'),
      "cv":
          await AppController.getAppLinks(neddedLink: 'doctorInfo', key: 'cv'),
    };
  }

  UserFirebaseServices services = UserFirebaseServices();

  @override
  onInit() async {
    doctorInfo = {
      "doctorPhoto": await AppController.getAppLinks(
          neddedLink: 'doctorInfo', key: 'doctorPhoto'),
      "doctorName": await AppController.getAppLinks(
          neddedLink: 'doctorInfo', key: 'doctorName'),
      "id":
          await AppController.getAppLinks(neddedLink: 'doctorInfo', key: 'id'),
      "cv":
          await AppController.getAppLinks(neddedLink: 'doctorInfo', key: 'cv'),
    };
    if (AuthController().auth.currentUser != null) {
      currentUser.uId = AuthController().auth.currentUser!.uid;
    }

    super.onInit();

    // doctorPhoto = await getAppLinks(neddedLink: 'doctorPhoto');
  }

  static getAppLinks({required neddedLink, String key = 'link'}) async {
    final linksDocRef = await FirebaseFirestore.instance
        .collection('AppLinks')
        .doc(neddedLink)
        .get();
    return await linksDocRef.get(key);
  }

/* 
  Map<String, String> appLinks = {'doctor'}; */
  fetchUSerDate(String uid) async {
    currentUser = await services.fethcUserData(uid);
    mainScreenPages = [
      HomePage(currentUser: currentUser),
      FriendsPage(currnetUser: currentUser),
      MessagesPage(currnetUser: currentUser),
      AccountPage(currnetUser: currentUser)
    ];
  }

  List<Widget> mainScreenPages = [];

  void bnbItemTapped(int index) {
    _selectedPage = index;
    update();
  }

  /////////////////////////// home page //////////////////////////////////////
  // final StoriesService _storiesService = StoriesService();
  // void addStory(String storyType, String storyContent) async {
  //   final story = StoryModel(
  //     storyId: Uuid().v4(),
  //     publisherId: currentUser.uId,
  //     phublisherPhoto: currentUser.avatarUrl,
  //     storyType: storyType,
  //     storyContent: storyContent,
  //   );
  //   await _storiesService.addStoryToFirebase(story);
  // }
}
