import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/auth_controller.dart';
import 'package:talk_box/controllers/home_controller.dart';
import 'package:talk_box/models/story_model.dart';
import 'package:talk_box/models/user_model.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/internal page/appointement_booking.dart';
import 'package:talk_box/view/internal%20page/shimmer.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/head_title.dart';
import 'package:talk_box/view/widgets/my_story.dart';
import 'package:talk_box/view/widgets/trending_story.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.currentUser});
  final UserModel currentUser;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  final HomeController homeController = Get.put(HomeController());
  final AppController appController = Get.put(AppController());
  CollectionReference storiesRef =
      FirebaseFirestore.instance.collection('Stories');
  @override
  Widget build(BuildContext context) {
    final start = DateTime.now().add(const Duration(hours: 1));

    final end = DateTime.now().subtract(const Duration(days: 1));
    return Scaffold(
        body: StreamBuilder(
            stream: storiesRef
                .where('publishTime', isLessThan: Timestamp.fromDate(start))
                .where('publishTime', isGreaterThan: Timestamp.fromDate(end))
                .orderBy('publishTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator.adaptive(strokeWidth: 1.5));
              }
              if (snapshot.hasError) {
                return const Text('Error');
              } else {
                if (snapshot.hasData) {
                  List<StoryModel> allStories = [];
                  for (var element in snapshot.data!.docs) {
                    allStories.add(StoryModel.fromJson(
                        element.data() as Map<String, dynamic>));
                  }
                  List<StoryModel> trendingStories = allStories
                      .where(
                        (element) =>
                            element.publisherId != widget.currentUser.uId,
                      )
                      .toList();
                  List<StoryModel> myStories = allStories
                      .where(
                        (element) =>
                            element.publisherId == widget.currentUser.uId,
                      )
                      .toList();
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _post(widget.currentUser, context),
                      _myStories(homeController, myStories),
                      _trendingStory(trendingStories),
                      _doctorCard(appController),
                    ],
                  );
                } else {
                  return const Center(
                      child:
                          CircularProgressIndicator.adaptive(strokeWidth: 1.5));
                }
              }
            }));
  }
}

Widget _post(UserModel currentUser, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(15),
    child: GetBuilder<HomeController>(
      builder: (controller) => TextFormField(
          controller: controller.postController,
          maxLines: 5,
          minLines: 1,
          style: GoogleFonts.alexandria(fontSize: 20, color: AppColors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            suffixIcon: controller.isTextPost
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: AppColors.black1,
                        width: 2,
                        height: 36,
                      ),
                      SizedBox(
                        width: 55.w,
                        height: 55.w,
                        child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            onPressed: () {
                              controller.addStoryTofirebasStorage(
                                  storyType: 'text');
                            },
                            child: const Icon(
                              Icons.post_add_rounded,
                              color: AppColors.secondaryClr,
                            )),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 55.w,
                        height: 55.w,
                        child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            onPressed: () async {
                              await controller.selectFile('photo');
                              _showLoadingDialog(context, controller);
                            },
                            child: const Icon(
                              Icons.photo_library_outlined,
                              color: AppColors.secondaryClr,
                            )),
                      ),
                      Container(
                        color: AppColors.black1,
                        width: 2,
                        height: 36,
                      ),
                      SizedBox(
                        width: 55.w,
                        height: 55.w,
                        child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            onPressed: () async {
                              await controller.selectFile('video');
                              _showLoadingDialog(context, controller);
                            },
                            child: const Icon(
                              Icons.video_collection_outlined,
                              color: AppColors.secondaryClr,
                            )),
                      ),
                    ],
                  ),
            filled: true,
            fillColor: AppColors.white,
            hintText: "postHint".tr,
            hintStyle: GoogleFonts.alexandria(
                fontSize: 16.sp, color: AppColors.black2),
            errorBorder: customErrorBorder,
            focusedErrorBorder: customErrorBorder,
            border: customBorder,
            focusedBorder: customBorder,
            disabledBorder: customBorder,
            enabledBorder: customBorder,
          )),
    ),
  );
}

Future<dynamic> _showLoadingDialog(
    BuildContext context, HomeController controller) {
  return showDialog(
      context: context,
      builder: (context) => controller.uploadTask != null
          ? Center(
              child: StreamBuilder<TaskSnapshot>(
                stream: controller.uploadTask!.snapshotEvents,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return CustomText(text: 'Upload error: ${snapshot.error}');
                  }
                  if (snapshot.hasData) {
                    final progress = snapshot.data!.bytesTransferred /
                        snapshot.data!.totalBytes;
                    if (snapshot.data!.bytesTransferred ==
                        snapshot.data!.totalBytes) Navigator.pop(context);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        color: Colors.white,
                        height: 120.h,
                        width: 100.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator.adaptive(
                                value: progress, strokeWidth: 1),
                            const SizedBox(height: 10),
                            CustomText(
                              text: '${(progress * 100).toStringAsFixed(2)} %',
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const CircularProgressIndicator.adaptive(
                      strokeWidth: 1);
                },
              ),
            )
          : Container(),
      barrierColor: Colors.black.withOpacity(.1));
}

Column _myStories(HomeController controller, List<StoryModel> myStories) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: HeadTitle(title: "myStories".tr),
      ),
      myStories.isNotEmpty
          ? SizedBox(
              height: 145.h,
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: myStories.length,
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemBuilder: (context, index) => MyStory(
                  story: myStories[index],
                ),
              ),
            )
          : SizedBox(
              height: 33.h,
              child: Center(
                  child: CustomText(
                text: "noStoriesForYou".tr,
                fontSize: 12,
              )),
            ),
    ],
  );
}

Column _trendingStory(List<StoryModel> allStories) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: HeadTitle(title: "trendingStories".tr),
      ),
      allStories.isNotEmpty
          ? SizedBox(
              height: 189.h,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemCount: allStories.length,
                itemBuilder: (context, index) =>
                    TrendingStory(story: allStories[index]),
              ),
            )
          : SizedBox(
              height: 50.h,
              child: Center(
                  child: CustomText(
                text: "noTrendingStories".tr,
                fontSize: 12,
              )),
            ),
    ],
  );
}

Padding _doctorCard(AppController appController) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
    child: Container(
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(width: 2, color: AppColors.black1)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 7, 7, 0),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.secondaryClr.withOpacity(.4),
                  radius: 28.sp,
                  child: CircleAvatar(
                    backgroundColor: AppColors.white,
                    radius: 26.sp,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: appController.doctorInfo["doctorPhoto"] ??
                            "https://firebasestorage.googleapis.com/v0/b/talk-box-7bc47.appspot.com/o/account.png?alt=media&token=c95f5479-a520-48f4-b3d0-62bf3590269b",
                        height: 51.h,
                        width: 51.h,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: appController.doctorInfo["doctorName"] ?? "",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 3),
                    CustomText(
                      text: "jobTitle".tr,
                      fontSize: 11,
                      color: AppColors.black3,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          width: 2,
                          color: AppColors.secondaryClr.withOpacity(.2))),
                  height: 50.w,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onPressed: () => Get.to(const AppointementBokking()),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          text: "bookNow".tr,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 25.sp,
                          color: AppColors.secondaryClr,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              height: 1,
              width: 313.6.w,
              color: AppColors.black1,
            ),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(7, 0, 7, 10),
              child: CustomText(
                textAlign: TextAlign.start,
                text: "doctorCardDescription".tr,
                fontSize: 13.5,
                color: AppColors.black,
                fontWeight: FontWeight.w400,
              ))
        ],
      ),
    ),
  );
}
