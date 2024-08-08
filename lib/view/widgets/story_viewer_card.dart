import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/friends_controller.dart';
import 'package:talk_box/models/user_model.dart';
import 'package:talk_box/services/user_services.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/widgets/add_friend_button.dart';
import 'package:talk_box/view/widgets/custom_text.dart';

// ignore: must_be_immutable
class StoryReactCard extends StatelessWidget {
  StoryReactCard({super.key, required this.user, this.comment});
  final UserModel user;
  final String? comment;

  AppController appController = Get.put(AppController());
  FriendsController friendsController = Get.put(FriendsController());
  bool areFriends = false;
  Future<bool> checkIfAreFriends() async {
    return await UserFirebaseServices()
        .areUsersFriends(appController.currentUser.uId!, user.uId!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.secondaryClr,
                  radius: 25.sp,
                  child: CircleAvatar(
                    backgroundColor: AppColors.white,
                    radius: 24.sp,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.avatarUrl!,
                        height: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: user.name!,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        comment != null
                            ? SizedBox(
                                width: 220.w,
                                child: CustomText(
                                  textAlign: TextAlign.start,
                                  text: comment!,
                                  fontSize: 14,
                                  color: AppColors.black3,
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ],
                ),
              ],
            ),
            AddFriendButton(
              friendId: user.uId!,
              isReactCard: true,
            )
          ],
        ),
        const Divider()
      ],
    );
  }
}
