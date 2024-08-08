import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/controllers/friends_controller.dart';
import 'package:talk_box/services/user_services.dart';
import 'package:talk_box/utils/constants.dart';

class AddFriendButton extends StatefulWidget {
  const AddFriendButton(
      {super.key,
      required this.friendId,
      this.color = Colors.white,
      this.isReactCard = false});
  final String friendId;
  final Color? color;
  final bool? isReactCard;
  @override
  State<AddFriendButton> createState() => _AddFriendButtonState();
}

class _AddFriendButtonState extends State<AddFriendButton> {
  final AppController appController = Get.put(AppController());
  final FriendsController friendsController = Get.put(FriendsController());
  UserFirebaseServices userFirebaseServices = UserFirebaseServices();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: userFirebaseServices.checkFriendshipStatus(
            requester: appController.currentUser.uId!,
            recipient: widget.friendId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              margin: const EdgeInsets.all(5),
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color:
                    widget.isReactCard! ? null : Colors.black.withOpacity(.3),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                    strokeWidth: 1,
                    color: widget.isReactCard!
                        ? AppColors.secondaryClr
                        : AppColors.white),
              ),
            );
          } else {
            return !widget.isReactCard!
                ? Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.black.withOpacity(.3),
                    ),
                    child: snapshot.data == "not friend"
                        ? InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () async {
                              setState(() {});
                              await friendsController.sendFriendRequest(
                                  userId: widget.friendId);
                              setState(() {});
                            },
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Image.asset(
                                  AppAssets.addFriendIcon,
                                  color: AppColors.white,
                                  width: 30.w,
                                )),
                          )
                        : snapshot.data == "there is request"
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.watch_later_outlined,
                                  color: AppColors.white,
                                  size: 30.sp,
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Image.asset(
                                  AppAssets.friendsIcon,
                                  color: AppColors.white,
                                  width: 30.w,
                                ),
                              ))
                : Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: snapshot.data == "not friend"
                        ? InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () async {
                              setState(() {});
                              await friendsController.sendFriendRequest(
                                  userId: widget.friendId);
                              setState(() {});
                            },
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Image.asset(
                                  AppAssets.addFriendIcon,
                                  color: AppColors.secondaryClr,
                                  width: 25.w,
                                )),
                          )
                        : snapshot.data == "there is request"
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.watch_later_outlined,
                                  color: AppColors.secondaryClr,
                                  size: 25.sp,
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Image.asset(
                                  AppAssets.friendsIcon,
                                  color: AppColors.secondaryClr,
                                  width: 25.w,
                                ),
                              ));
          }
        });
  }
}
