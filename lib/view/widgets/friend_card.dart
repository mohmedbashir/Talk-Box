import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/chat_controller.dart';
import 'package:talk_box/controllers/friends_controller.dart';
import 'package:talk_box/models/friend_request_model.dart';
import 'package:talk_box/utils/constants.dart';
import 'package:talk_box/view/internal%20page/chat_page.dart';
import 'package:talk_box/view/widgets/custom_circle_button.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/voice_message.dart';

import '../../utils/helper.dart';

class FriendCard extends StatelessWidget {
  FriendCard(
      {super.key,
      required this.firendCardType,
      this.name,
      this.time,
      this.messagesCount,
      this.lastMessage,
      this.onTap,
      this.userId,
      this.userPhoto,
      this.fcmToken,
      this.friendRequest});
  final FirendCardType firendCardType;
  final String? name;
  final String? userPhoto;
  final Timestamp? time;
  final int? messagesCount;
  final String? lastMessage;
  final Function()? onTap;
  final String? fcmToken;
  final String? userId;
  final FriendRequestModel? friendRequest;
  FriendsController friendsController = Get.put(FriendsController());
  GlobalKey dismissionKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return firendCardType == FirendCardType.defaultCard
        ? Container(
            height: 77.h,
            margin: const EdgeInsets.only(bottom: 7),
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1, color: AppColors.black1)),
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: firendCardType == FirendCardType.message
                  ? () => Get.to(ChatPage(
                        friendName: name ?? friendRequest!.requesterName!,
                        friendId: userId!,
                        friendPhoto: userPhoto!,
                      ))
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.secondaryClr.withOpacity(.4),
                        radius: 29.sp,
                        child: CircleAvatar(
                          backgroundColor: AppColors.white,
                          radius: 28.sp,
                          child: firendCardType == FirendCardType.friendRequest
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: friendRequest!.requesterPhoto!,
                                    height: 50.w,
                                  ),
                                )
                              : ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: userPhoto ??
                                        'https://png.pngtree.com/png-vector/20190704/ourlarge/pngtree-businessman-user-avatar-free-vector-png-image_1538405.jpg',
                                    height: 54.h,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                              firendCardType == FirendCardType.message
                                  ? MainAxisAlignment.spaceEvenly
                                  : MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 185.w,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    CustomText(
                                      text: firendCardType ==
                                              FirendCardType.friendRequest
                                          ? friendRequest!.requesterName!
                                          : name ?? '',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            firendCardType == FirendCardType.message
                                ? SizedBox(
                                    width: 180.w,
                                    child: CustomText(
                                      text: lastMessage!.tr,
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      fontSize: lastMessage!.contains("أنا".tr)
                                          ? 13
                                          : 12,
                                      color: AppColors.black3,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    ],
                  ),
                  firendCardType == FirendCardType.friendRequest
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomText(
                              text: Helper.formatTimestamp(
                                  (friendRequest!.timestamp! as Timestamp)
                                      .toDate()),
                              fontSize: 12,
                            ),
                            Row(
                              children: [
                                CustomCircleButton(
                                  icon: Icons.done,
                                  color: AppColors.secondaryClr,
                                  onTap: () =>
                                      friendsController.acceptFriendRequest(
                                          friendRequest: friendRequest!),
                                ),
                                const SizedBox(width: 10),
                                CustomCircleButton(
                                  icon: Icons.close,
                                  color: Colors.red[300]!,
                                  onTap: () =>
                                      friendsController.rejectFriendRequest(
                                          friendRequest: friendRequest!),
                                ),
                              ],
                            )
                          ],
                        )
                      : firendCardType == FirendCardType.defaultCard
                          ? SizedBox(
                              width: 65.72.w,
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                onPressed: () => Get.to(
                                  ChatPage(
                                    isDoctor: false,
                                    friendName:
                                        name ?? friendRequest!.requesterName!,
                                    friendId: userId!,
                                    friendPhoto: userPhoto!,
                                  ),
                                ),
                                child: Image.asset(
                                  AppAssets.chatIcon,
                                  height: 60.w,
                                  width: 60.w,
                                  color: AppColors.secondaryClr,
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomText(
                                  text: Helper.formatTimestamp(
                                      (time as Timestamp).toDate()),
                                  color: AppColors.black3,
                                  fontSize: 11,
                                ),
                              ],
                            )
                ],
              ),
            ),
          )
        : firendCardType == FirendCardType.friendRequest
            ? Container(
                height: 77.h,
                margin: const EdgeInsets.only(bottom: 7),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: AppColors.black1)),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  onPressed: firendCardType == FirendCardType.message
                      ? () => Get.to(ChatPage(
                            friendName: name ?? friendRequest!.requesterName!,
                            friendId: userId!,
                            friendPhoto: userPhoto!,
                          ))
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.secondaryClr.withOpacity(.4),
                            radius: 29.sp,
                            child: CircleAvatar(
                              backgroundColor: AppColors.white,
                              radius: 28.sp,
                              child:
                                  firendCardType == FirendCardType.friendRequest
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                friendRequest!.requesterPhoto!,
                                            height: 50.w,
                                          ),
                                        )
                                      : ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: userPhoto ??
                                                'https://png.pngtree.com/png-vector/20190704/ourlarge/pngtree-businessman-user-avatar-free-vector-png-image_1538405.jpg',
                                            height: 54.h,
                                          ),
                                        ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  firendCardType == FirendCardType.message
                                      ? MainAxisAlignment.spaceEvenly
                                      : MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 175.w,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        CustomText(
                                          text: firendCardType ==
                                                  FirendCardType.friendRequest
                                              ? friendRequest!.requesterName!
                                              : name ?? '',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                firendCardType == FirendCardType.message
                                    ? SizedBox(
                                        width: 180.w,
                                        child: CustomText(
                                          text: lastMessage!.tr,
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          fontSize:
                                              lastMessage!.contains("أنا".tr)
                                                  ? 13
                                                  : 12,
                                          color: AppColors.black3,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          )
                        ],
                      ),
                      firendCardType == FirendCardType.friendRequest
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomText(
                                  text: Helper.formatTimestamp(
                                      (friendRequest!.timestamp! as Timestamp)
                                          .toDate()),
                                  fontSize: 12,
                                ),
                                Row(
                                  children: [
                                    CustomCircleButton(
                                      icon: Icons.done,
                                      color: AppColors.secondaryClr,
                                      onTap: () =>
                                          friendsController.acceptFriendRequest(
                                              friendRequest: friendRequest!),
                                    ),
                                    const SizedBox(width: 10),
                                    CustomCircleButton(
                                      icon: Icons.close,
                                      color: Colors.red[300]!,
                                      onTap: () =>
                                          friendsController.rejectFriendRequest(
                                              friendRequest: friendRequest!),
                                    ),
                                  ],
                                )
                              ],
                            )
                          : firendCardType == FirendCardType.defaultCard
                              ? SizedBox(
                                  width: 65.72.w,
                                  child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    onPressed: () => Get.to(
                                      ChatPage(
                                        isDoctor: false,
                                        friendName: name ??
                                            friendRequest!.requesterName!,
                                        friendId: userId!,
                                        friendPhoto: userPhoto!,
                                      ),
                                    ),
                                    child: Image.asset(
                                      AppAssets.chatIcon,
                                      height: 60.w,
                                      width: 60.w,
                                      color: AppColors.secondaryClr,
                                    ),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CustomText(
                                      text: Helper.formatTimestamp(
                                          (time as Timestamp).toDate()),
                                      color: AppColors.black3,
                                      fontSize: 11,
                                    ),
                                  ],
                                )
                    ],
                  ),
                ),
              )
            : Container(
                height: 77.h,
                margin: const EdgeInsets.only(bottom: 7),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: AppColors.black1)),
                child: Slidable(
                  direction: Axis.horizontal,
                  actionPane: SlidableStrechActionPane(),
                  secondaryActions: [
                    if (Get.locale.toString().contains("en"))
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                        child: IconSlideAction(
                          caption: "deleteChat".tr,
                          icon: Icons.delete_outline_rounded,
                          color: Colors.red,
                          foregroundColor: Colors.white,
                          onTap: () => Get.dialog(
                              _deleteChatConfirmation(chatController)),
                        ),
                      )
                  ],
                  actions: [
                    if (!Get.locale.toString().contains("en"))
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            topLeft: Radius.circular(15)),
                        child: IconSlideAction(
                          onTap: () => Get.dialog(
                              _deleteChatConfirmation(chatController)),
                          caption: "deleteChat".tr,
                          icon: Icons.delete_outline_rounded,
                          color: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      )
                  ],
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: firendCardType == FirendCardType.message
                        ? () => Get.to(ChatPage(
                              friendName: name ?? friendRequest!.requesterName!,
                              friendId: userId!,
                              friendPhoto: userPhoto!,
                            ))
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppColors.secondaryClr.withOpacity(.4),
                              radius: 29.sp,
                              child: CircleAvatar(
                                backgroundColor: AppColors.white,
                                radius: 28.sp,
                                child: firendCardType ==
                                        FirendCardType.friendRequest
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: friendRequest!
                                                  .requesterPhoto ??
                                              "https://firebasestorage.googleapis.com/v0/b/talk-box-7bc47.appspot.com/o/man-avatar.png?alt=media&token=61f79ba2-e24c-4049-8b5e-f6ee8ff7b25e",
                                          height: 50.w,
                                        ),
                                      )
                                    : ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: userPhoto ??
                                              'https://png.pngtree.com/png-vector/20190704/ourlarge/pngtree-businessman-user-avatar-free-vector-png-image_1538405.jpg',
                                          height: 54.h,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    firendCardType == FirendCardType.message
                                        ? MainAxisAlignment.spaceEvenly
                                        : MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 175.w,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            textAlign: TextAlign.start,
                                            text: firendCardType ==
                                                    FirendCardType.friendRequest
                                                ? friendRequest!.requesterName!
                                                : name ?? '',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  firendCardType == FirendCardType.message
                                      ? SizedBox(
                                          width: 180.w,
                                          child: CustomText(
                                            text: lastMessage!.tr,
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            fontSize: lastMessage!.tr
                                                    .contains("أنا".tr)
                                                ? 13
                                                : 12,
                                            color: AppColors.black3,
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            )
                          ],
                        ),
                        firendCardType == FirendCardType.friendRequest
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomText(
                                    text: Helper.formatTimestamp(
                                        (friendRequest!.timestamp! as Timestamp)
                                            .toDate()),
                                    fontSize: 12,
                                  ),
                                  Row(
                                    children: [
                                      CustomCircleButton(
                                        icon: Icons.done,
                                        color: AppColors.secondaryClr,
                                        onTap: () => friendsController
                                            .acceptFriendRequest(
                                                friendRequest: friendRequest!),
                                      ),
                                      const SizedBox(width: 10),
                                      CustomCircleButton(
                                        icon: Icons.close,
                                        color: Colors.red[300]!,
                                        onTap: () => friendsController
                                            .rejectFriendRequest(
                                                friendRequest: friendRequest!),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : firendCardType == FirendCardType.defaultCard
                                ? SizedBox(
                                    width: 65.72.w,
                                    child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      onPressed: () => Get.to(
                                        ChatPage(
                                          isDoctor: false,
                                          friendName: name ??
                                              friendRequest!.requesterName!,
                                          friendId: userId!,
                                          friendPhoto: userPhoto!,
                                        ),
                                      ),
                                      child: Image.asset(
                                        AppAssets.chatIcon,
                                        height: 60.w,
                                        width: 60.w,
                                        color: AppColors.secondaryClr,
                                      ),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CustomText(
                                        text: Helper.formatTimestamp(
                                            (time as Timestamp).toDate()),
                                        color: AppColors.black3,
                                        fontSize: 11,
                                      ),
                                    ],
                                  )
                      ],
                    ),
                  ),
                ),
              );
  }

  Center _deleteChatConfirmation(ChatController controller) {
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
                    text: "areYouSureOfDeleteThisChat".tr,
                    fontSize: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: MaterialButton(
                          height: 50.h,
                          onPressed: () {
                            AppController appController =
                                Get.put(AppController());
                            List ids = [appController.currentUser.uId, userId]
                              ..sort();
                            String chatId = ids.toString();
                            chatController.deleteChat(chatId: chatId);
                            Get.back();
                          },
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
                          onPressed: () {
                            Get.back();
                          },
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
}

enum FirendCardType { defaultCard, friendRequest, message }
