// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_box/models/comment_model.dart';

import 'package:talk_box/models/story_model.dart';
import 'package:talk_box/models/user_model.dart';

class StoriesService {
  final CollectionReference<Map<String, dynamic>> _storiesCollection =
      FirebaseFirestore.instance.collection('Stories');
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('Users');

  Future<void> addStoryToFirebase(StoryModel story, String userId) async {
    await _storiesCollection.doc(story.storyId).set(story.toJson());
    await _usersCollection.doc(userId).update({
      'stories': [story.storyId]
    });
  }

/////////////views/////
  Future view({required String storyId, required String viewerId}) async {
    await _storiesCollection.doc(storyId).update({
      'views': FieldValue.arrayUnion([viewerId])
    });
  }

  Future<List<UserModel>> getstoryViewers({required storyId}) async {
    List<UserModel> viewersOfStory = [];
    final story = await _storiesCollection.doc(storyId).get();

    List storyViewersDataSnapShot = story.get('views') ?? [];
    final _storyViewersQuery =
        await _usersCollection.where('uId', whereIn: storyViewersDataSnapShot);
    final viewrs = await _storyViewersQuery.get();

    viewrs.docs.forEach((element) {
      viewersOfStory.add(UserModel.fromJson(element.data()));
    });
    return viewersOfStory;
  }

  /////////////likes/////
  Future like({required String storyId, required String likerId}) async {
    await _storiesCollection.doc(storyId).update({
      'likes': FieldValue.arrayUnion([likerId])
    });
  }

  Future unlike({required String storyId, required String likerId}) async {
    await _storiesCollection.doc(storyId).update({
      'likes': FieldValue.arrayRemove([likerId])
    });
  }

  Future<bool> checkIfUserLikeTheStory(
      String storyId, String currentUserId) async {
    final story = await _storiesCollection.doc(storyId).get();
    final storyLikers = story.data()?['likes'] ?? [];

    final storyRef =
        FirebaseFirestore.instance.collection('stories').doc(storyId);

    final snapshot = await storyRef.get();
    final likedBy = List<String>.from(snapshot.data()?['likes'] ?? []);

    if (likedBy.contains(currentUserId)) {
      print(
          'User has already liked the story, change the appearance of the like button accordingly');
    } else {
      print(
          'User hasnt liked the story yet, display the default appearance of the like button');
    }
    return storyLikers.contains(currentUserId);
  }

  Future<List<UserModel>> getStoryLikers({required storyId}) async {
    List<UserModel> likersOfStory = [];
    final story = await _storiesCollection.doc(storyId).get();

    List storyLikersDataSnapShot = story.get('likes') ?? [];

    if (storyLikersDataSnapShot.isNotEmpty) {
      final _storyLikersQuery =
          await _usersCollection.where('uId', whereIn: storyLikersDataSnapShot);
      final likers = await _storyLikersQuery.get();
      likers.docs.forEach((element) {
        likersOfStory.add(UserModel.fromJson(element.data()));
      });
    }

    return likersOfStory;
  }

  /////////////Comments/////
  Future comment(
      {required String storyId,
      required String commenterId,
      required String commentContent}) async {
    await _storiesCollection.doc(storyId).update({
      'comments': FieldValue.arrayUnion([
        Comment(commentContent: commentContent, commenter: commenterId).toJson()
      ])
    });
  }

  Future<List<Commenter>> getComments({required String storyId}) async {
    List<Commenter> commentsOfStory = [];
    final story = await _storiesCollection.doc(storyId).get();
    List storyCommentsDataSnapShot = story.get('comments') ?? [];
    if (storyCommentsDataSnapShot.isNotEmpty) {
      for (int i = 0; i < storyCommentsDataSnapShot.length; i++) {
        final commentOwner =
            await getUserById(storyCommentsDataSnapShot[i]['commenter']);
        commentsOfStory.add(
          Commenter(
              commentOwner: commentOwner,
              comment: storyCommentsDataSnapShot[i]['commentContent']),
        );
      }
    }

    return commentsOfStory;
  }

  Future<UserModel> getUserById(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    print(UserModel.fromJson(doc.data()!).uId);
    return UserModel.fromJson(doc.data()!);
  }

//////////////delete//////////
  Future deleteStory(String storyId) async {
    await _storiesCollection
        .doc(storyId)
        .delete()
        .then((value) => print('storyDeleted'));
  }
}
