import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import 'package:talk_box/models/friend_request_model.dart';
import 'package:talk_box/models/user_model.dart';
import 'package:talk_box/services/notification_service.dart';
import 'package:talk_box/utils/helper.dart';

class UserFirebaseServices {
  final CollectionReference<Map<String, dynamic>> usersCollection =
      FirebaseFirestore.instance.collection('Users');
// AuthController authController = Get.put(dependency)
  Future addUserToFireBase(UserModel user) async {
    await usersCollection.doc(user.uId).set(user.toJson());
  }

  Future<UserModel> fethcUserData(String userId) async {
    final userDataSnapShot = await usersCollection.doc(userId).get();

    final userData = userDataSnapShot.data();
    if (userData != null) {
      return UserModel.fromJson(userData);
    } else {
      Helper.customSnakBar(title: "error".tr, message: "tryLater".tr);
      throw Exception('User data not found');
    }
  }

  /////////freinds Requests////////////////////////////////
  final CollectionReference<Map<String, dynamic>> friendRequestsCollection =
      FirebaseFirestore.instance.collection('FriendRequests');

  Future<void> sendFriendRequest({
    required FriendRequestModel friendRequest,
    required String currentUserName,
  }) async {
    /*  if (await areUsersFriends(
        friendRequest.requester!, friendRequest.recipient!)) {
      Helper.customSnakBar(
          success: false,
          title: "friendRequest1".tr,
          message: "friendRequest12".tr);
    } else if (await checkIfThereRequests(
        friendRequest.requester!, friendRequest.recipient!)) {
      Helper.customSnakBar(
          success: false,
          title: "friendRequest1".tr,
          message: "friendRequest13".tr);
    } else if (!(await areUsersFriends(
            friendRequest.requester!, friendRequest.recipient!)) &&
        !(await checkIfThereRequests(
            friendRequest.requester!, friendRequest.recipient!))) */
    await friendRequestsCollection.doc().set(friendRequest.toJson());
    Helper.customSnakBar(
        success: true,
        title:
            '${"friendRequest14".tr} ${(await UserFirebaseServices().getFriendName(friendUid: friendRequest.recipient!)).split(' ')[0]}',
        message: "friendRequest15".tr);
    NotificationService.sendPushNotification(
        title: "friendRequest16".tr,
        body: "${"friendRequest17".tr}$currentUserName",
        to: await UserFirebaseServices()
            .getFriendFcm(friendUid: friendRequest.recipient!));
  }

  Future<bool> areUsersFriends(String userId1, String userId2) async {
    final userData1 = await usersCollection.doc(userId1).get();
    final userData2 = await usersCollection.doc(userId2).get();
    final friends1 = userData1.data()?['friends'] ?? [];
    final friends2 = userData2.data()?['friends'] ?? [];
    return friends1.contains(userId2) && friends2.contains(userId1);
  }

  Future<bool> checkIfThereRequests(String requester, String recipient) async {
    final querySnapshot = await friendRequestsCollection
        .where('requester', isEqualTo: requester)
        .where('recipient', isEqualTo: recipient)
        .get();

    final friendRequests = querySnapshot.docs
        .map((doc) => FriendRequestModel.fromJson(doc.data()))
        .toList();

    return friendRequests.isNotEmpty;
  }

  Future<String> checkFriendshipStatus(
      {required String requester, required String recipient}) async {
    if (await areUsersFriends(requester, recipient)) {
      return "friends";
    }
    if (await checkIfThereRequests(requester, recipient)) {
      return "there is request";
    } else
      return "not friend";
  }

  acceptFriendRequest({required FriendRequestModel friendRequest}) async {
    final QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('requester', isEqualTo: friendRequest.requester)
        .get();
    final DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    await friendRequestsCollection
        .doc(documentSnapshot.id)
        .update({'status': 'accepted'});

    usersCollection.doc(friendRequest.recipient).update({
      'friends': FieldValue.arrayUnion([friendRequest.requester])
    });
    usersCollection.doc(friendRequest.requester).update({
      'friends': FieldValue.arrayUnion([friendRequest.recipient])
    });
  }

  rejectFriendRequest({required FriendRequestModel friendRequest}) async {
    final QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('requester', isEqualTo: friendRequest.requester)
        .where('recipient', isEqualTo: friendRequest.recipient)
        .where('status', isEqualTo: 'pending')
        .get();
    final DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    await friendRequestsCollection.doc(documentSnapshot.id).delete();
  }

  /// get avatar photot ///////////////
  ///
  final FirebaseStorage storage = FirebaseStorage.instance;

  /* Future<List<String>> getPhotoUrls() async {
    Reference storageRef = storage.ref().child('Avatar');
    ListResult listResult = await storageRef.listAll();
    List<String> photoUrls = [];

    for (var item in listResult.items) {
      String downloadUrl = await item.getDownloadURL();
      photoUrls.add(downloadUrl);
    }

    return photoUrls;
  } */

  updateAvatar(
      {required String currentUserId, required String newAvatar}) async {
    await usersCollection.doc(currentUserId).update({'avatarUrl': newAvatar});
  }

  Future<String> getFriendFcm({required String friendUid}) async {
    final friendDocRef = usersCollection.doc(friendUid);
    final friendDoc = await friendDocRef.get();
    String fcmToken = friendDoc.get('fcmToken');
    return fcmToken;
  }

  Future<String> getFriendName({required String friendUid}) async {
    final friendDocRef = usersCollection.doc(friendUid);
    final friendDoc = await friendDocRef.get();
    String friendname = friendDoc.get('name');
    return friendname;
  }

  void updateToken({required String uid}) async {
    usersCollection
        .doc(uid)
        .update({'fcmToken': await FirebaseMessaging.instance.getToken()});
  }
}
