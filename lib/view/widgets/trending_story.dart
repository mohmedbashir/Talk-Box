import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_box/controllers/home_controller.dart';
import 'package:talk_box/models/story_model.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/internal%20page/trending_story_page.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class TrendingStory extends StatefulWidget {
  const TrendingStory({super.key, required this.story});
  final StoryModel story;

  @override
  State<TrendingStory> createState() => _TrendingStoryState();
}

class _TrendingStoryState extends State<TrendingStory> {
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    if (widget.story.storyType == 'video' && _thumbnailUrl == null) {
      generateThumbnail();
    }
    super.initState();
  }

  String? _thumbnailUrl;
  getThumnail() async {}
  Future<String> generateThumbnail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _thumbnailUrl = prefs.getString(widget.story.storyId!);
    if (_thumbnailUrl == null) {
      _thumbnailUrl = await VideoThumbnail.thumbnailFile(
          quality: 30,
          video: widget.story.storyContent!,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.WEBP);
      prefs.setString(widget.story.storyId!, _thumbnailUrl!);
    }
    return _thumbnailUrl!;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        onTap: () {
          homeController.viewTheStory(storyId: widget.story.storyId!);
          Get.to(TrendingStoryPage(story: widget.story));
        },
        child: Container(
          width: 133.28.w,
          height: 181.28.h,
          decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: const [
                BoxShadow(
                    offset: Offset(1, 1),
                    color: AppColors.black2,
                    blurRadius: 3),
              ],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(width: 2, color: AppColors.black1)),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: widget.story.storyType == 'text'
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
                      child: AutoSizeText(
                        widget.story.storyContent!.length < 25
                            ? widget.story.storyContent!
                            : '${widget.story.storyContent!.substring(0, 25)}...',
                        style: GoogleFonts.alexandria(
                            fontSize: 18, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ))
                  : widget.story.storyType == 'photo'
                      ? CachedNetworkImage(
                          imageUrl: widget.story.storyContent!,
                          fit: BoxFit.cover)
                      : FutureBuilder(
                          future: generateThumbnail(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              SizedBox(
                                  width: 70.w,
                                  height: 70.h,
                                  child: const Center(
                                      child: CircularProgressIndicator.adaptive(
                                          strokeWidth: 1)));
                            } else {
                              return Image.file(File(_thumbnailUrl!),
                                  fit: BoxFit.cover);
                            }
                            return SizedBox(
                                width: 70.w,
                                height: 70.h,
                                child: const Center(
                                    child: CircularProgressIndicator.adaptive(
                                        strokeWidth: 1)));
                          },
                        )),
        ),
      ),
      _publisherCard(),
      (widget.story.storyType == 'video')
          ? _videoBadge(homeController, widget.story)
          : Container()
    ]);
  }

  Padding _publisherCard() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(children: [
        Container(
          height: 25.h,
          decoration: BoxDecoration(
              color: AppColors.black.withOpacity(.4),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.white, width: 0)),
          child: Center(
            child: Container(
              height: 30,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 13.sp,
                    child: CircleAvatar(
                        backgroundColor: AppColors.white.withOpacity(.6),
                        radius: 12.sp,
                        child: ClipOval(
                            child: CachedNetworkImage(
                                imageUrl: widget.story.phublisherPhoto!))),
                  ),
                  SizedBox(width: 5),
                  Container(
                    constraints: BoxConstraints(maxWidth: 75.w),
                    child: CustomText(
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      text: widget.story.phublisherName!.split(' ')[0],
                      fontSize: 12,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

Widget _videoBadge(HomeController controller, StoryModel story) {
  return GestureDetector(
    onTap: () {
      controller.viewTheStory(storyId: story.storyId!);
      Get.to(TrendingStoryPage(story: story));
    },
    child: SizedBox(
      width: 133.28.w,
      height: 181.28.h,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              color: AppColors.black.withOpacity(.4),
              borderRadius: BorderRadius.circular(50)),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 40.sp,
          ),
        ),
      ),
    ),
  );
}
