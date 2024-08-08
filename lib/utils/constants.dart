import 'package:flutter/material.dart';

// const doctorId = '5gYfYDYpSof7vkLyzH7Y41h207A2';
OutlineInputBorder customBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: AppColors.borderClr, width: 2),
    borderRadius: BorderRadius.circular(15));

OutlineInputBorder customErrorBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(15),
  borderSide: BorderSide(color: Colors.red[100]!, width: 2),
);

class AppColors {
  static const Color primaryClr = Color(0xff007AFF);
  static const Color secondaryClr = Color(0xff55A6FE);
  static const Color backgroundClr = Color(0xFFf0f1f9);
  static const Color borderClr = Colors.black12;
  static const Color headTitleBorderClr = Color(0xFF007AFF);
  static const Color hintTextClr = Colors.black54;

  static const Color black = Colors.black;
  static const Color black1 = Colors.black12;
  static const Color black2 = Colors.black38;
  static const Color black3 = Colors.black54;
  static const Color white = Colors.white;
}

class AppAssets {
  static const logo = 'assets/images/splash2.png';

  static const onboarding1 = 'assets/images/onboarding1.png';
  static const onboarding2 = 'assets/images/onboarding2.png';
  static const onboarding3 = 'assets/images/onboarding3.png';

  static const homeIcon = 'assets/icons/home.png';

  static const frindsIcon = 'assets/icons/group.png';

  static const chatIcon = 'assets/icons/chat.png';

  static const accountIcon = 'assets/icons/account.png';

  static const setAvatarIcon = 'assets/icons/user.png';
  static const avatarIcon = 'assets/icons/change-avatar.png';
  static const sendIcon = 'assets/icons/send.png';
  static const storyIcon = 'assets/icons/story.png';
  static const attachIcon = 'assets/icons/attach.png';
  static const changeAvatarIcon = 'assets/icons/avatar.png';
  static const rateIcon = 'assets/icons/rate.png';
  // static const logoutIcon = 'assets/icons/logout.png';
  static const logoutIcon = 'assets/icons/logout.png';

  static const shareIcon = 'assets/icons/share.png';

  static const userNameIcon = 'assets/icons/username.png';
  static const emailIcon = 'assets/icons/email.png';
  static const passwordIcon = 'assets/icons/password.png';
  static const hidePasswordIcon = 'assets/icons/hide-password.png';
  static const wrongIcon = 'assets/icons/wrong.png';
  static const successIcon = 'assets/icons/success.png';
  static const friendsIcon = 'assets/icons/friends.png';
  static const addFriendIcon = 'assets/icons/add-friend.png';

  static const personPhoto = 'assets/images/person-photo.png';
  // static const doctorPhoto = 'assets/images/doctor-photo.png';

  static const story1 = 'assets/images/story1.jpg';
  static const story2 = 'assets/images/story2.jpg';
  static const story3 = 'assets/images/story3.jpg';
  static const story4 = 'assets/images/story4.jpg';
  static const story5 = 'assets/images/story5.jpg';
  static const story6 = 'assets/images/story6.jpg';
}

class AppConstants {
  static const String createPaymentProcessURLTest =
      "https://sandbox.meshulam.co.il/api/light/server/1.0/createPaymentProcess";
  static const String createPaymentProcessURL =
      "https://secure.meshulam.co.il/api/light/server/1.0/createPaymentProcess";
  static const String MESHULAM_PAGE_CODE =
      "8ec6d47fd62d"; // for test: f59d6bd63321
  static const String MESHULAM_PAGE_CODE_Test = "f59d6bd63321";

  static const String MESHULAM_USER_ID =
      "ae6029ad5a34d8e3"; // for test: 23836384e95927cf
  static const String MESHULAM_USER_ID_Test = "23836384e95927cf";
  static const String MESHULAM_AMOUNT = "150";
  static const String MESHULAM_SUCCESS_URL =
      "https://talk-box-7bc47.web.app/thanks_for_payment.html?area=payment";
  static const String BASE_MESHULAM_URL =
      "https://secure.meshulam.co.il/api/light/server/1.0/"; // for test: https://sandbox.meshulam.co.il/api/light/server/1.0/
  static const String BASE_TIMEZONE_URL =
      "https://timeapi.io/api/Time/current/";
  static const String BASE_TIMEZONE_URL2 = "http://worldtimeapi.org/api/";
  static const String DOCTOR_CITY = "asia/jerusalem";
  static const String GP_URL =
      "https://play.google.com/store/apps/details?id=com.tBox.app";
  static const String DOCTOR_NAME = "TalkBox Psychiatrist";
  static const String DOCTOR_ID = "0QMg4BXAQHRJ5qmIuyKnbfeIO3x2";
  static const String DOCTOR_IMAGE =
      "https://firebasestorage.googleapis.com/v0/b/talk-box-7bc47.appspot.com/o/doctor_img.png?alt=media";
  static const String SUPPORT_EMAIL = "mailto:talkboxcommunity@gmail.com";
  static const String DOCTOR_CV =
      "https://firebasestorage.googleapis.com/v0/b/talk-box-7bc47.appspot.com/o/DoctorCV.pdf?alt=media";

  static const String DOCTOR_POLICIES =
      "https://talk-box-7bc47.web.app/doctor_privecy_policy.html";
  static const String APP_POLICIES =
      "https://talk-box-7bc47.web.app/privecy_policy.html";
  static const String ACCESS_TOKEN_SERVER =
      "https://twilio-serverless-video-8572-dev.twil.io/get_token";

  static const String SHARED_PREF_DOCTOR_POLICES = "doctor_policies";
  static const String SHARED_PREF_DOCTOR_POLICES_KEY_ACCEPTED = "accepted";

  static const int MAX_VIDEO_DURATION_SECONDS = 60;

  static const womanDefualtAvatar =
      'https://firebasestorage.googleapis.com/v0/b/talk-box-7bc47.appspot.com/o/woman-avatar.png?alt=media&token=44b84d72-6efc-4a6c-beae-68673e2ae3aa&_gl=1*1mptbp2*_ga*MTM4NzU4MDU0Mi4xNjc1MjQ4Njcw*_ga_CW55HF8NVT*MTY4NjMyNTY1NS44OS4xLjE2ODYzMjU2NTkuMC4wLjA.';
  static const manDefualtAvatar =
      'https://firebasestorage.googleapis.com/v0/b/talk-box-7bc47.appspot.com/o/man-avatar.png?alt=media&token=61f79ba2-e24c-4049-8b5e-f6ee8ff7b25e&_gl=1*1edpxzh*_ga*MTM4NzU4MDU0Mi4xNjc1MjQ4Njcw*_ga_CW55HF8NVT*MTY4NjMxNTQyOS44Ny4xLjE2ODYzMTU2NzYuMC4wLjA.';
}
