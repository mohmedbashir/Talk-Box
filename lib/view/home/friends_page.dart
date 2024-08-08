import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/friends_controller.dart';
import 'package:talk_box/models/friend_request_model.dart';
import 'package:talk_box/models/user_model.dart';
import 'package:talk_box/view/widgets/head_title.dart';
import 'package:talk_box/view/widgets/custom_text.dart';
import 'package:talk_box/view/widgets/friend_card.dart';

class FriendsPage extends StatelessWidget {
  FriendsPage({super.key, required this.currnetUser});
  final UserModel currnetUser;
  FriendsController friendsController = Get.put(FriendsController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(15),
        children: [
          _friendRequests(),
          _friends(),
        ],
      ),
    );
  }

  Widget _friends() {
    return StreamBuilder(
      stream: friendsController.getMyFriendsIds(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator.adaptive(strokeWidth: 1.5));
        } else {
          final friendIds = snapshot.data!.get('friends');
          print(friendIds);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeadTitle(
                  title:
                      '${"friends".tr} : ${friendIds != null ? friendIds.length : '0'}'),
              friendIds != null
                  ? FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('Users')
                          .where('uId', whereIn: friendIds)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Error');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 1.5));
                        } else {
                          // print(snapshot.data!.docs.length);
                          List<UserModel> friends = [];
                          for (var element in snapshot.data!.docs) {
                            friends.add(UserModel.fromJson(element.data()));
                          }
                          return SizedBox(
                            height: 486.h,
                            child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: friends.length,
                                itemBuilder: (context, index) => FriendCard(
                                      firendCardType:
                                          FirendCardType.defaultCard,
                                      name: friends[index].name!,
                                      userId: friends[index].uId,
                                      userPhoto: friends[index].avatarUrl!,
                                    )),
                          );
                        }
                      })
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: CustomText(
                          text: "friends2".tr,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ],
          );
        }
      },
    );
  }

  Widget _friendRequests() {
    return StreamBuilder(
      stream: friendsController.getMyFriendRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator.adaptive(strokeWidth: 1.5));
        }
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.hasData) {
          List<FriendRequestModel> friendRequests = [];
          for (var element in snapshot.data!.docs) {
            friendRequests.add(FriendRequestModel.fromJson(
                element.data() as Map<String, dynamic>));
          }
          friendRequests = friendRequests.toSet().toList();
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadTitle(
                    title: '${"friendRequests".tr}: ${friendRequests.length}'),
                friendRequests.isNotEmpty
                    ? SizedBox(
                        height: friendRequests.length > 3
                            ? 3 * 82.4.h
                            : friendRequests.length * 82.4.h,
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: friendRequests.length,
                            itemBuilder: (context, index) => FriendCard(
                                  firendCardType: FirendCardType.friendRequest,
                                  friendRequest: friendRequests[index],
                                )),
                      )
                    : Center(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: CustomText(
                              text: "friendRequests2".tr,
                              fontSize: 12,
                            )))
              ]);
        } else {
          return const Center(
              child: CircularProgressIndicator.adaptive(strokeWidth: 1.5));
        }
      },
    );
  }
}
