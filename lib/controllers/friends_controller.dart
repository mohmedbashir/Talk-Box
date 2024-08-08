// ignore_for_file: unnecessary_overrides

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/models/friend_request_model.dart';
import 'package:talk_box/services/user_services.dart';

class FriendsController extends AppController {
  final AppController appController = Get.put(AppController());

  @override
  onInit() {
    super.onInit();
  }

  final UserFirebaseServices _userFirebaseServices = UserFirebaseServices();

  Future<void> sendFriendRequest({required String userId}) async {
    FriendRequestModel friendRequest = FriendRequestModel(
        recipient: userId,
        requester: appController.currentUser.uId,
        requesterName: appController.currentUser.name,
        requesterPhoto: appController.currentUser.avatarUrl,
        status: 'pending',
        timestamp: FieldValue.serverTimestamp());

    await _userFirebaseServices.sendFriendRequest(
        friendRequest: friendRequest,
        currentUserName: appController.currentUser.name!);
  }

  Stream<QuerySnapshot<Object?>> getMyFriendRequests() {
    return UserFirebaseServices()
        .friendRequestsCollection
        .where('recipient', isEqualTo: appController.currentUser.uId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<DocumentSnapshot> getMyFriendsIds() {
    print(appController.currentUser.uId);
    return UserFirebaseServices()
        .usersCollection
        .doc(appController.currentUser.uId)
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>> getMyFriends() {
    List<String> friendsIds = [];
    _userFirebaseServices.usersCollection
        .doc(appController.currentUser.uId)
        .get()
        .then((value) => friendsIds = value.get('friends'));
    print(friendsIds);
    return UserFirebaseServices()
        .usersCollection
        .where('uId', whereIn: friendsIds)
        .snapshots();
  }

  acceptFriendRequest({required FriendRequestModel friendRequest}) {
    _userFirebaseServices.acceptFriendRequest(friendRequest: friendRequest);
  }

  rejectFriendRequest({required FriendRequestModel friendRequest}) {
    _userFirebaseServices.rejectFriendRequest(friendRequest: friendRequest);
  }
}
