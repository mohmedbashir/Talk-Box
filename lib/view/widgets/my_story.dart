import 'dart:io';

// import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:talk_box/view/internal%20page/my_story_page.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:ui' as ui;

class MyStory extends StatefulWidget {
  const MyStory({super.key, required this.story});

  final StoryModel story;

  @override
  State<MyStory> createState() => _MyStoryState();
}

class _MyStoryState extends State<MyStory> {
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    if (widget.story.storyType == 'video' && _thumbnailUrl == null) {
      generateThumbnail();
    }
    super.initState();
  }

  String? _thumbnailUrl;

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
          Get.to(
            MyStoryPage(
              story: widget.story,
            ),
          );
        },
        child: Container(
          width: 85.w,
          height: 120.h,
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
                      child: Text(
                      widget.story.storyContent!.length < 25
                          ? widget.story.storyContent!
                          : '${widget.story.storyContent!.substring(0, 25)}...',
                      style: GoogleFonts.alexandria(
                          fontSize: 18, color: Colors.black),
                      /*    maxFontSize: 14.sp,
                        minFontSize: 10.sp, */
                      textAlign: TextAlign.center,
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
      _viewsCount(),
      (widget.story.storyType == 'video')
          ? _videoBadge(widget.story)
          : Container()
    ]);
  }

  Widget _viewsCount() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          height: 22.h,
          width: 40.w,
          decoration: BoxDecoration(
              color: AppColors.black.withOpacity(.4),
              borderRadius: BorderRadius.circular(10)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Icon(
              Icons.remove_red_eye_outlined,
              color: AppColors.white,
              size: 16.sp,
            ),
            CustomText(
              text: widget.story.views == null
                  ? '0'
                  : widget.story.views!.length.toString(),
              fontSize: 12.sp,
              color: AppColors.white,
            )
          ]),
        ),
      ),
    );
  }
}

Widget _videoBadge(StoryModel story) {
  return SizedBox(
    width: 85.w,
    height: 120.h,
    child: Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => Get.to(MyStoryPage(story: story)),
        child: Container(
          height: 30.h,
          width: 30.w,
          decoration: BoxDecoration(
              color: AppColors.black.withOpacity(.4),
              borderRadius: BorderRadius.circular(50)),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
