import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/models/user_model.dart';
import 'package:talk_box/services/local_storage_service.dart';
import 'package:talk_box/services/user_services.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/utils/helper.dart';
import 'package:talk_box/view/auth/sign_in_screen.dart';
import 'package:talk_box/view/home/doctor/doctor_interface.dart';
import 'package:talk_box/view/home/main_screen.dart';

class AuthController extends GetxController {
  //firebase Authentication processes /////////////////////////

  final FirebaseAuth auth = FirebaseAuth.instance;
  final UserFirebaseServices _userFirebaseServices = UserFirebaseServices();
  final LocalStorageService _localStorageService = LocalStorageService();

  final Rxn<User> _user = Rxn<User>();
  get user => _user.value;

  late UserModel currentUser;
  // Map doctorInfo = {};
  @override
  void onInit() async {
    _user.bindStream(auth.authStateChanges());
    /*    doctorInfo = await {
      "doctorPhoto": await AppController.getAppLinks(
          neddedLink: 'doctorInfo', key: 'doctorPhoto'),
      "doctorName": await AppController.getAppLinks(
          neddedLink: 'doctorInfo', key: 'doctorName'),
      "id":
          await AppController.getAppLinks(neddedLink: 'doctorInfo', key: 'id'),
      "cv":
          await AppController.getAppLinks(neddedLink: 'doctorInfo', key: 'cv'),
    }; */
    super.onInit();
  }

  /// when get into the homeScreen
  @override
  void onClose() {
    emailController.clear();
    firstNameController.clear();
    lastNameController.clear();
    bioController.clear();
    passwordController.clear();
    loginEmailController.clear();
    loginPasswordController.clear();
    _age = 25;
    _isMale = true;
    _usagePoliciesCheckBoxValue = false;
    super.onClose();
  }

  bool signLoading = false;

  ///Sign up
  void signUp() async {
    signLoading = true;
    update();
    try {
      await auth
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      )
          .then((value) async {
        await saveUserToFireStor(value);
        await saveUserIdToLocalStorage(value.user!.uid);
        final doctorinfo = {
          "doctorPhoto": await AppController.getAppLinks(
              neddedLink: 'doctorInfo', key: 'doctorPhoto'),
          "doctorName": await AppController.getAppLinks(
              neddedLink: 'doctorInfo', key: 'doctorName'),
          "id": await AppController.getAppLinks(
              neddedLink: 'doctorInfo', key: 'id'),
          "cv": await AppController.getAppLinks(
              neddedLink: 'doctorInfo', key: 'cv'),
        };
        Get.offAll(MainScreen());
        onClose();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Helper.customSnakBar(
            success: false, title: "snackBar1".tr, message: "snackBar12".tr);
      }
    }
    signLoading = false;
    update();
  }

  ///signIn
  void signIn() async {
    signLoading = true;
    update();
    try {
      await auth
          .signInWithEmailAndPassword(
              email: loginEmailController.text,
              password: loginPasswordController.text)
          .then((value) async {
        _userFirebaseServices.updateToken(uid: value.user!.uid);
        await getUserDatafromFireStore(value.user!.uid);
        await saveUserIdToLocalStorage(value.user!.uid);
        final doctorId = await AppController.getAppLinks(
            neddedLink: 'doctorInfo', key: 'id');
        ;
        if (value.user!.uid == doctorId) {
          Get.offAll(DoctorInterface());
        } else {
          Get.offAll(MainScreen());
        }
        onClose();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Helper.customSnakBar(
            success: false, title: "snackBar2".tr, message: "snackBar22".tr);
      } else if (e.code == 'wrong-password') {
        Helper.customSnakBar(
            success: false, title: "snackBar3".tr, message: "snackBar32".tr);
      } else if (e.code == 'too-many-requests') {
        Helper.customSnakBar(
            success: false, title: "snackBar4".tr, message: "snackBar42".tr);
      }
    }
    signLoading = false;
    update();
  }

//SignOut
  void signOut() {
    auth.signOut();
    _localStorageService.deleteUser();
    _selectedAvatar = null;
    AppController().bnbItemTapped(0);
    Get.offAll(SignInScreen());
  }

  ///Firebaser services/////////////////////////////////////////

  ///add the user and his data to firebase
  saveUserToFireStor(UserCredential value) async {
    final UserModel user = UserModel(
        uId: value.user!.uid,
        email: value.user!.email,
        name: "${firstNameController.text} ${lastNameController.text}",
        bio: bioController.text,
        age: _age,
        gender: isMale ? 'male' : 'female',
        avatarUrl: _selectedAvatar ??
            (isMale
                ? AppConstants.manDefualtAvatar
                : AppConstants.womanDefualtAvatar),
        fcmToken: await FirebaseMessaging.instance.getToken());

    _userFirebaseServices.addUserToFireBase(user);
  }

//bring the user data to display on the app
  getUserDatafromFireStore(String userId) async {
    UserFirebaseServices service = UserFirebaseServices();
    currentUser = await service.fethcUserData(userId);
  }

  /// save userId to local storage
  saveUserIdToLocalStorage(String userId) {
    _localStorageService.saveData(userId);
  }
// UI and Text Fields ////////////////////////////////////

  String? textFieldErrorMessage;

  String? _selectedAvatar;
  String? get selectedAvatar => _selectedAvatar;
  changeAvatar(String newAvatar) async {
    if (auth.currentUser == null) {
      _selectedAvatar = newAvatar;
      update();
    } else {
      await _userFirebaseServices.updateAvatar(
          currentUserId: auth.currentUser!.uid, newAvatar: newAvatar);
      _selectedAvatar = newAvatar;
      update();
    }
    update();
  }

// TextFiedls Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

// password textField obsecure
  bool _obsecurePassword = true;
  bool get obsecurePassword => _obsecurePassword;

  onTapObsecureButton() {
    _obsecurePassword = !_obsecurePassword;
    update();
  }

  // age
  int _age = 25;
  int get age => _age;
  changeAge(String action) {
    action == '+' ? _age++ : _age--;
    update();
  }

// gender
  bool _isMale = true;
  bool get isMale => _isMale;

  changeGender(int index) {
    index == 0 ? _isMale = true : _isMale = false;
    update();
  }

// usage policy check box
  bool _usagePoliciesCheckBoxValue = false;
  bool get usagePoliciesCheckBoxValue => _usagePoliciesCheckBoxValue;

  checkBoxOnTap(bool value) {
    _usagePoliciesCheckBoxValue = value;
    update();
  }

  //////// Get Avatar Photos /////////////////////////
  ///
}
