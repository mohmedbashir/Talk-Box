import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/home_controller.dart';
import 'package:talk_box/models/story_model.dart';

class LikeButton extends StatefulWidget {
  const LikeButton(
      {super.key, required this.homeController, required this.story});
  final HomeController homeController;
  final StoryModel story;
  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        builder: (controller) => FutureBuilder(
            future: widget.homeController
                .checkIfIlikerTheStory(storyId: widget.story.storyId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    margin: Get.locale.toString().contains("en")
                        ? const EdgeInsets.only(left: 10)
                        : const EdgeInsets.only(right: 10),
                    height: 30.h,
                    width: 30.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1,
                    ));
              } else {
                return Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () {
                      if (snapshot.data! == false) {
                        widget.homeController
                            .likeTheStory(storyId: widget.story.storyId!);
                        widget.homeController.checkIfIlikerTheStory(
                            storyId: widget.story.storyId!);
                      } else {
                        widget.homeController
                            .unlikeTheStory(storyId: widget.story.storyId!);
                        widget.homeController.checkIfIlikerTheStory(
                            storyId: widget.story.storyId!);
                      }
                      setState(() {});
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: snapshot.data!
                            ? Icon(
                                Icons.favorite_rounded,
                                color: Colors.red,
                                size: 35.sp,
                              )
                            : Icon(
                                Icons.favorite_border_rounded,
                                color: Colors.white,
                                size: 35.sp,
                              )),
                  ),
                );
              }
            }));
  }
}
