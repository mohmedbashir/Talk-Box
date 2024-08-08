import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_box/controllers/app_controller.dart';
import 'package:talk_box/models/comment_model.dart';
import 'package:talk_box/models/story_model.dart';
import 'package:talk_box/models/user_model.dart';
import 'package:talk_box/services/stories_services.dart';
import 'package:talk_box/services/user_services.dart';
import 'package:talk_box/utils/helper.dart';
import 'package:talk_box/view/home/main_screen.dart';
import 'package:uuid/uuid.dart';

class HomeController extends AppController {
  TextEditingController postController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  final AppController appController = Get.put(AppController());
  final StoriesService _storiesService = StoriesService();
  final UserFirebaseServices userFirebaseService = UserFirebaseServices();
  final storage = FirebaseStorage.instance;
  var currUser;
  bool _isTextPost = false;
  bool get isTextPost => _isTextPost;

  @override
  void onInit() {
    postController.addListener(() {
      if ((postController.text.replaceAll(' ', '')).isNotEmpty) {
        _isTextPost = true;
      } else {
        _isTextPost = false;
      }
      update();
    });
    currUser = appController.currentUser;
    super.onInit();
  }

/*   Future<Uint8List> getThumbnail(String videoLink) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video:
          'https://firebasestorage.googleapis.com/v0/b/talk-box-7bc47.appspot.com/o/Stories%2FMon%20Oct%2031%2000%3A16%3A24%20GMT%2B02%3A00%202022-4d344b99-a3ab-425f-b81b-aa210e6983a0?alt=media&token=237833fb-8872-45d5-8a61-0be12b465f11',
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 25,
    );
    return uint8list!;
  } */

//////////adding stories from local storage /////////////////////
  Future<void> selectFile(String storyType) async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
          type: storyType == 'photo' ? FileType.image : FileType.video);
    } on Exception {}
    if (result != null) {
      addStoryTofirebasStorage(storyType: storyType, result: result);
    } else {
      /*  Helper.customSnakBar(
          success: false, title: 'خطأ', message: 'لم تقم بتحديد أي صورة'); */
    }
  }

  UploadTask? uploadTask;
/////// adding stories to firebase storage
  void addStoryTofirebasStorage(
      {required String storyType, FilePickerResult? result}) async {
    // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    PlatformFile? platformFile;
    String? storyLink;

    if (result != null) {
      platformFile = result.files.first;
      final file = File(platformFile.path!);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('Stories/${platformFile.name}');
      uploadTask = firebaseStorageRef.putFile(File(file.path));

      TaskSnapshot taskSnapshot = await uploadTask!.whenComplete(() => null);
      storyLink = await taskSnapshot.ref.getDownloadURL();
    }

    final story = StoryModel(
        storyId: const Uuid().v4(),
        publisherId: appController.currentUser.uId,
        phublisherPhoto: appController.currentUser.avatarUrl,
        storyType: storyType,
        storyContent: storyType == 'text' ? postController.text : storyLink,
        phublisherName: appController.currentUser.name,
        firebaseStoragePath:
            storyType == 'text' ? null : 'Stories/${platformFile!.name}',
        publishTime: FieldValue.serverTimestamp());

    await _storiesService.addStoryToFirebase(
        story, appController.currentUser.uId!);
    postController.clear();
  }

//////////// record a view on the story
  void viewTheStory({required String storyId}) async {
    await _storiesService.view(
      storyId: storyId,
      viewerId: appController.currentUser.uId!,
    );
  }

  Future<List<UserModel>> getStoryViewrs({required String storyId}) async {
    return await _storiesService.getstoryViewers(storyId: storyId);
  }

//////////// record a like on the story
  /* Icon? likeBtn = Icon(
    Icons.favorite_border_rounded,
    color: Colors.white,
    size: 30,
  );

  void onLikeButtonPressed({required String storyId}) {
    FirebaseFirestore.instance.collection('Stories').doc(storyId).update({
      'likes': FieldValue.arrayUnion([appController.currentUser.uId])
    });
  }

  Future checkIfLiked({required String storyId}) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Stories')
        .doc(storyId)
        .get();

    List<dynamic>? likers = (doc.data() as Map<String, dynamic>)['likes'];
    if (likers != null) {
      if (likers.contains(appController.currentUser.uId)) {
        likeBtn = Icon(
          Icons.favorite_rounded,
          color: Colors.red,
          size: 30,
        );
        update();
      } else {
        likeBtn = Icon(
          Icons.favorite_border_rounded,
          color: Colors.white,
          size: 30,
        );
      }
    }
  } */
  IconData likeBtn = Icons.favorite_border;
  void likeTheStory({required String storyId}) async {
    await _storiesService.like(
      storyId: storyId,
      likerId: appController.currentUser.uId!,
    );
  }

  void unlikeTheStory({required String storyId}) async {
    await _storiesService.unlike(
      storyId: storyId,
      likerId: appController.currentUser.uId!,
    );
  }

  Future<bool> checkIfIlikerTheStory({required String storyId}) {
    return _storiesService.checkIfUserLikeTheStory(
        storyId, appController.currentUser.uId!);
  }

  Future<List<UserModel>> getStoryLikers({required String storyId}) async {
    return await _storiesService.getStoryLikers(storyId: storyId);
  }

////////////// delete a story from firebase firestore and firestorage
  void deleteStory({required StoryModel story}) {
    _storiesService.deleteStory(story.storyId!);
    if (story.storyType != 'text') {
      Reference ref =
          FirebaseStorage.instance.ref().child(story.firebaseStoragePath!);
      ref
          .delete()
          .then((value) => print("File deleted successfully."))
          .catchError((error) => print("Failed to delete file: $error"));
    }
    Get.back();
    Get.back();
  }

  addComment({
    required String storyId,
  }) {
    if (commentController.text.isNotEmpty) {
      _storiesService.comment(
          storyId: storyId,
          commenterId: appController.currentUser.uId!,
          commentContent: commentController.text);
    }
  }

  Future<List<Commenter>> getCommentsOfStory({required String storyId}) async {
    return await _storiesService.getComments(storyId: storyId);
  }

  //////////////////////////////
  Future report({required storyId}) async {
    FirebaseFirestore.instance.collection('Reports').doc().set({
      'reporterId': appController.currentUser.uId,
      'reportTime': Timestamp.now(),
      'storyId': storyId,
    });
  }
}
