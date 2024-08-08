import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/auth/sign_in_screen.dart';
import 'package:talk_box/view/auth/sign_up_screen.dart';
import 'package:talk_box/view/widgets/custom_button.dart';
import 'package:talk_box/view/widgets/custom_text.dart';

class OnBoardingScreen extends StatefulWidget {
  OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController pageController = PageController();
  bool isFirstTime = true;
  initializeOnBoardingScreens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTime = await prefs.getBool('isFirstTime') ?? true;
  }

  @override
  void initState() {
    // initializeOnBoardingScreens();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          _pageContent(),
          _pageIndicator(),
          const Spacer(),
          _nextButton(pageController)
        ],
      )),
    );
  }

  SizedBox _pageContent() {
    return SizedBox(
      height: 480.h,
      child: PageView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: onBoardings.length,
          controller: pageController,
          itemBuilder: (context, index) {
            return onBoardings[index];
          }),
    );
  }

  SmoothPageIndicator _pageIndicator() {
    return SmoothPageIndicator(
      controller: pageController,
      count: onBoardings.length,
      effect: ExpandingDotsEffect(
          spacing: 10.sp,
          radius: 50.sp,
          dotWidth: 10.w,
          dotHeight: 10.w,
          dotColor: AppColors.borderClr,
          activeDotColor: AppColors.primaryClr),
    );
  }
}

Future<void> _setOnboardingCompleted() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstTime', false);
  print("_setOnboardingCompleted");
}

Padding _nextButton(PageController pageController) {
  return Padding(
    padding: const EdgeInsets.all(15),
    child: CustomButton(
        label: "next".tr,
        onTap: () async {
          print(pageController.page!.toInt());
          if (pageController.page!.toInt() == 2) {
            await _setOnboardingCompleted();
          }
          pageController.page!.toInt() < 2
              ? pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease)
              : Get.offAll(SignUpScreen(),
                  transition: Transition.fade,
                  duration: const Duration(milliseconds: 500));
        }),
  );
}

class OnBoardingContent extends StatelessWidget {
  const OnBoardingContent(
      {super.key,
      required this.image,
      required this.title,
      required this.description,
      this.appName = true});
  final String image;
  final String title;
  final String description;
  final bool appName;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Image.asset(
            image,
            width: image == AppAssets.onboarding2 ? 220.h : 300.h,
          ),
          const Spacer(flex: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: title,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              appName
                  ? CustomText(
                      text: "1onBording1Title2".tr,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryClr,
                    )
                  : Container(),
            ],
          ),
          const Spacer(flex: 1),
          CustomText(
            text: description,
            fontSize: 15.h,
            fontWeight: FontWeight.w400,
            color: AppColors.hintTextClr,
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

List<OnBoardingContent> onBoardings = [
  OnBoardingContent(
    image: AppAssets.onboarding1,
    title: "1onBording1Title1".tr,
    description: "1onBording1Desc".tr,
  ),
  OnBoardingContent(
    image: AppAssets.onboarding2,
    title: "2onBording1Title1".tr,
    description: "2onBording1Desc".tr,
  ),
  OnBoardingContent(
    image: AppAssets.onboarding3,
    title: "3onBording1Title1".tr,
    appName: false,
    description: "3onBording1Desc".tr,
  ),
];
