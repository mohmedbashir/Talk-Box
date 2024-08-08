import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/friends_controller.dart';
import 'package:talk_box/controllers/home_controller.dart';
import 'package:talk_box/models/story_model.dart';
import 'package:talk_box/services/user_services.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/widgets/add_friend_button.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/video_player.dart';

import '../widgets/like_button.dart';

class TrendingStoryPage extends StatefulWidget {
  const TrendingStoryPage({
    super.key,
    required this.story,
  });
  final StoryModel story;

  @override
  State<TrendingStoryPage> createState() => _TrendingStoryPageState();
}

class _TrendingStoryPageState extends State<TrendingStoryPage> {
  HomeController homeController = Get.put(HomeController());

  FriendsController friendsController = Get.put(FriendsController());
  AppController appController = Get.put(FriendsController());

  Future<bool> checkIfAreFriends() async {
    return await UserFirebaseServices().areUsersFriends(
        appController.currentUser.uId!, widget.story.publisherId!);
  }

  /* Future<String> checkFriendshipStatus() async {
    if (await UserFirebaseServices().areUsersFriends(
        appController.currentUser.uId!, widget.story.publisherId!)) {
      return "friends";
    }else if(){
    
    }
    ;
  } */

  bool areFriends = false;
  @override
  void initState() {
    checkIfAreFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        _storyContent(),
        _customAppBar(),
        _reactSection(),
      ]),
    );
  }

  Positioned _reactSection() {
    return Positioned(
        bottom: 0,
        child: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                    offset: Offset(-1, -1),
                    blurRadius: 5,
                    color: AppColors.black1)
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              child: Container(
                color: AppColors.black.withOpacity(.3),
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LikeButton(
                          homeController: homeController, story: widget.story),
                      _sendComment(),
                    ],
                  ),
                ),
              ),
            )));
  }

  Row _sendComment() {
    return Row(
      children: [
        Container(
          width: 250.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.borderClr, width: 1.5)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: TextFormField(
                controller: homeController.commentController,
                cursorWidth: 1,
                maxLines: 3,
                minLines: 1,
                scrollPadding: EdgeInsets.all(0),
                style: GoogleFonts.alexandria(
                    fontSize: 17, color: AppColors.white),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    filled: true,
                    fillColor: AppColors.white.withOpacity(.15),
                    hintText: "sendComment".tr,
                    hintStyle: GoogleFonts.alexandria(
                        fontSize: 16.sp,
                        color: AppColors.white.withOpacity(.7)),
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none))),
          ),
        ),
        SizedBox(width: 10.w),
        ClipOval(
          child: Material(
            elevation: 10,
            color: AppColors.secondaryClr,
            child: InkWell(
              onTap: () {
                homeController.addComment(storyId: widget.story.storyId!);
                homeController.commentController.clear();
              },
              child: SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: Icon(
                    Icons.send,
                    size: 30.sp,
                    color: AppColors.white,
                  )),
            ),
          ),
        )
      ],
    );
  }

  Widget _storyContent() {
    return Container(
      height: 200,
      width: double.infinity,
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: widget.story.storyType == 'photo'
            ? DecorationImage(
                image: CachedNetworkImageProvider(widget.story.storyContent!),
                fit: BoxFit.contain)
            : null,
      ),
      child: widget.story.storyType == 'text'
          ? Center(
              child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: AutoSizeText(
                    widget.story.storyContent!,
                    style: GoogleFonts.alexandria(
                        fontSize: 18, color: Colors.black),
                    maxFontSize: 16,
                    minFontSize: 12,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ))
          : widget.story.storyType == 'video'
              ? VideoPlayerView(url: widget.story.storyContent!)
              : Container(
                  color: Colors.transparent,
                ),
    );
  }

  AppBar _customAppBar() {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
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
      title: _publisherCard(),
      actions: [
        AddFriendButton(friendId: widget.story.publisherId!),
        _reportoButton(),
      ],
    );
  }

  Row _publisherCard() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 5.w),
        CircleAvatar(
          backgroundColor: AppColors.black1,
          radius: 24.sp,
          child: CircleAvatar(
            backgroundColor: AppColors.white.withOpacity(.6),
            radius: 23.sp,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.story.phublisherPhoto!,
                height: 46.h,
                width: 46.h,
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
            child: Container(
              constraints: BoxConstraints(maxWidth: 150.w),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomText(
                      text: widget.story.phublisherName!,
                      maxLines: 1,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* Widget addFriendButton() {
    return FutureBuilder(
        future: checkIfAreFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              margin: const EdgeInsets.all(5),
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.black.withOpacity(.3),
              ),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: AppColors.white,
                ),
              ),
            );
          } else {
            return Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black.withOpacity(.3),
                ),
                child: snapshot.data == false
                    ? InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () async {
                          Future.delayed(Duration(seconds: 1))
                              .then((value) async {
                            await friendsController.sendFriendRequest(
                                userId: widget.story.publisherId!);
                          });
                        },
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Image.asset(
                              AppAssets.addFriendIcon,
                              color: AppColors.white,
                              width: 30.w,
                            )),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset(
                          AppAssets.friendsIcon,
                          color: AppColors.white,
                          width: 30.w,
                        ),
                      ));
          }
        });
  }
 */
  Container _reportoButton() {
    return Container(
      width: 45.h,
      height: 45.h,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.black.withOpacity(.3),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () => homeController.report(storyId: widget.story.storyId),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.5),
          child: Icon(
            Icons.report_gmailerrorred,
            size: 35.sp,
          ),
        ),
      ),
    );
  }
}
