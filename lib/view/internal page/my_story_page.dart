import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_box/controllers/home_controller.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/story_viewer_card.dart';
import 'package:talk_box/view/widgets/video_player.dart';

import '../../models/story_model.dart';

class MyStoryPage extends StatelessWidget {
  MyStoryPage({super.key, required this.story});
  final StoryModel story;

  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        SafeArea(child: _story()),
        _customAppBar(context),
        _options(context),
      ]),
    );
  }

  Positioned _options(BuildContext context) {
    return Positioned(
        left: 10,
        bottom: 10,
        child: Column(
          children: [_likers(), _commenters(), _deleteButton(context)],
        ));
  }

  Container _deleteButton(BuildContext context) {
    return Container(
      height: 45,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.black.withOpacity(.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () => showDialog(
            context: context, builder: (context) => _storyDeletionDialog()),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 30.sp,
          ),
        ),
      ),
    );
  }

  Container _commenters() {
    return Container(
      height: 45,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.black.withOpacity(.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () async {
          Get.bottomSheet(
            Container(
              decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25))),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          color: AppColors.black1,
                          height: 7,
                          width: 50,
                        )),
                  ),
                  CustomText(text: "comments".tr, fontSize: 14),
                  story.comments == null
                      ? Expanded(
                          child: Center(
                            child: CustomText(
                              text: "noComments".tr,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : FutureBuilder(
                          future: homeController.getCommentsOfStory(
                              storyId: story.storyId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Center(
                                        child:
                                            CircularProgressIndicator.adaptive(
                                      strokeWidth: 1.5,
                                    )),
                                  ],
                                ),
                              );
                            } else {
                              return Expanded(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.all(15),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) =>
                                      StoryReactCard(
                                    user: snapshot.data![index].commentOwner!,
                                    comment: snapshot.data![index].comment,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.insert_comment_rounded,
            color: Colors.white,
            size: 30.sp,
          ),
        ),
      ),
    );
  }

  Container _likers() {
    return Container(
      height: 45,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.black.withOpacity(.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () {
          Get.bottomSheet(
            Container(
              decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25))),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          color: AppColors.black1,
                          height: 7,
                          width: 50,
                        )),
                  ),
                  CustomText(text: "likes".tr, fontSize: 14),
                  story.likes == null || story.likes!.isEmpty
                      ? Expanded(
                          child: Center(
                            child: CustomText(
                              text: "noLikes".tr,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : FutureBuilder(
                          future: homeController.getStoryLikers(
                              storyId: story.storyId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Center(
                                        child:
                                            CircularProgressIndicator.adaptive(
                                      strokeWidth: 1.5,
                                    )),
                                  ],
                                ),
                              );
                            } else {
                              return Expanded(
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(15),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) =>
                                        StoryReactCard(
                                            user: snapshot.data![index])),
                              );
                            }
                          },
                        ),
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 30.sp,
          ),
        ),
      ),
    );
  }

  Positioned _customAppBar(BuildContext context) {
    return Positioned(
        child: AppBar(
      titleSpacing: 0,
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.black.withOpacity(.3),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => Get.back(),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 26.sp,
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: AppColors.black1,
            radius: 24.sp,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(.2),
              radius: 23.sp,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: story.phublisherPhoto!,
                  height: 46.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Container(
            height: 35.h,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black.withOpacity(.3)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 156.8.w),
                    child: CustomText(
                      maxLines: 1,
                      text: story.phublisherName!,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        _viewers(),
      ],
    ));
  }

  Padding _viewers() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 20.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black.withOpacity(.3),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Get.bottomSheet(
              Container(
                decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            color: AppColors.black1,
                            height: 7,
                            width: 50,
                          )),
                    ),
                    CustomText(text: "views".tr, fontSize: 14),
                    story.views == null
                        ? Expanded(
                            child: Center(
                              child: CustomText(
                                text: "noViews".tr,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : FutureBuilder(
                            future: homeController.getStoryViewrs(
                                storyId: story.storyId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Center(
                                          child: CircularProgressIndicator
                                              .adaptive(
                                        strokeWidth: 1.5,
                                      )),
                                    ],
                                  ),
                                );
                              } else {
                                return Expanded(
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(15),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) =>
                                        StoryReactCard(
                                            user: snapshot.data![index]),
                                  ),
                                );
                              }
                            },
                          ),
                  ],
                ),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: CustomText(
                  text: story.views == null
                      ? '0'
                      : story.views!.length.toString(),
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.remove_red_eye_outlined,
                size: 22.sp,
              ),
              const SizedBox(width: 10)
            ],
          ),
        ),
      ),
    );
  }

  Center _storyDeletionDialog() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          color: Colors.white,
          height: 140.h,
          width: 313.6.w,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomText(
                    textAlign: TextAlign.center,
                    text: "areYouSureOfDeletingStory".tr,
                    fontSize: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: MaterialButton(
                          height: 50,
                          onPressed: () =>
                              homeController.deleteStory(story: story),
                          child: CustomText(
                            text: "yes".tr,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(color: Colors.black12, height: 35, width: 1),
                      Expanded(
                        child: MaterialButton(
                          height: 50.h,
                          onPressed: () => Get.back(),
                          child: CustomText(
                            text: "no".tr,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  )
                ]),
          ),
        ),
      ),
    );
  }

  Container _story() {
    return Container(
      height: 200.h,
      width: double.infinity,
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: story.storyType == 'photo'
            ? DecorationImage(
                image: CachedNetworkImageProvider(story.storyContent!),
                fit: BoxFit.contain)
            : null,
      ),
      child: story.storyType == 'text'
          ? Center(
              child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: AutoSizeText(
                    story.storyContent!,
                    style: GoogleFonts.alexandria(
                        fontSize: 18, color: Colors.black),
                    maxFontSize: 16,
                    minFontSize: 12,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ))
          : story.storyType == 'video'
              ? VideoPlayerView(url: story.storyContent!)
              : Container(
                  color: Colors.transparent,
                ),
    );
  }
}
